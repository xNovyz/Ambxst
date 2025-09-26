pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.globals

Singleton {
    id: root

    property alias loader: loader

    FileView {
        id: loader
        path: Qt.resolvedUrl("../config.json")
        preload: true
        watchChanges: true
        onFileChanged: reload()

        adapter: JsonAdapter {
            property JsonObject theme: JsonObject {
                property bool oledMode: false
                property bool lightMode: false
                property real opacity: 1.0
                property int roundness: 16
                property int borderSize: 0
                property string borderColor: "background"
                property string font: "Roboto Condensed"
                property int fontSize: 14
                property bool fillIcons: false
                property string currentTheme: "default"
                property bool enableCorners: true
                property int animDuration: 300
                property real shadowOpacity: 0.5
                property int shadowXOffset: 0
                property int shadowYOffset: 0
                property real shadowBlur: 1
            }

            property JsonObject bar: JsonObject {
                property string position: "top"
                property string launcherIcon: ""
                property bool showBackground: false
                property real bgOpacity: 0.75
                property bool verbose: true
                property list<string> screenList: []
            }

            property JsonObject workspaces: JsonObject {
                property int shown: 10
                property bool showAppIcons: true
                property bool alwaysShowNumbers: false
                property bool showNumbers: false
            }

            property JsonObject overview: JsonObject {
                property int rows: 2
                property int columns: 5
                property real scale: 0.1
                property real workspaceSpacing: 4
            }

            property JsonObject notch: JsonObject {
                property string theme: "default"
            }

            property JsonObject hyprland: JsonObject {
                property string activeBorderColor: "primary"
                property string inactiveBorderColor: "background"
                property int borderSize: 2
                property int rounding: 16
                property bool syncRoundness: true
                property bool syncBorderWidth: false
                property bool syncBorderColor: false
            }

            property JsonObject performance: JsonObject {
                property bool blurTransition: true
                property bool windowPreview: true
            }

            property JsonObject weather: JsonObject {
                property string location: ""
                property string unit: "C"
            }
        }
    }

    // Theme configuration
    property QtObject theme: loader.adapter.theme
    property bool oledMode: lightMode ? false : theme.oledMode
    property bool lightMode: theme.lightMode
    property real opacity: Math.min(Math.max(theme.opacity, 0.1), 1.0)
    property int roundness: theme.roundness
    property string defaultFont: theme.font
    property string currentTheme: theme.currentTheme
    property int animDuration: theme.animDuration

    // Detectar cambios en lightMode y ejecutar Matugen
    onLightModeChanged: {
        console.log("lightMode changed to:", lightMode);
        // Ejecutar Matugen con el wallpaper actual si existe un wallpaper manager
        if (GlobalStates.wallpaperManager) {
            var wallpaperManager = GlobalStates.wallpaperManager;
            if (wallpaperManager.currentWallpaper) {
                console.log("Re-running Matugen due to lightMode change");
                wallpaperManager.runMatugenForCurrentWallpaper();
            }
        }
    }

    // Bar configuration
    property QtObject bar: loader.adapter.bar
    property real bgOpacity: Math.min(Math.max(bar.opacity, 0.1), 1.0)

    // Workspace configuration
    property QtObject workspaces: loader.adapter.workspaces

    // Overview configuration
    property QtObject overview: loader.adapter.overview

    // Notch configuration
    property QtObject notch: loader.adapter.notch
    property string notchTheme: theme.borderSize > 0 ? "island" : notch.theme

    // Hyprland configuration
    property QtObject hyprland: loader.adapter.hyprland
    property int hyprlandRounding: hyprland.syncRoundness ? Math.max(0, roundness - hyprlandBorderSize) : Math.max(0, hyprland.rounding - hyprland.borderSize)
    property int hyprlandBorderSize: hyprland.syncBorderWidth ? theme.borderSize : hyprland.borderSize
    property string hyprlandBorderColor: hyprland.syncBorderColor ? theme.borderColor : hyprland.activeBorderColor

    // Performance configuration
    property QtObject performance: loader.adapter.performance
    property bool blurTransition: performance.blurTransition

    // Weather configuration
    property QtObject weather: loader.adapter.weather
}
