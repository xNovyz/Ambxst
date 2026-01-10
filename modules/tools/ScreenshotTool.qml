import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import qs.modules.theme
import qs.modules.components
import qs.modules.services
import qs.config

PanelWindow {
    id: screenshotPopup

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    // Visible only when explicitly opened
    visible: state !== "idle"
    exclusionMode: ExclusionMode.Ignore

    property string state: "idle" // idle, loading, active, processing
    property string currentMode: "region" // region, window, screen
    property var activeWindows: []

    property var modes: [
        {
            name: "region",
            icon: Icons.regionScreenshot,
            tooltip: "Region"
        },
        {
            name: "window",
            icon: Icons.windowScreenshot,
            tooltip: "Window"
        },
        {
            name: "screen",
            icon: Icons.fullScreenshot,
            tooltip: "Screen"
        }
    ]

    function open() {
        // Reset to default state
        if (modeGrid)
            modeGrid.currentIndex = 0;
        screenshotPopup.currentMode = "region";

        screenshotPopup.state = "loading";
        Screenshot.freezeScreen();
    }

    function close() {
        screenshotPopup.state = "idle";
    }

    function executeCapture() {
        if (screenshotPopup.currentMode === "screen") {
            Screenshot.processFullscreen();
            screenshotPopup.close();
        } else if (screenshotPopup.currentMode === "region") {
            // Check if rect exists
            if (selectionRect.width > 0) {
                Screenshot.processRegion(selectionRect.x, selectionRect.y, selectionRect.width, selectionRect.height);
                screenshotPopup.close();
            }
        }
    }

    // Connect to global Screenshot singleton signals
    Connections {
        target: Screenshot
        function onScreenshotCaptured(path) {
            previewImage.source = "";
            previewImage.source = "file://" + path;
            screenshotPopup.state = "active";
            // Reset selection
            selectionRect.width = 0;
            selectionRect.height = 0;
            // Fetch windows if we are in window mode, or pre-fetch
            Screenshot.fetchWindows();

            // Force focus on the overlay window content
            modeGrid.forceActiveFocus();
        }
        function onWindowListReady(windows) {
            screenshotPopup.activeWindows = windows;
        }
        function onErrorOccurred(msg) {
            console.warn("Screenshot Error:", msg);
            screenshotPopup.close();
        }
    }

    // Main Content
    FocusScope {
        id: mainFocusScope
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: screenshotPopup.close()

        // 1. The "Frozen" Image
        Image {
            id: previewImage
            anchors.fill: parent
            fillMode: Image.Stretch
            visible: screenshotPopup.state === "active"
        }

        // 2. Dimmer (Dark overlay)
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: screenshotPopup.state === "active" ? 0.4 : 0
            visible: screenshotPopup.state === "active" && screenshotPopup.currentMode !== "screen"
        }

        // 3. Window Selection Highlights
        Item {
            anchors.fill: parent
            visible: screenshotPopup.state === "active" && screenshotPopup.currentMode === "window"

            Repeater {
                model: screenshotPopup.activeWindows
                delegate: Rectangle {
                    x: modelData.at[0]
                    y: modelData.at[1]
                    width: modelData.size[0]
                    height: modelData.size[1]
                    color: "transparent"
                    border.color: hoverHandler.hovered ? Styling.styledRectItem("overprimary") : "transparent"
                    border.width: 2

                    Rectangle {
                        anchors.fill: parent
                        color: Styling.styledRectItem("overprimary")
                        opacity: hoverHandler.hovered ? 0.2 : 0
                    }

                    HoverHandler {
                        id: hoverHandler
                    }

                    TapHandler {
                        onTapped: {
                            Screenshot.processRegion(parent.x, parent.y, parent.width, parent.height);
                            screenshotPopup.close();
                        }
                    }
                }
            }
        }

        // 4. Region Selection (Drag) and Screen Capture (Click)
        MouseArea {
            id: regionArea
            anchors.fill: parent
            enabled: screenshotPopup.state === "active" && (screenshotPopup.currentMode === "region" || screenshotPopup.currentMode === "screen")
            hoverEnabled: true
            cursorShape: screenshotPopup.currentMode === "region" ? Qt.CrossCursor : Qt.ArrowCursor

            property point startPoint: Qt.point(0, 0)
            property bool selecting: false

            onPressed: mouse => {
                if (screenshotPopup.currentMode === "screen") {
                    // Immediate capture for screen mode
                    return;
                }

                startPoint = Qt.point(mouse.x, mouse.y);
                selectionRect.x = mouse.x;
                selectionRect.y = mouse.y;
                selectionRect.width = 0;
                selectionRect.height = 0;
                selecting = true;
            }

            onClicked: {
                if (screenshotPopup.currentMode === "screen") {
                    Screenshot.processFullscreen();
                    screenshotPopup.close();
                }
            }

            onPositionChanged: mouse => {
                if (!selecting)
                    return;
                var x = Math.min(startPoint.x, mouse.x);
                var y = Math.min(startPoint.y, mouse.y);
                var w = Math.abs(startPoint.x - mouse.x);
                var h = Math.abs(startPoint.y - mouse.y);

                selectionRect.x = x;
                selectionRect.y = y;
                selectionRect.width = w;
                selectionRect.height = h;
            }

            onReleased: {
                if (!selecting)
                    // for screen mode click
                    return;
                selecting = false;
                // Auto capture on release? Or wait for confirm?
                // Usually region drag ends in capture.
                if (selectionRect.width > 5 && selectionRect.height > 5) {
                    Screenshot.processRegion(selectionRect.x, selectionRect.y, selectionRect.width, selectionRect.height);
                    screenshotPopup.close();
                }
            }
        }

        // Visual Selection Rect
        Rectangle {
            id: selectionRect
            visible: screenshotPopup.state === "active" && screenshotPopup.currentMode === "region"
            color: "transparent"
            border.color: Styling.styledRectItem("overprimary")
            border.width: 2

            Rectangle {
                anchors.fill: parent
                color: Styling.styledRectItem("overprimary")
                opacity: 0.2
            }
        }

        // 5. Controls UI (Bottom Bar)
        Rectangle {
            id: controlsBar
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 50

            // Padding of 16px around the content
            width: modeGrid.width + 32
            height: modeGrid.height + 32

            radius: Styling.radius(20)
            color: Colors.background
            border.color: Colors.surface
            border.width: 1
            visible: screenshotPopup.state === "active"

            // Catch-all MouseArea
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                preventStealing: true
            }

            ActionGrid {
                id: modeGrid
                anchors.centerIn: parent
                actions: screenshotPopup.modes
                buttonSize: 48
                iconSize: 24
                spacing: 10

                onCurrentIndexChanged: {
                    screenshotPopup.currentMode = screenshotPopup.modes[currentIndex].name;
                }

                onActionTriggered: {
                    screenshotPopup.executeCapture();
                }
            }
        }
    }
}
