pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property bool active: true
    property var items: []
    property var imageDataById: ({})
    property int revision: 0
    
    readonly property string dbPath: Quickshell.dataPath("clipboard.db")
    readonly property string binaryDataDir: Quickshell.dataPath("clipboard-data")
    readonly property string schemaPath: Qt.resolvedUrl("clipboard_init.sql").toString().replace("file://", "")
    readonly property string insertScriptPath: Qt.resolvedUrl("../../scripts/clipboard_insert.sh").toString().replace("file://", "")

    property bool _initialized: false
    property string _lastTextHash: ""
    property string _lastImageHash: ""

    signal listCompleted()

    // Timer to poll clipboard
    property Timer pollTimer: Timer {
        interval: 1000
        running: root._initialized
        repeat: true
        onTriggered: root.checkClipboard()
    }

    // Initialize database
    property Process initDbProcess: Process {
        running: false
        
        onExited: function(code) {
            if (code === 0) {
                console.log("ClipboardService: Database initialized");
                root._initialized = true;
                ensureBinaryDataDir();
                Qt.callLater(root.list);
            } else {
                console.warn("ClipboardService: Failed to initialize database");
            }
        }
    }

    property Process ensureDirProcess: Process {
        running: false
    }

    // Check text clipboard
    property Process checkTextProcess: Process {
        running: false
        command: ["sh", "-c", "tmpfile=$(mktemp); wl-paste --type text 2>/dev/null > \"$tmpfile\" && echo \"$tmpfile|$(md5sum < \"$tmpfile\" | cut -d' ' -f1)\" || rm -f \"$tmpfile\""]
        
        stdout: StdioCollector {
            waitForEnd: true
            
            onStreamFinished: {
                var line = text.trim();
                if (line.length === 0) return;
                
                var parts = line.split('|');
                if (parts.length !== 2) return;
                
                var tmpFile = parts[0];
                var hash = parts[1];
                
                if (hash && hash !== root._lastTextHash) {
                    console.log("ClipboardService: Text clipboard changed, hash:", hash);
                    root._lastTextHash = hash;
                    root._pendingTmpFile = tmpFile;
                    readTmpFileProcess.running = true;
                } else if (tmpFile.length > 0) {
                    // Same content, cleanup tmpfile
                    cleanupTmpProcess.command = ["rm", "-f", tmpFile];
                    cleanupTmpProcess.running = true;
                }
            }
        }
        
        onExited: function(code) {
            if (code !== 0) {
                console.warn("ClipboardService: checkTextProcess exited with code:", code);
            }
        }
    }
    
    property string _pendingTmpFile: ""
    
    property Process readTmpFileProcess: Process {
        running: false
        command: ["cat", root._pendingTmpFile]
        
        stdout: StdioCollector {
            waitForEnd: true
            
            onStreamFinished: {
                var content = text;
                if (content.length > 0) {
                    console.log("ClipboardService: New text item detected, content length:", content.length);
                    // Pass the tmpFile directly to insertTextItem instead of content
                    root.insertTextItemFromFile(root._lastTextHash, root._pendingTmpFile);
                }
            }
        }
        
        onExited: function(code) {
            // Don't cleanup here, let insertProcess do it
        }
    }
    
    property Process cleanupTmpProcess: Process {
        running: false
    }

    // Check image clipboard
    property Process checkImageProcess: Process {
        running: false
        command: ["sh", "-c", "wl-paste --list-types 2>/dev/null | grep '^image/' | head -1"]
        
        stdout: StdioCollector {
            waitForEnd: true
            
            onStreamFinished: {
                var mimeType = text.trim();
                if (mimeType.length > 0) {
                    root.getImageHash(mimeType);
                }
            }
        }
    }

    property Process getImageHashProcess: Process {
        property string mimeType: ""
        running: false
        command: ["sh", "-c", "wl-paste --type " + mimeType + " 2>/dev/null | md5sum | cut -d' ' -f1"]
        
        stdout: StdioCollector {
            waitForEnd: true
            
            onStreamFinished: {
                var hash = text.trim();
                if (hash && hash !== root._lastImageHash) {
                    console.log("ClipboardService: New image item detected, hash:", hash, "mime:", getImageHashProcess.mimeType);
                    root._lastImageHash = hash;
                    root.insertImageItem(hash, getImageHashProcess.mimeType);
                }
            }
        }
    }

    // List all items from database
    property Process listProcess: Process {
        running: false
        
        stdout: StdioCollector {
            waitForEnd: true
            
            onStreamFinished: {
                var clipboardItems = [];
                
                try {
                    var jsonArray = JSON.parse(text);
                    
                    for (var i = 0; i < jsonArray.length; i++) {
                        var item = jsonArray[i];
                        
                        clipboardItems.push({
                            id: item.id.toString(),
                            preview: item.is_image ? "[Image]" : item.preview,
                            fullContent: item.preview,
                            mime: item.mime_type,
                            isImage: item.is_image === 1,
                            binaryPath: item.binary_path || ""
                        });
                    }
                } catch (e) {
                    console.warn("ClipboardService: Failed to parse clipboard items:", e);
                }
                
                root.items = clipboardItems;
                root.listCompleted();
            }
        }
        
        onExited: function(code) {
            if (code !== 0) {
                root.items = [];
                root.listCompleted();
            }
        }
    }

    // Insert item into database
    property Process insertProcess: Process {
        property string itemHash: ""
        property string itemContent: ""
        property string tmpFile: ""
        running: false
        
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0) {
                    console.warn("ClipboardService: insertProcess stderr:", text);
                }
            }
        }
        
        onExited: function(code) {
            if (code === 0) {
                console.log("ClipboardService: Item inserted successfully");
                Qt.callLater(root.list);
            } else {
                console.warn("ClipboardService: insertProcess failed with code:", code);
            }
            
            // Cleanup temp file
            if (tmpFile.length > 0) {
                cleanupTmpProcess.command = ["rm", "-f", tmpFile];
                cleanupTmpProcess.running = true;
                tmpFile = "";
            }
            
            itemHash = "";
            itemContent = "";
        }
    }

    // Save image binary
    property Process saveImageProcess: Process {
        property string mimeType: ""
        property string hash: ""
        running: false
        
        onExited: function(code) {
            if (code === 0) {
                console.log("ClipboardService: Image saved, inserting into database");
                var binaryPath = root.binaryDataDir + "/" + saveImageProcess.hash;
                
                // Use script to insert, with empty content
                insertImageDbProcess.itemHash = saveImageProcess.hash;
                insertImageDbProcess.itemMimeType = saveImageProcess.mimeType;
                insertImageDbProcess.itemBinaryPath = binaryPath;
                insertImageDbProcess.command = ["sh", "-c", "echo -n '' | '" + root.insertScriptPath + "' '" + root.dbPath + "' '" + saveImageProcess.hash + "' '" + saveImageProcess.mimeType + "' 1 '" + binaryPath + "'"];
                insertImageDbProcess.running = true;
            } else {
                console.warn("ClipboardService: Failed to save image");
            }
        }
    }
    
    // Insert image into database (no stdin needed)
    property Process insertImageDbProcess: Process {
        property string itemHash: ""
        property string itemMimeType: ""
        property string itemBinaryPath: ""
        running: false
        
        onExited: function(code) {
            if (code === 0) {
                console.log("ClipboardService: Image inserted successfully");
                Qt.callLater(root.list);
            } else {
                console.warn("ClipboardService: Failed to insert image into database");
            }
        }
    }

    // Get full content of an item
    property Process getContentProcess: Process {
        property string itemId: ""
        running: false
        
        stdout: StdioCollector {
            waitForEnd: true
            
            onStreamFinished: {
                root.fullContentRetrieved(getContentProcess.itemId, text);
            }
        }
        
        onExited: function(code) {
            if (code !== 0) {
                root.fullContentRetrieved(getContentProcess.itemId, "");
            }
        }
    }

    // Delete item
    property Process deleteProcess: Process {
        property string itemId: ""
        running: false
        
        onExited: function(code) {
            if (code === 0) {
                Qt.callLater(root.list);
            }
        }
    }

    // Clear all items
    property Process clearProcess: Process {
        running: false
        
        onExited: function(code) {
            if (code === 0) {
                root.items = [];
                root.imageDataById = {};
                root.revision++;
                root.listCompleted();
                cleanBinaryDataDir();
            }
        }
    }

    // Load image data
    property Process loadImageProcess: Process {
        property string itemId: ""
        property string mimeType: ""
        running: false
        
        stdout: StdioCollector {
            waitForEnd: true
            
            onStreamFinished: {
                if (text.length > 0) {
                    var cleanBase64 = text.replace(/\s/g, '');
                    var dataUrl = "data:" + loadImageProcess.mimeType + ";base64," + cleanBase64;
                    root.imageDataById[loadImageProcess.itemId] = dataUrl;
                    root.revision++;
                }
            }
        }
    }

    signal fullContentRetrieved(string itemId, string content)

    function initialize() {
        initDbProcess.command = ["sh", "-c", "sqlite3 " + dbPath + " < " + schemaPath];
        initDbProcess.running = true;
    }

    function ensureBinaryDataDir() {
        ensureDirProcess.command = ["mkdir", "-p", binaryDataDir];
        ensureDirProcess.running = true;
    }

    function checkClipboard() {
        if (!checkTextProcess.running) {
            checkTextProcess.running = true;
        }
        if (!checkImageProcess.running) {
            checkImageProcess.running = true;
        }
    }

    function getImageHash(mimeType) {
        getImageHashProcess.mimeType = mimeType;
        getImageHashProcess.command = ["sh", "-c", "wl-paste --type " + mimeType + " 2>/dev/null | md5sum | cut -d' ' -f1"];
        getImageHashProcess.running = true;
    }

    function insertTextItemFromFile(hash, tmpFile) {
        console.log("ClipboardService: insertTextItemFromFile called with hash:", hash, "file:", tmpFile);
        
        // Call insert script with temp file
        insertProcess.itemHash = hash;
        insertProcess.tmpFile = tmpFile;
        insertProcess.command = ["sh", "-c", "cat '" + tmpFile + "' | '" + insertScriptPath + "' '" + dbPath + "' '" + hash + "' 'text/plain' 0 ''"];
        insertProcess.running = true;
        
        // Clear the pending tmp file reference
        _pendingTmpFile = "";
    }
    
    property Process writeTmpProcess: Process {
        property string itemHash: ""
        property string itemContent: ""
        running: false
        
        stdout: StdioCollector {
            waitForEnd: true
            
            onStreamFinished: {
                var tmpFile = text.trim();
                if (tmpFile.length > 0) {
                    console.log("ClipboardService: Created temp file:", tmpFile);
                    // Now call insert script with temp file
                    insertProcess.itemHash = writeTmpProcess.itemHash;
                    insertProcess.tmpFile = tmpFile;
                    insertProcess.command = ["sh", "-c", "cat '" + tmpFile + "' | '" + root.insertScriptPath + "' '" + root.dbPath + "' '" + writeTmpProcess.itemHash + "' 'text/plain' 0 ''"];
                    insertProcess.running = true;
                }
            }
        }
    }

    function insertImageItem(hash, mimeType) {
        var binaryPath = binaryDataDir + "/" + hash;
        saveImageProcess.hash = hash;
        saveImageProcess.mimeType = mimeType;
        saveImageProcess.command = ["sh", "-c", "wl-paste --type " + mimeType + " > " + binaryPath];
        saveImageProcess.running = true;
    }

    function list() {
        if (!_initialized) return;
        // Use JSON mode for reliable parsing
        listProcess.command = ["sh", "-c", 
            "sqlite3 '" + dbPath + "' <<'EOSQL'\n.mode json\nSELECT id, mime_type, preview, is_image, binary_path FROM clipboard_items ORDER BY created_at DESC LIMIT 100;\nEOSQL"
        ];
        listProcess.running = true;
    }

    function getFullContent(id) {
        if (!_initialized) return;
        getContentProcess.itemId = id;
        getContentProcess.command = ["sqlite3", dbPath,
                                     "SELECT full_content FROM clipboard_items WHERE id = " + id + ";"];
        getContentProcess.running = true;
    }

    function deleteItem(id) {
        if (!_initialized) return;
        deleteProcess.itemId = id;
        deleteProcess.command = ["sqlite3", dbPath, "DELETE FROM clipboard_items WHERE id = " + id + ";"];
        deleteProcess.running = true;
    }

    function clear() {
        if (!_initialized) return;
        clearProcess.command = ["sqlite3", dbPath, "DELETE FROM clipboard_items;"];
        clearProcess.running = true;
    }

    function cleanBinaryDataDir() {
        var cleanProc = Process({
            command: ["sh", "-c", "rm -f " + binaryDataDir + "/*"],
            running: true
        });
    }

    function decodeToDataUrl(id, mime) {
        if (imageDataById[id]) {
            return;
        }
        
        for (var i = 0; i < items.length; i++) {
            if (items[i].id === id) {
                var binaryPath = items[i].binaryPath;
                if (binaryPath && binaryPath.length > 0) {
                    loadImageProcess.itemId = id;
                    loadImageProcess.mimeType = mime;
                    loadImageProcess.command = ["base64", "-w", "0", binaryPath];
                    loadImageProcess.running = true;
                }
                break;
            }
        }
    }

    function getImageData(id) {
        return imageDataById[id] || "";
    }

    Component.onCompleted: {
        initialize();
    }
}
