import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../workspaces"
import "../theme"
import "../launcher"

PanelWindow {
    id: notchPanel

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    WlrLayershell.keyboardFocus: (GlobalStates.launcherOpen || GlobalStates.dashboardOpen) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    mask: Region {
        item: notchContainer
    }

    // Default view component - user@host text
    Component {
        id: defaultViewComponent
        Item {
            width: userHostText.implicitWidth + 24
            height: 28

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    GlobalStates.dashboardOpen = !GlobalStates.dashboardOpen;
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: parent.pressed ? Colors.surfaceContainerHighest : (parent.containsMouse ? Colors.surfaceContainerHigh : "transparent")

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }
            }

            Text {
                id: userHostText
                anchors.centerIn: parent
                text: `${Quickshell.env("USER")}@${Quickshell.env("HOSTNAME")}`
                color: Colors.foreground
                font.family: Styling.defaultFont
                font.pixelSize: 14
                font.weight: Font.Bold
            }
        }
    }

    // Launcher view component
    Component {
        id: launcherViewComponent
        Item {
            width: 440
            height: Math.min(launcherSearch.implicitHeight, 400)

            LauncherSearch {
                id: launcherSearch
                anchors.fill: parent

                onItemSelected: {
                    GlobalStates.launcherOpen = false;
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        GlobalStates.launcherOpen = false;
                        event.accepted = true;
                    }
                }

                Component.onCompleted: {
                    clearSearch();
                    Qt.callLater(() => {
                        forceActiveFocus();
                    });
                }
            }
        }
    }

    // Dashboard view component
    Component {
        id: dashboardViewComponent
        Item {
            width: 440
            height: Math.min(dashboardItem.implicitHeight, 500)

            Dashboard {
                id: dashboardItem
                anchors.fill: parent

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        GlobalStates.dashboardOpen = false;
                        event.accepted = true;
                    }
                }

                Component.onCompleted: {
                    Qt.callLater(() => {
                        forceActiveFocus();
                    });
                }
            }
        }
    }

    // Center notch
    Notch {
        id: notchContainer
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 0
            radius: GlobalStates.launcherOpen ? 16 : 8
            samples: GlobalStates.launcherOpen ? 32 : 16
            color: GlobalStates.launcherOpen ? Qt.rgba(Colors.shadow.r, Colors.shadow.g, Colors.shadow.b, 0.7) : Qt.rgba(Colors.shadow.r, Colors.shadow.g, Colors.shadow.b, 0.5)
            transparentBorder: true
        }

        defaultViewComponent: defaultViewComponent
        launcherViewComponent: launcherViewComponent
        dashboardViewComponent: dashboardViewComponent

        // Handle global keyboard events
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape && (GlobalStates.launcherOpen || GlobalStates.dashboardOpen)) {
                GlobalStates.launcherOpen = false;
                GlobalStates.dashboardOpen = false;
                event.accepted = true;
            }
        }
    }

    // Listen for launcher and dashboard state changes
    Connections {
        target: GlobalStates
        function onLauncherOpenChanged() {
            if (GlobalStates.launcherOpen) {
                notchContainer.stackView.push(launcherViewComponent);
                Qt.callLater(() => {
                    notchPanel.requestActivate();
                    notchPanel.forceActiveFocus();
                });
            } else {
                if (notchContainer.stackView.depth > 1) {
                    notchContainer.stackView.pop();
                }
            }
        }

        function onDashboardOpenChanged() {
            if (GlobalStates.dashboardOpen) {
                notchContainer.stackView.push(dashboardViewComponent);
                Qt.callLater(() => {
                    notchPanel.requestActivate();
                    notchPanel.forceActiveFocus();
                });
            } else {
                if (notchContainer.stackView.depth > 1) {
                    notchContainer.stackView.pop();
                }
            }
        }
    }
}
