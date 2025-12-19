import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.modules.globals
import qs.modules.theme
import qs.modules.services
import qs.modules.components
import qs.config
import "."

PanelWindow {
    id: overviewPopup

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    // Get this screen's visibility state
    readonly property var screenVisibilities: Visibilities.getForScreen(screen.name)
    readonly property bool overviewOpen: screenVisibilities ? screenVisibilities.overview : false

    visible: overviewOpen
    exclusionMode: ExclusionMode.Ignore

    // Mask to capture input on the entire window when open
    mask: Region {
        item: overviewOpen ? fullMask : emptyMask
    }

    // Full screen mask when open
    Item {
        id: fullMask
        anchors.fill: parent
    }

    // Empty mask when hidden
    Item {
        id: emptyMask
        width: 0
        height: 0
    }

    HyprlandFocusGrab {
        id: focusGrab
        windows: [overviewPopup]
        active: overviewOpen

        onCleared: {
            // Use Qt.callLater to avoid potential race conditions
            Qt.callLater(() => {
                if (overviewOpen) {
                    Visibilities.setActiveModule("");
                }
            });
        }
    }

    // Semi-transparent backdrop
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Colors.scrim
        opacity: overviewOpen ? 0.5 : 0

        Behavior on opacity {
            enabled: Config.animDuration > 0
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutQuart
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                Visibilities.setActiveModule("");
            }
        }
    }

    // Overview container
    Item {
        id: overviewContainer
        anchors.centerIn: parent
        width: overviewLoader.item ? overviewLoader.item.implicitWidth + 48 : 400
        height: overviewLoader.item ? overviewLoader.item.implicitHeight + 48 : 300

        // Background panel
        StyledRect {
            id: overviewBackground
            variant: "bg"
            anchors.fill: parent
            radius: Styling.radius(20)

            layer.enabled: true
            layer.effect: Shadow {}
        }

        // Scale and opacity animation
        opacity: overviewOpen ? 1 : 0
        scale: overviewOpen ? 1 : 0.9

        Behavior on opacity {
            enabled: Config.animDuration > 0
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutQuart
            }
        }

        Behavior on scale {
            enabled: Config.animDuration > 0
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }
        }

        // Loader for Overview to prevent issues during destruction
        Loader {
            id: overviewLoader
            anchors.centerIn: parent
            active: overviewOpen
            
            sourceComponent: Overview {
                currentScreen: overviewPopup.screen

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        Visibilities.setActiveModule("");
                        event.accepted = true;
                    }
                }

                Component.onCompleted: {
                    forceActiveFocus();
                }
            }
        }
    }

    // Ensure focus when overview opens
    onOverviewOpenChanged: {
        if (overviewOpen && overviewLoader.item) {
            Qt.callLater(() => {
                if (overviewLoader.item) {
                    overviewLoader.item.forceActiveFocus();
                }
            });
        }
    }
}
