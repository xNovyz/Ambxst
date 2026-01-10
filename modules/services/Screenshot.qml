pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    signal screenshotCaptured(string path)
    signal errorOccurred(string message)
    signal windowListReady(var windows)
    signal lensImageReady(string path)

    property string tempPath: "/tmp/ambxst_freeze.png"
    property string cropPath: "/tmp/ambxst_crop.png"
    property string lensPath: "/tmp/image.png"
    
    // Mode: "normal" saves to Screenshots folder, "lens" saves to /tmp/image.png
    property string captureMode: "normal"
    
    // We'll store the resolved XDG_PICTURES_DIR/Screenshots here
    property string screenshotsDir: ""
    property string finalPath: ""
    property var _activeWorkspaceIds: []
    
    // Store monitor scale factor for coordinate scaling
    property real monitorScale: 1.0
    
    // Store focused monitor name for single-monitor capture
    property string focusedMonitor: ""

    property Process xdgProcess: Process {
        command: ["bash", "-c", "xdg-user-dir PICTURES"]
        running: true
        stdout: StdioCollector {
            onTextChanged: {
                let dir = text.trim() || (Quickshell.env("HOME") + "/Pictures")
                root.screenshotsDir = dir + "/Screenshots"
                ensureDirProcess.running = true
            }
        }
    }

    property Process ensureDirProcess: Process {
        command: ["mkdir", "-p", root.screenshotsDir]
    }

    // Process for initial freeze
    property Process freezeProcess: Process {
        id: freezeProcess
        // command set dynamically based on focused monitor
        onExited: exitCode => {
            console.log("Screenshot: freezeProcess exited with code " + exitCode)
            if (exitCode === 0) {
                console.log("Screenshot: Emitting screenshotCaptured with path: " + root.tempPath)
                root.screenshotCaptured(root.tempPath)
            } else {
                console.warn("Screenshot: grim failed with exit code " + exitCode)
                root.errorOccurred("Failed to capture screen (grim)")
            }
        }
    }
    
    // Process to get scale factor and focused monitor before freeze
    property Process scaleProcess: Process {
        id: scaleProcess
        command: ["hyprctl", "-j", "monitors"]
        stdout: StdioCollector {}
        onExited: exitCode => {
            if (exitCode === 0) {
                try {
                    var monitors = JSON.parse(scaleProcess.stdout.text)
                    for (var i = 0; i < monitors.length; i++) {
                        if (monitors[i].focused) {
                            if (monitors[i].scale) {
                                root.monitorScale = monitors[i].scale
                                console.log("Screenshot: Monitor scale factor detected: " + root.monitorScale)
                            }
                            if (monitors[i].name) {
                                root.focusedMonitor = monitors[i].name
                                console.log("Screenshot: Focused monitor detected: " + root.focusedMonitor)
                            }
                            break
                        }
                    }
                    // Now run freeze with the detected monitor
                    if (root.focusedMonitor !== "") {
                        freezeProcess.command = ["grim", "-o", root.focusedMonitor, root.tempPath]
                    } else {
                        freezeProcess.command = ["grim", root.tempPath]
                    }
                    console.log("Screenshot: Starting freezeProcess with command: " + JSON.stringify(freezeProcess.command))
                    freezeProcess.running = true
                } catch (e) {
                    console.warn("Screenshot: Failed to parse scale: " + e.message)
                    root.monitorScale = 1.0
                    root.focusedMonitor = ""
                    freezeProcess.command = ["grim", root.tempPath]
                    freezeProcess.running = true
                }
            } else {
                root.monitorScale = 1.0
                root.focusedMonitor = ""
                freezeProcess.command = ["grim", root.tempPath]
                freezeProcess.running = true
            }
        }
    }
    
    // Process for fetching monitors (to get active workspaces reliably)
    property Process monitorsProcess: Process {
        id: monitorsProcess
        command: ["hyprctl", "-j", "monitors"]
        stdout: StdioCollector {}
        onExited: exitCode => {
            if (exitCode === 0) {
                try {
                    var monitors = JSON.parse(monitorsProcess.stdout.text)
                    var ids = []
                    for (var i = 0; i < monitors.length; i++) {
                        if (monitors[i].activeWorkspace) {
                            ids.push(monitors[i].activeWorkspace.id)
                        }
                        // Get scale factor from focused monitor
                        if (monitors[i].focused && monitors[i].scale) {
                            root.monitorScale = monitors[i].scale
                            console.log("Screenshot: Monitor scale factor detected: " + root.monitorScale)
                        }
                    }
                    root._activeWorkspaceIds = ids
                    console.log("Screenshot: Active workspaces found via hyprctl: " + JSON.stringify(ids))
                    
                    // Now fetch clients
                    clientsProcess.running = true
                } catch (e) {
                    console.warn("Screenshot: Failed to parse monitors: " + e.message)
                    // Fallback: try fetching clients anyway, filtering might fail or be permissive
                    root._activeWorkspaceIds = []
                    root.monitorScale = 1.0
                    clientsProcess.running = true
                }
            } else {
                console.warn("Screenshot: Failed to fetch monitors")
                root._activeWorkspaceIds = []
                root.monitorScale = 1.0
                clientsProcess.running = true
            }
        }
    }
    
    // Process for fetching clients
    property Process clientsProcess: Process {
        id: clientsProcess
        command: ["hyprctl", "-j", "clients"]
        stdout: StdioCollector {}
        onExited: exitCode => {
            if (exitCode === 0) {
                try {
                    var all = JSON.parse(clientsProcess.stdout.text)
                    var filtered = all.filter(c => {
                        if (!c) return false;
                        if (c.pinned) return true;
                        if (!c.workspace || typeof c.workspace.id === "undefined") return false;
                        return root._activeWorkspaceIds.includes(c.workspace.id)
                    })
                    root.windowListReady(filtered)
                } catch (e) {
                    console.warn("Screenshot: Failed to parse clients: " + e.message)
                    root.errorOccurred("Failed to parse clients: " + e.message)
                }
            } else {
                console.warn("Screenshot: Failed to fetch clients")
            }
        }
    }
    
    // Process for cropping
    property Process cropProcess: Process {
        id: cropProcess
        // command set dynamically
        onExited: exitCode => {
            if (exitCode === 0) {
                if (root.captureMode === "lens") {
                    // Run Google Lens script
                    root.runLensScript()
                    root.captureMode = "normal" // Reset mode
                } else {
                    // After successful save/crop, copy to clipboard
                    copyProcess.running = true
                }
            } else {
                root.errorOccurred("Failed to save image")
            }
        }
    }

    property Process copyProcess: Process {
        command: ["bash", "-c", `wl-copy < "${root.finalPath}"`]
    }
    
    // Process for Google Lens upload
    property Process lensProcess: Process {
        id: lensProcess
        // command set dynamically
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onExited: exitCode => {
            if (exitCode === 0) {
                console.log("Screenshot: Google Lens script executed successfully")
            } else {
                console.warn("Screenshot: Google Lens script failed with exit code " + exitCode)
                console.warn("Screenshot: stderr: " + lensProcess.stderr.text)
                root.errorOccurred("Failed to open Google Lens: " + lensProcess.stderr.text)
            }
        }
    }
    
    property Process openScreenshotsProcess: Process {
        id: openScreenshotsProcess
        command: ["xdg-open", root.screenshotsDir]
    }
    
    property Process verifyImageProcess: Process {
        id: verifyImageProcess
        // command set dynamically
        onExited: exitCode => {
            if (exitCode === 0) {
                // Image exists, proceed with lens script
                var scriptPath = Qt.resolvedUrl("../../scripts/google_lens.sh").toString().replace("file://", "");
                lensProcess.command = ["bash", scriptPath];
                lensProcess.running = true;
            } else {
                console.warn("Screenshot: Image file not found at " + root.lensPath)
                root.errorOccurred("Image file not ready for Google Lens")
            }
        }
    }

    // Timer to delay capture slightly so other UI elements can hide
    property Timer captureDelayTimer: Timer {
        id: captureDelayTimer
        interval: 200  // 200ms delay
        repeat: false
        onTriggered: {
            console.log("Screenshot: Delay complete, starting scaleProcess")
            scaleProcess.running = true
        }
    }

    function freezeScreen() {
        console.log("Screenshot: freezeScreen() called")
        // First wait a bit for other UI elements to hide, then detect monitor and capture
        captureDelayTimer.running = true
    }

    function fetchWindows() {
        console.log("Screenshot: fetchWindows() called")
        // Start the chain: Monitors -> Clients
        monitorsProcess.running = true
    }

    function getTimestamp() {
        // Simple timestamp format YYYY-MM-DD-HH-mm-ss
        var d = new Date()
        // Manually format to avoid weird ISO chars
        var pad = (n) => n < 10 ? '0' + n : n;
        return d.getFullYear() + '-' + 
               pad(d.getMonth() + 1) + '-' + 
               pad(d.getDate()) + '-' + 
               pad(d.getHours()) + '-' + 
               pad(d.getMinutes()) + '-' + 
               pad(d.getSeconds());
    }

    function processRegion(x, y, w, h) {
        console.log("Screenshot: processRegion() called with x=" + x + ", y=" + y + ", w=" + w + ", h=" + h)
        // Determine output path based on mode
        if (root.captureMode === "lens") {
            root.finalPath = root.lensPath;
        } else {
            if (root.screenshotsDir === "") {
                root.screenshotsDir = Quickshell.env("HOME") + "/Pictures/Screenshots"
            }
            var filename = "Screenshot_" + getTimestamp() + ".png"
            root.finalPath = root.screenshotsDir + "/" + filename
        }
        
        console.log("Screenshot: finalPath = " + root.finalPath)
        
        // Scale coordinates by monitor scale factor for accurate cropping
        var scaledX = Math.round(x * root.monitorScale)
        var scaledY = Math.round(y * root.monitorScale)
        var scaledW = Math.round(w * root.monitorScale)
        var scaledH = Math.round(h * root.monitorScale)
        
        console.log(`Screenshot: Region - logical: ${w}x${h}+${x}+${y}, physical: ${scaledW}x${scaledH}+${scaledX}+${scaledY}, scale: ${root.monitorScale}`)
        
        // convert /tmp/ambxst_freeze.png -crop WxH+X+Y /path/to/save.png
        var geom = `${scaledW}x${scaledH}+${scaledX}+${scaledY}`
        console.log("Screenshot: Running crop command: convert " + root.tempPath + " -crop " + geom + " " + root.finalPath)
        cropProcess.command = ["convert", root.tempPath, "-crop", geom, root.finalPath]
        cropProcess.running = true
    }

    function processFullscreen() {
        console.log("Screenshot: processFullscreen() called")
        // Determine output path based on mode
        if (root.captureMode === "lens") {
            root.finalPath = root.lensPath;
        } else {
            if (root.screenshotsDir === "") {
                root.screenshotsDir = Quickshell.env("HOME") + "/Pictures/Screenshots"
            }
            var filename = "Screenshot_" + getTimestamp() + ".png"
            root.finalPath = root.screenshotsDir + "/" + filename
        }
        
        console.log("Screenshot: Copying " + root.tempPath + " to " + root.finalPath)

        // Just copy the freeze file to final path
        cropProcess.command = ["cp", root.tempPath, root.finalPath]
        cropProcess.running = true
    }

    function openScreenshotsFolder() {
        if (root.screenshotsDir === "") {
             // Fallback attempt if not ready
             openScreenshotsProcess.command = ["xdg-open", Quickshell.env("HOME") + "/Pictures/Screenshots"];
        } else {
             openScreenshotsProcess.command = ["xdg-open", root.screenshotsDir];
        }
        openScreenshotsProcess.running = true;
    }

    function runLensScript() {
        var scriptPath = Qt.resolvedUrl("../../scripts/google_lens.sh").toString().replace("file://", "");
        
        // Verify image exists before running script
        verifyImageProcess.command = ["test", "-f", root.lensPath];
        verifyImageProcess.running = true;
    }
}
