pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    FileView {
        id: loader
        path: Qt.resolvedUrl("./config.json")
        preload: true
        watchChanges: true
        onFileChanged: reload()

        adapter: JsonAdapter {
            property bool oledMode: false
            property int roundness: 16
            property bool barBottom: false
            property bool barBorderless: false
            property string barTopLeftIcon: "spark"
            property bool barShowBackground: true
            property bool barVerbose: true
            property list<string> barScreenList: []
            property int workspacesShown: 10
            property bool workspacesShowAppIcons: true
            property bool workspacesAlwaysShowNumbers: false
            property int workspacesShowNumberDelay: 300
            property bool workspacesShowNumbers: false
        }
    }

    // Theme configuration
    property bool oledMode: loader.adapter.oledMode
    property int roundness: loader.adapter.roundness

    // Bar configuration
    property QtObject bar: QtObject {
        property bool bottom: loader.adapter.barBottom
        property bool borderless: loader.adapter.barBorderless
        property string topLeftIcon: loader.adapter.barTopLeftIcon
        property bool showBackground: loader.adapter.barShowBackground
        property bool verbose: loader.adapter.barVerbose
        property list<string> screenList: loader.adapter.barScreenList
    }

    // Workspace configuration
    property QtObject workspaces: QtObject {
        property int shown: loader.adapter.workspacesShown
        property bool showAppIcons: loader.adapter.workspacesShowAppIcons
        property bool alwaysShowNumbers: loader.adapter.workspacesAlwaysShowNumbers
        property int showNumberDelay: loader.adapter.workspacesShowNumberDelay
        property bool showNumbers: loader.adapter.workspacesShowNumbers
    }
}