import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.modules.bar.workspaces
import qs.modules.theme
import qs.modules.bar.clock
import qs.modules.bar.systray
import qs.modules.widgets.overview
import qs.modules.widgets.launcher
import qs.modules.widgets.powermenu
import qs.modules.corners
import qs.modules.components
import qs.modules.services
import qs.config

PanelWindow {
    id: panel

    property string position: ["top", "bottom", "left", "right"].includes(Config.bar.position) ? Config.bar.position : "top"
    property string orientation: position === "left" || position === "right" ? "vertical" : "horizontal"

    anchors {
        top: position !== "bottom"
        bottom: position !== "top"
        left: position !== "right"
        right: position !== "left"
    }

    color: "transparent"

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Top

    exclusiveZone: Config.bar.showBackground ? 44 : 40
    exclusionMode: ExclusionMode.Ignore

    // Altura implícita incluye espacio extra para animaciones / futuros elementos.
    implicitHeight: Screen.height

    // La máscara sigue a la barra principal para mantener correcta interacción en ambas posiciones.
    mask: Region {
        item: bar
    }

    Component.onCompleted: {
        Visibilities.registerBar(screen.name, bar);
        Visibilities.registerPanel(screen.name, panel);
    }

    Component.onDestruction: {
        Visibilities.unregisterBar(screen.name);
        Visibilities.unregisterPanel(screen.name);
    }

    Item {
        id: bar
        
        states: [
            State {
                name: "top"
                when: panel.position === "top"
                AnchorChanges {
                    target: bar
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: undefined
                }
                PropertyChanges {
                    target: bar
                    width: undefined
                    height: Visibilities.contextMenuOpen ? Screen.height : 44
                }
            },
            State {
                name: "bottom"
                when: panel.position === "bottom"
                AnchorChanges {
                    target: bar
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: undefined
                    anchors.bottom: parent.bottom
                }
                PropertyChanges {
                    target: bar
                    width: undefined
                    height: Visibilities.contextMenuOpen ? Screen.height : 44
                }
            },
            State {
                name: "left"
                when: panel.position === "left"
                AnchorChanges {
                    target: bar
                    anchors.left: parent.left
                    anchors.right: undefined
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                }
                PropertyChanges {
                    target: bar
                    width: Visibilities.contextMenuOpen ? Screen.width : 44
                    height: undefined
                }
            },
            State {
                name: "right"
                when: panel.position === "right"
                AnchorChanges {
                    target: bar
                    anchors.left: undefined
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                }
                PropertyChanges {
                    target: bar
                    width: Visibilities.contextMenuOpen ? Screen.width : 44
                    height: undefined
                }
            }
        ]

        Rectangle {
            id: barBg
            anchors.fill: parent
            property color bgColor: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, Config.bar.bgOpacity)
            color: Config.bar.showBackground ? bgColor : "transparent"

            RoundCorner {
                id: cornerLeft
                visible: Config.theme.enableCorners
                size: Config.roundness > 0 ? Config.roundness + 4 : 0
                x: 0
                y: panel.position === "top" ? parent.height : -size
                corner: panel.position === "top" ? RoundCorner.CornerEnum.TopLeft : RoundCorner.CornerEnum.BottomLeft
                color: parent.color
            }

            RoundCorner {
                id: cornerRight
                visible: Config.theme.enableCorners
                size: Config.roundness > 0 ? Config.roundness + 4 : 0
                x: parent.width - size
                y: panel.position === "top" ? parent.height : -size
                corner: panel.position === "top" ? RoundCorner.CornerEnum.TopRight : RoundCorner.CornerEnum.BottomRight
                color: parent.color
            }
        }

        Rectangle {
            id: barBgShadow
            anchors.fill: barBg
            color: Config.bar.showBackground ? "black" : "transparent"

            layer.enabled: true
            layer.smooth: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: barBgShadow
                maskInverted: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                shadowEnabled: true
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 0
                shadowBlur: 1
                shadowColor: Colors[Config.theme.shadowColor] || Colors.shadow
                shadowOpacity: Config.theme.shadowOpacity
            }

            RoundCorner {
                id: shadowCornerLeft
                visible: Config.theme.enableCorners
                size: Config.roundness > 0 ? Config.roundness + 4 : 0
                x: 0
                y: panel.position === "top" ? parent.height : -size
                corner: panel.position === "top" ? RoundCorner.CornerEnum.TopLeft : RoundCorner.CornerEnum.BottomLeft
                color: parent.color
            }

            RoundCorner {
                id: shadowCornerRight
                visible: Config.theme.enableCorners
                size: Config.roundness > 0 ? Config.roundness + 4 : 0
                x: parent.width - size
                y: panel.position === "top" ? parent.height : -size
                corner: panel.position === "top" ? RoundCorner.CornerEnum.TopRight : RoundCorner.CornerEnum.BottomRight
                color: parent.color
            }
        }

        RowLayout {
            id: horizontalLayout
            visible: panel.orientation === "horizontal"
            anchors.fill: parent
            anchors.margins: 4
            spacing: 4

            RowLayout {
                spacing: 4
                LauncherButton { id: launcherButton }
                Workspaces {
                    orientation: panel.orientation
                    bar: QtObject {
                        property var screen: panel.screen
                    }
                }
                OverviewButton { id: overviewButton }
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 4
                SysTray { bar: panel }
                Clock { id: clockComponent }
                PowerButton { id: powerButton }
            }
        }

        ColumnLayout {
            id: verticalLayout
            visible: panel.orientation === "vertical"
            anchors.fill: parent
            anchors.margins: 4
            spacing: 4

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                LauncherButton { 
                    id: launcherButtonVert
                    Layout.preferredHeight: 36
                }
                Workspaces {
                    orientation: panel.orientation
                    bar: QtObject {
                        property var screen: panel.screen
                    }
                }
                OverviewButton { 
                    id: overviewButtonVert
                    Layout.preferredHeight: 36
                }
            }

            Item { Layout.fillHeight: true }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                SysTray { 
                    bar: panel
                    Layout.preferredHeight: 36
                }
                Clock { 
                    id: clockComponentVert
                    Layout.preferredHeight: 36
                }
                PowerButton { 
                    id: powerButtonVert
                    Layout.preferredHeight: 36
                }
            }
        }
    }
}
