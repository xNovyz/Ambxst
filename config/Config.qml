pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.globals
import qs.modules.theme
import qs.modules.services as Services

Singleton {
    id: root

    property alias loader: loader
    property alias keybindsLoader: keybindsLoader
    property bool initialLoadComplete: false
    property bool keybindsInitialLoadComplete: false
    property string configPath: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/Ambxst/config.json"
    property string keybindsPath: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/Ambxst/binds.json"

    Process {
        id: checkFile
        running: true
        command: ["sh", "-c", "mkdir -p \"$(dirname '" + configPath + "')\" && test -f \"" + configPath + "\""]

        onExited: exitCode => {
            if (exitCode !== 0) {
                console.log("config.json not found, creating with default values...");
                loader.writeAdapter();
            }
            root.initialLoadComplete = true;
        }
    }

    Process {
        id: checkKeybindsFile
        running: true
        command: ["sh", "-c", "mkdir -p \"$(dirname '" + keybindsPath + "')\" && test -f \"" + keybindsPath + "\""]

        onExited: exitCode => {
            if (exitCode !== 0) {
                console.log("binds.json not found, creating with default values...");
                keybindsLoader.writeAdapter();
            }
            root.keybindsInitialLoadComplete = true;
        }
    }

    FileView {
        id: loader
        path: configPath
        atomicWrites: true
        watchChanges: true
        onFileChanged: reload()
        onPathChanged: reload()
        onAdapterUpdated: {
            if (root.initialLoadComplete) {
                loader.writeAdapter();
            }
        }

        adapter: JsonAdapter {
            property JsonObject theme: JsonObject {
                property bool oledMode: false
                property bool lightMode: false
                property real opacity: 1.0
                property int roundness: 16
                property int borderSize: 0
                property string borderColor: "surfaceBright"
                property string font: "Roboto Condensed"
                property int fontSize: 14
                property bool tintIcons: false
                property string currentTheme: "default"
                property bool enableCorners: true
                property int animDuration: 300
                property real shadowOpacity: 0.5
                property string shadowColor: "shadow"
                property int shadowXOffset: 0
                property int shadowYOffset: 0
                property real shadowBlur: 1
                property list<var> bgColor: [["background", 0.0]]
                property string bgOrientation: "vertical"
                property list<var> paneColor: [["surface", 0.0]]
                property string paneOrientation: "vertical"
                property list<var> separatorColor: [["surfaceBright", 0.0]]

                // Gradient configurations
                property list<var> gradBg: [["background", 0.0]]
                property string gradBgType: "linear"
                property int gradBgAngle: 0
                property real gradBgCenterX: 0.5
                property real gradBgCenterY: 0.5
                property real gradBgHalftoneDotMin: 2.0
                property real gradBgHalftoneDotMax: 8.0
                property real gradBgHalftoneStart: 0.0
                property real gradBgHalftoneEnd: 1.0
                property string gradBgHalftoneDotColor: "primary"
                property string gradBgHalftoneBackgroundColor: "surface"
                property list<var> gradPane: [["surface", 0.0]]
                property string gradPaneType: "linear"
                property int gradPaneAngle: 0
                property real gradPaneCenterX: 0.5
                property real gradPaneCenterY: 0.5
                property real gradPaneHalftoneDotMin: 2.0
                property real gradPaneHalftoneDotMax: 8.0
                property real gradPaneHalftoneStart: 0.0
                property real gradPaneHalftoneEnd: 1.0
                property string gradPaneHalftoneDotColor: "primary"
                property string gradPaneHalftoneBackgroundColor: "surface"
                property list<var> gradCommon: [["surface", 0.0]]
                property string gradCommonType: "linear"
                property int gradCommonAngle: 0
                property real gradCommonCenterX: 0.5
                property real gradCommonCenterY: 0.5
                property real gradCommonHalftoneDotMin: 2.0
                property real gradCommonHalftoneDotMax: 8.0
                property real gradCommonHalftoneStart: 0.0
                property real gradCommonHalftoneEnd: 1.0
                property string gradCommonHalftoneDotColor: "primary"
                property string gradCommonHalftoneBackgroundColor: "surface"
                property list<var> gradFocus: [["surfaceBright", 0.0]]
                property string gradFocusType: "linear"
                property int gradFocusAngle: 0
                property real gradFocusCenterX: 0.5
                property real gradFocusCenterY: 0.5
                property real gradFocusHalftoneDotMin: 2.0
                property real gradFocusHalftoneDotMax: 8.0
                property real gradFocusHalftoneStart: 0.0
                property real gradFocusHalftoneEnd: 1.0
                property string gradFocusHalftoneDotColor: "primary"
                property string gradFocusHalftoneBackgroundColor: "surfaceBright"
                property list<var> gradPrimary: [["primary", 0.0]]
                property string gradPrimaryType: "linear"
                property int gradPrimaryAngle: 0
                property real gradPrimaryCenterX: 0.5
                property real gradPrimaryCenterY: 0.5
                property real gradPrimaryHalftoneDotMin: 2.0
                property real gradPrimaryHalftoneDotMax: 8.0
                property real gradPrimaryHalftoneStart: 0.0
                property real gradPrimaryHalftoneEnd: 1.0
                property string gradPrimaryHalftoneDotColor: "overPrimary"
                property string gradPrimaryHalftoneBackgroundColor: "primary"
                property list<var> gradPrimaryFocus: [["overBackground", 0.0]]
                property string gradPrimaryFocusType: "linear"
                property int gradPrimaryFocusAngle: 0
                property real gradPrimaryFocusCenterX: 0.5
                property real gradPrimaryFocusCenterY: 0.5
                property real gradPrimaryFocusHalftoneDotMin: 2.0
                property real gradPrimaryFocusHalftoneDotMax: 8.0
                property real gradPrimaryFocusHalftoneStart: 0.0
                property real gradPrimaryFocusHalftoneEnd: 1.0
                property string gradPrimaryFocusHalftoneDotColor: "primary"
                property string gradPrimaryFocusHalftoneBackgroundColor: "overBackground"
                property list<var> gradOverPrimary: [["overPrimary", 0.0]]
                property string gradOverPrimaryType: "linear"
                property int gradOverPrimaryAngle: 0
                property real gradOverPrimaryCenterX: 0.5
                property real gradOverPrimaryCenterY: 0.5
                property real gradOverPrimaryHalftoneDotMin: 2.0
                property real gradOverPrimaryHalftoneDotMax: 8.0
                property real gradOverPrimaryHalftoneStart: 0.0
                property real gradOverPrimaryHalftoneEnd: 1.0
                property string gradOverPrimaryHalftoneDotColor: "primary"
                property string gradOverPrimaryHalftoneBackgroundColor: "overPrimary"
                property list<var> gradSecondary: [["secondary", 0.0]]
                property string gradSecondaryType: "linear"
                property int gradSecondaryAngle: 0
                property real gradSecondaryCenterX: 0.5
                property real gradSecondaryCenterY: 0.5
                property real gradSecondaryHalftoneDotMin: 2.0
                property real gradSecondaryHalftoneDotMax: 8.0
                property real gradSecondaryHalftoneStart: 0.0
                property real gradSecondaryHalftoneEnd: 1.0
                property string gradSecondaryHalftoneDotColor: "overSecondary"
                property string gradSecondaryHalftoneBackgroundColor: "secondary"
                property list<var> gradSecondaryFocus: [["overBackground", 0.0]]
                property string gradSecondaryFocusType: "linear"
                property int gradSecondaryFocusAngle: 0
                property real gradSecondaryFocusCenterX: 0.5
                property real gradSecondaryFocusCenterY: 0.5
                property real gradSecondaryFocusHalftoneDotMin: 2.0
                property real gradSecondaryFocusHalftoneDotMax: 8.0
                property real gradSecondaryFocusHalftoneStart: 0.0
                property real gradSecondaryFocusHalftoneEnd: 1.0
                property string gradSecondaryFocusHalftoneDotColor: "secondary"
                property string gradSecondaryFocusHalftoneBackgroundColor: "overBackground"
                property list<var> gradOverSecondary: [["overSecondary", 0.0]]
                property string gradOverSecondaryType: "linear"
                property int gradOverSecondaryAngle: 0
                property real gradOverSecondaryCenterX: 0.5
                property real gradOverSecondaryCenterY: 0.5
                property real gradOverSecondaryHalftoneDotMin: 2.0
                property real gradOverSecondaryHalftoneDotMax: 8.0
                property real gradOverSecondaryHalftoneStart: 0.0
                property real gradOverSecondaryHalftoneEnd: 1.0
                property string gradOverSecondaryHalftoneDotColor: "secondary"
                property string gradOverSecondaryHalftoneBackgroundColor: "overSecondary"
                property list<var> gradTertiary: [["tertiary", 0.0]]
                property string gradTertiaryType: "linear"
                property int gradTertiaryAngle: 0
                property real gradTertiaryCenterX: 0.5
                property real gradTertiaryCenterY: 0.5
                property real gradTertiaryHalftoneDotMin: 2.0
                property real gradTertiaryHalftoneDotMax: 8.0
                property real gradTertiaryHalftoneStart: 0.0
                property real gradTertiaryHalftoneEnd: 1.0
                property string gradTertiaryHalftoneDotColor: "overTertiary"
                property string gradTertiaryHalftoneBackgroundColor: "tertiary"
                property list<var> gradTertiaryFocus: [["overBackground", 0.0]]
                property string gradTertiaryFocusType: "linear"
                property int gradTertiaryFocusAngle: 0
                property real gradTertiaryFocusCenterX: 0.5
                property real gradTertiaryFocusCenterY: 0.5
                property real gradTertiaryFocusHalftoneDotMin: 2.0
                property real gradTertiaryFocusHalftoneDotMax: 8.0
                property real gradTertiaryFocusHalftoneStart: 0.0
                property real gradTertiaryFocusHalftoneEnd: 1.0
                property string gradTertiaryFocusHalftoneDotColor: "tertiary"
                property string gradTertiaryFocusHalftoneBackgroundColor: "overBackground"
                property list<var> gradOverTertiary: [["overTertiary", 0.0]]
                property string gradOverTertiaryType: "linear"
                property int gradOverTertiaryAngle: 0
                property real gradOverTertiaryCenterX: 0.5
                property real gradOverTertiaryCenterY: 0.5
                property real gradOverTertiaryHalftoneDotMin: 2.0
                property real gradOverTertiaryHalftoneDotMax: 8.0
                property real gradOverTertiaryHalftoneStart: 0.0
                property real gradOverTertiaryHalftoneEnd: 1.0
                property string gradOverTertiaryHalftoneDotColor: "tertiary"
                property string gradOverTertiaryHalftoneBackgroundColor: "overTertiary"
                property list<var> gradError: [["error", 0.0]]
                property string gradErrorType: "linear"
                property int gradErrorAngle: 0
                property real gradErrorCenterX: 0.5
                property real gradErrorCenterY: 0.5
                property real gradErrorHalftoneDotMin: 2.0
                property real gradErrorHalftoneDotMax: 8.0
                property real gradErrorHalftoneStart: 0.0
                property real gradErrorHalftoneEnd: 1.0
                property string gradErrorHalftoneDotColor: "overError"
                property string gradErrorHalftoneBackgroundColor: "error"
                property list<var> gradErrorFocus: [["overBackground", 0.0]]
                property string gradErrorFocusType: "linear"
                property int gradErrorFocusAngle: 0
                property real gradErrorFocusCenterX: 0.5
                property real gradErrorFocusCenterY: 0.5
                property real gradErrorFocusHalftoneDotMin: 2.0
                property real gradErrorFocusHalftoneDotMax: 8.0
                property real gradErrorFocusHalftoneStart: 0.0
                property real gradErrorFocusHalftoneEnd: 1.0
                property string gradErrorFocusHalftoneDotColor: "error"
                property string gradErrorFocusHalftoneBackgroundColor: "overBackground"
                property list<var> gradOverError: [["overError", 0.0]]
                property string gradOverErrorType: "linear"
                property int gradOverErrorAngle: 0
                property real gradOverErrorCenterX: 0.5
                property real gradOverErrorCenterY: 0.5
                property real gradOverErrorHalftoneDotMin: 2.0
                property real gradOverErrorHalftoneDotMax: 8.0
                property real gradOverErrorHalftoneStart: 0.0
                property real gradOverErrorHalftoneEnd: 1.0
                property string gradOverErrorHalftoneDotColor: "error"
                property string gradOverErrorHalftoneBackgroundColor: "overError"

                // Border configurations [color, width]
                property list<var> borderBg: ["surfaceBright", 0]
                property list<var> borderPane: ["surfaceBright", 0]
                property list<var> borderCommon: ["surfaceBright", 0]
                property list<var> borderFocus: ["surfaceBright", 0]
                property list<var> borderPrimary: ["primary", 0]
                property list<var> borderPrimaryFocus: ["overBackground", 0]
                property list<var> borderOverPrimary: ["overPrimary", 0]
                property list<var> borderSecondary: ["secondary", 0]
                property list<var> borderSecondaryFocus: ["overBackground", 0]
                property list<var> borderOverSecondary: ["overSecondary", 0]
                property list<var> borderTertiary: ["tertiary", 0]
                property list<var> borderTertiaryFocus: ["overBackground", 0]
                property list<var> borderOverTertiary: ["overTertiary", 0]
                property list<var> borderError: ["error", 0]
                property list<var> borderErrorFocus: ["overBackground", 0]
                property list<var> borderOverError: ["overError", 0]

                // Item color configurations
                property string itemBg: "overBackground"
                property string itemPane: "overBackground"
                property string itemCommon: "overBackground"
                property string itemFocus: "overBackground"
                property string itemPrimary: "overPrimary"
                property string itemPrimaryFocus: "overPrimary"
                property string itemOverPrimary: "primary"
                property string itemSecondary: "overSecondary"
                property string itemSecondaryFocus: "overSecondary"
                property string itemOverSecondary: "secondary"
                property string itemTertiary: "overTertiary"
                property string itemTertiaryFocus: "overTertiary"
                property string itemOverTertiary: "tertiary"
                property string itemError: "overError"
                property string itemErrorFocus: "overError"
                property string itemOverError: "error"
            }

            property JsonObject bar: JsonObject {
                property string position: "top"
                property string launcherIcon: ""
                property bool launcherIconTint: true
                property bool launcherIconFullTint: true
                property int launcherIconSize: 24
                property bool showBackground: false
                property real bgOpacity: 0.5
                property bool verbose: true
                property list<string> screenList: []
                property bool enableFirefoxPlayer: false
                property list<var> barColor: [["surface", 0.0]]
                property string barOrientation: "vertical"
            }

            property JsonObject workspaces: JsonObject {
                property int shown: 10
                property bool showAppIcons: true
                property bool alwaysShowNumbers: false
                property bool showNumbers: false
                property bool dynamic: false
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
                property list<string> activeBorderColor: ["primary"]
                property int borderAngle: 45
                property list<string> inactiveBorderColor: ["surface"]
                property int inactiveBorderAngle: 45
                property int borderSize: 2
                property int rounding: 16
                property bool syncRoundness: true
                property bool syncBorderWidth: false
                property bool syncBorderColor: false
                property bool syncShadowOpacity: false
                property bool syncShadowColor: false
                property int gapsIn: 2
                property int gapsOut: 4
                property string layout: "dwindle"
                property bool shadowEnabled: true
                property int shadowRange: 8
                property int shadowRenderPower: 3
                property bool shadowSharp: false
                property bool shadowIgnoreWindow: true
                property string shadowColor: "shadow"
                property string shadowColorInactive: "shadow"
                property real shadowOpacity: 0.5
                property string shadowOffset: "0 0"
                property real shadowScale: 1.0
                property bool blurEnabled: true
                property int blurSize: 4
                property int blurPasses: 2
                property bool blurIgnoreOpacity: true
                property bool blurNewOptimizations: true
                property bool blurXray: false
                property real blurNoise: 0.0
                property real blurContrast: 1.0
                property real blurBrightness: 1.0
                property real blurVibrancy: 0.0
                property real blurVibrancyDarkness: 0.0
                property bool blurSpecial: true
                property bool blurPopups: false
                property real blurPopupsIgnorealpha: 0.2
                property bool blurInputMethods: false
                property real blurInputMethodsIgnorealpha: 0.2
            }

            property JsonObject performance: JsonObject {
                property bool blurTransition: true
                property bool windowPreview: true
                property bool wavyLine: true
            }

            property JsonObject weather: JsonObject {
                property string location: ""
                property string unit: "C"
            }

            property JsonObject desktop: JsonObject {
                property bool enabled: false
                property int iconSize: 40
                property int spacingVertical: 16
                property string textColor: "overBackground"
            }

            property JsonObject lockscreen: JsonObject {
                property string position: "bottom"
            }

            property JsonObject prefix: JsonObject {
                property string clipboard: "clp"
                property string emoji: "emo"
                property string tmux: "tmx"
                property string wallpapers: "wpp"
            }
        }
    }

    FileView {
        id: keybindsLoader
        path: keybindsPath
        atomicWrites: true
        watchChanges: true
        onFileChanged: reload()
        onPathChanged: reload()
        onAdapterUpdated: {
            if (root.keybindsInitialLoadComplete) {
                keybindsLoader.writeAdapter();
            }
        }

        adapter: JsonAdapter {
            property JsonObject ambxst: JsonObject {
                property JsonObject dashboard: JsonObject {
                    property JsonObject widgets: JsonObject {
                        property list<string> modifiers: ["SUPER"]
                        property string key: "R"
                        property string dispatcher: "global"
                        property string argument: "ambxst:dashboard-widgets"
                    }
                    property JsonObject clipboard: JsonObject {
                        property list<string> modifiers: ["SUPER"]
                        property string key: "V"
                        property string dispatcher: "global"
                        property string argument: "ambxst:dashboard-clipboard"
                    }
                    property JsonObject emoji: JsonObject {
                        property list<string> modifiers: ["SUPER"]
                        property string key: "PERIOD"
                        property string dispatcher: "global"
                        property string argument: "ambxst:dashboard-emoji"
                    }
                    property JsonObject tmux: JsonObject {
                        property list<string> modifiers: ["SUPER"]
                        property string key: "T"
                        property string dispatcher: "global"
                        property string argument: "ambxst:dashboard-tmux"
                    }
                    property JsonObject kanban: JsonObject {
                        property list<string> modifiers: ["SUPER"]
                        property string key: "N"
                        property string dispatcher: "global"
                        property string argument: "ambxst:dashboard-kanban"
                    }
                    property JsonObject wallpapers: JsonObject {
                        property list<string> modifiers: ["SUPER"]
                        property string key: "COMMA"
                        property string dispatcher: "global"
                        property string argument: "ambxst:dashboard-wallpapers"
                    }
                    property JsonObject assistant: JsonObject {
                        property list<string> modifiers: ["SUPER"]
                        property string key: "A"
                        property string dispatcher: "global"
                        property string argument: "ambxst:dashboard-assistant"
                    }
                }
                property JsonObject system: JsonObject {
                    property JsonObject overview: JsonObject {
                        property list<string> modifiers: ["SUPER"]
                        property string key: "TAB"
                        property string dispatcher: "global"
                        property string argument: "ambxst:overview"
                    }
                    property JsonObject powermenu: JsonObject {
                        property list<string> modifiers: ["SUPER"]
                        property string key: "ESCAPE"
                        property string dispatcher: "global"
                        property string argument: "ambxst:powermenu"
                    }
                    property JsonObject config: JsonObject {
                        property list<string> modifiers: ["SUPER", "SHIFT"]
                        property string key: "C"
                        property string dispatcher: "global"
                        property string argument: "ambxst:config"
                    }
                    property JsonObject lockscreen: JsonObject {
                        property list<string> modifiers: ["SUPER"]
                        property string key: "L"
                        property string dispatcher: "global"
                        property string argument: "ambxst:lockscreen"
                    }
                }
            }
            property list<var> custom: [
                // Window management
                {
                    "modifiers": ["SUPER"],
                    "key": "C",
                    "dispatcher": "killactive",
                    "argument": "",
                    "enabled": true
                },

                // Switch workspaces with SUPER + [0-9]
                {
                    "modifiers": ["SUPER"],
                    "key": "1",
                    "dispatcher": "workspace",
                    "argument": "1",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER"],
                    "key": "2",
                    "dispatcher": "workspace",
                    "argument": "2",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER"],
                    "key": "3",
                    "dispatcher": "workspace",
                    "argument": "3",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER"],
                    "key": "4",
                    "dispatcher": "workspace",
                    "argument": "4",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER"],
                    "key": "5",
                    "dispatcher": "workspace",
                    "argument": "5",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER"],
                    "key": "6",
                    "dispatcher": "workspace",
                    "argument": "6",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER"],
                    "key": "7",
                    "dispatcher": "workspace",
                    "argument": "7",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER"],
                    "key": "8",
                    "dispatcher": "workspace",
                    "argument": "8",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER"],
                    "key": "9",
                    "dispatcher": "workspace",
                    "argument": "9",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER"],
                    "key": "0",
                    "dispatcher": "workspace",
                    "argument": "10",
                    "enabled": true
                },

                // Move active window to workspace with SUPER + SHIFT + [0-9]
                {
                    "modifiers": ["SUPER", "SHIFT"],
                    "key": "1",
                    "dispatcher": "movetoworkspace",
                    "argument": "1",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER", "SHIFT"],
                    "key": "2",
                    "dispatcher": "movetoworkspace",
                    "argument": "2",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER", "SHIFT"],
                    "key": "3",
                    "dispatcher": "movetoworkspace",
                    "argument": "3",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER", "SHIFT"],
                    "key": "4",
                    "dispatcher": "movetoworkspace",
                    "argument": "4",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER", "SHIFT"],
                    "key": "5",
                    "dispatcher": "movetoworkspace",
                    "argument": "5",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER", "SHIFT"],
                    "key": "6",
                    "dispatcher": "movetoworkspace",
                    "argument": "6",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER", "SHIFT"],
                    "key": "7",
                    "dispatcher": "movetoworkspace",
                    "argument": "7",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER", "SHIFT"],
                    "key": "8",
                    "dispatcher": "movetoworkspace",
                    "argument": "8",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER", "SHIFT"],
                    "key": "9",
                    "dispatcher": "movetoworkspace",
                    "argument": "9",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER", "SHIFT"],
                    "key": "0",
                    "dispatcher": "movetoworkspace",
                    "argument": "10",
                    "enabled": true
                },

                // Scroll through workspaces
                {
                    "modifiers": ["SUPER"],
                    "key": "mouse_down",
                    "dispatcher": "workspace",
                    "argument": "e-1",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER", "SHIFT"],
                    "key": "Z",
                    "dispatcher": "workspace",
                    "argument": "e-1",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER"],
                    "key": "mouse_up",
                    "dispatcher": "workspace",
                    "argument": "e+1",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER", "SHIFT"],
                    "key": "X",
                    "dispatcher": "workspace",
                    "argument": "e+1",
                    "enabled": true
                },

                // Next/previous workspace with Z and X
                {
                    "modifiers": ["SUPER"],
                    "key": "Z",
                    "dispatcher": "workspace",
                    "argument": "-1",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER"],
                    "key": "X",
                    "dispatcher": "workspace",
                    "argument": "+1",
                    "enabled": true
                },

                // Move/resize windows with mouse
                {
                    "modifiers": ["SUPER"],
                    "key": "mouse:272",
                    "dispatcher": "movewindow",
                    "argument": "",
                    "flags": "m",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER"],
                    "key": "mouse:273",
                    "dispatcher": "resizewindow",
                    "argument": "",
                    "flags": "m",
                    "enabled": true
                },

                // Media player controls
                {
                    "modifiers": [],
                    "key": "XF86AudioPlay",
                    "dispatcher": "exec",
                    "argument": "playerctl play-pause",
                    "enabled": true
                },
                {
                    "modifiers": [],
                    "key": "XF86AudioPrev",
                    "dispatcher": "exec",
                    "argument": "playerctl previous",
                    "enabled": true
                },
                {
                    "modifiers": [],
                    "key": "XF86AudioNext",
                    "dispatcher": "exec",
                    "argument": "playerctl next",
                    "enabled": true
                },
                {
                    "modifiers": [],
                    "key": "XF86AudioMedia",
                    "dispatcher": "exec",
                    "argument": "playerctl play-pause",
                    "flags": "l",
                    "enabled": true
                },
                {
                    "modifiers": [],
                    "key": "XF86AudioStop",
                    "dispatcher": "exec",
                    "argument": "playerctl stop",
                    "flags": "l",
                    "enabled": true
                },

                // Volume controls
                {
                    "modifiers": [],
                    "key": "XF86AudioRaiseVolume",
                    "dispatcher": "exec",
                    "argument": "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%+",
                    "flags": "le",
                    "enabled": true
                },
                {
                    "modifiers": [],
                    "key": "XF86AudioLowerVolume",
                    "dispatcher": "exec",
                    "argument": "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%-",
                    "flags": "le",
                    "enabled": true
                },
                {
                    "modifiers": [],
                    "key": "XF86AudioMute",
                    "dispatcher": "exec",
                    "argument": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
                    "flags": "le",
                    "enabled": true
                },

                // Brightness controls
                {
                    "modifiers": [],
                    "key": "XF86MonBrightnessUp",
                    "dispatcher": "exec",
                    "argument": "swayosd-client --brightness=raise 5",
                    "flags": "le",
                    "enabled": true
                },
                {
                    "modifiers": [],
                    "key": "XF86MonBrightnessDown",
                    "dispatcher": "exec",
                    "argument": "swayosd-client --brightness=lower 5",
                    "flags": "le",
                    "enabled": true
                },

                // Calculator key
                {
                    "modifiers": [],
                    "key": "XF86Calculator",
                    "dispatcher": "exec",
                    "argument": "notify-send \"Soon\"",
                    "enabled": true
                },

                // Special workspaces
                {
                    "modifiers": ["SUPER", "SHIFT"],
                    "key": "V",
                    "dispatcher": "togglespecialworkspace",
                    "argument": "",
                    "enabled": true
                },
                {
                    "modifiers": ["SUPER", "ALT"],
                    "key": "V",
                    "dispatcher": "movetoworkspace",
                    "argument": "special",
                    "enabled": true
                },

                // Lid switch events
                {
                    "modifiers": [],
                    "key": "switch:Lid Switch",
                    "dispatcher": "exec",
                    "argument": "loginctl lock-session",
                    "flags": "l",
                    "enabled": true
                },
                {
                    "modifiers": [],
                    "key": "switch:on:Lid Switch",
                    "dispatcher": "exec",
                    "argument": "hyprctl dispatch dpms off",
                    "flags": "l",
                    "enabled": true
                },
                {
                    "modifiers": [],
                    "key": "switch:off:Lid Switch",
                    "dispatcher": "exec",
                    "argument": "hyprctl dispatch dpms on",
                    "flags": "l",
                    "enabled": true
                }
            ]
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
    property int animDuration: Services.GameModeService.toggled ? 0 : theme.animDuration
    property bool tintIcons: theme.tintIcons

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
    property string notchTheme: notch.theme

    // Hyprland configuration
    property QtObject hyprland: loader.adapter.hyprland
    property int hyprlandRounding: hyprland.syncRoundness ? Math.max(0, roundness - (hyprland.gapsOut - hyprlandBorderSize)) : Math.max(0, hyprland.rounding - hyprlandBorderSize)
    property int hyprlandBorderSize: hyprland.syncBorderWidth ? theme.borderSize : hyprland.borderSize
    property string hyprlandBorderColor: hyprland.syncBorderColor ? theme.borderColor : (hyprland.activeBorderColor.length > 0 ? hyprland.activeBorderColor[0] : "primary")
    property real hyprlandShadowOpacity: hyprland.syncShadowOpacity ? theme.shadowOpacity : hyprland.shadowOpacity
    property string hyprlandShadowColor: hyprland.syncShadowColor ? theme.shadowColor : hyprland.shadowColor

    // Performance configuration
    property QtObject performance: loader.adapter.performance
    property bool blurTransition: performance.blurTransition

    // Weather configuration
    property QtObject weather: loader.adapter.weather

    // Desktop configuration
    property QtObject desktop: loader.adapter.desktop

    // Lockscreen configuration
    property QtObject lockscreen: loader.adapter.lockscreen

    // Prefix configuration
    property QtObject prefix: loader.adapter.prefix

    // Helper functions for color handling (HEX or named colors)
    function isHexColor(colorValue) {
        if (typeof colorValue !== 'string')
            return false;
        const normalized = colorValue.toLowerCase().trim();
        return normalized.startsWith('#') || normalized.startsWith('rgb');
    }

    function resolveColor(colorValue) {
        if (isHexColor(colorValue)) {
            return colorValue;
        }
        return Colors[colorValue] || Colors.primary;
    }

    function resolveColorWithOpacity(colorValue, opacity) {
        const color = isHexColor(colorValue) ? Qt.color(colorValue) : (Colors[colorValue] || Colors.primary);
        return Qt.rgba(color.r, color.g, color.b, opacity);
    }
}
