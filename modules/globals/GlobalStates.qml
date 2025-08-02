pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    property bool oledMode: loader.adapter.oledMode
    property int roundness: loader.adapter.roundness

    FileView {
        id: loader
        path: Qt.resolvedUrl("./globals.json")
        preload: true
        watchChanges: true
        onFileChanged: reload()

        adapter: JsonAdapter {
            property bool oledMode: false
            property int roundness: 16
        }
    }

    property bool notchOpen: launcherOpen || dashboardOpen || overviewOpen
    property bool overviewOpen: false
    property bool launcherOpen: false
    property bool dashboardOpen: false
    property bool workspaceShowNumbers: false
    property var wallpaperManager: null
}
