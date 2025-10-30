import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
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
import qs.modules.bar
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

        layer.enabled: true
        layer.effect: Shadow {}

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
                    height: 44
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
                    height: 44
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
                    width: 44
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
                    width: 44
                    height: undefined
                }
            }
        ]

        BarBg {
            id: barBg
            anchors.fill: parent
            position: panel.position
        }

        RowLayout {
            id: horizontalLayout
            visible: panel.orientation === "horizontal"
            anchors.fill: parent
            anchors.margins: 4
            spacing: 4

            LauncherButton {
                id: launcherButton
            }

            ClippingRectangle {
                id: leftRect
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                color: "transparent"
                radius: Config.roundness
                layer.enabled: Config.bar.showBackground
                layer.effect: Shadow {}

                Flickable {
                    width: parent.width
                    height: parent.height
                    anchors.left: parent.left
                    contentWidth: leftContent.width
                    contentHeight: 36
                    flickableDirection: Flickable.HorizontalFlick

                    RowLayout {
                        id: leftContent
                        spacing: 4

                        RowLayout {
                            id: leftWidgets
                            spacing: 4

                            Workspaces {
                                orientation: panel.orientation
                                bar: QtObject {
                                    property var screen: panel.screen
                                }
                            }
                            OverviewButton {
                                id: overviewButton
                            }
                        }

                        Item {
                            Layout.preferredWidth: leftRect.width - leftWidgets.width - 4
                        }
                    }
                }
            }

            ClippingRectangle {
                id: rightRect
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                Layout.alignment: Qt.AlignRight
                color: "transparent"
                radius: Config.roundness
                layer.enabled: Config.bar.showBackground
                layer.effect: Shadow {}

                Flickable {
                    width: parent.width
                    height: parent.height
                    anchors.right: parent.right
                    contentWidth: rightContent.width
                    contentHeight: 36
                    contentX: rightContent.width
                    flickableDirection: Flickable.HorizontalFlick

                    RowLayout {
                        id: rightContent
                        spacing: 4

                        Item {
                            Layout.preferredWidth: rightRect.width - rightWidgets.width - 4
                        }

                        RowLayout {
                            id: rightWidgets
                            spacing: 4

                            MicSlider {
                                bar: panel
                                layerEnabled: Config.bar.showBackground
                            }

                            VolumeSlider {
                                id: volume
                                bar: panel
                                layerEnabled: Config.bar.showBackground
                            }

                            BrightnessSlider {
                                bar: panel
                                layerEnabled: Config.bar.showBackground
                            }

                            SysTray {
                                bar: panel
                                layer.enabled: false
                            }

                            Weather {
                                id: weatherComponent
                                bar: panel
                                layer.enabled: false
                            }

                            Clock {
                                id: clockComponent
                                bar: panel
                                layer.enabled: false
                            }
                        }
                    }
                }
            }

            PowerButton {
                id: powerButton
            }
        }

        ColumnLayout {
            id: verticalLayout
            visible: panel.orientation === "vertical"
            anchors.fill: parent
            anchors.margins: 4
            spacing: 4

            LauncherButton {
                id: launcherButtonVert
                Layout.preferredHeight: 36
            }

            ClippingRectangle {
                id: topRect
                Layout.fillHeight: true
                Layout.preferredWidth: 36
                color: "transparent"
                radius: Config.roundness
                layer.enabled: Config.bar.showBackground
                layer.effect: Shadow {}

                Flickable {
                    width: parent.width
                    height: parent.height
                    anchors.top: parent.top
                    contentWidth: 36
                    contentHeight: topContent.height
                    flickableDirection: Flickable.VerticalFlick

                    ColumnLayout {
                        id: topContent
                        spacing: 4

                        ColumnLayout {
                            id: topWidgets
                            spacing: 4

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

                        Item {
                            Layout.preferredHeight: topRect.height - topWidgets.height - 4
                        }
                    }
                }
            }

            ClippingRectangle {
                id: bottomRect
                Layout.fillHeight: true
                Layout.preferredWidth: 36
                color: "transparent"
                radius: Config.roundness
                layer.enabled: Config.bar.showBackground
                layer.effect: Shadow {}

                Flickable {
                    width: parent.width
                    height: parent.height
                    anchors.bottom: parent.bottom
                    contentWidth: 36
                    contentHeight: bottomContent.height
                    contentY: bottomContent.height
                    flickableDirection: Flickable.VerticalFlick

                    ColumnLayout {
                        id: bottomContent
                        spacing: 4

                        Item {
                            Layout.preferredHeight: bottomRect.height - bottomWidgets.height - 4
                        }

                        ColumnLayout {
                            id: bottomWidgets
                            spacing: 4

                            MicSlider {
                                bar: panel
                                layerEnabled: Config.bar.showBackground
                            }

                            VolumeSlider {
                                bar: panel
                                layerEnabled: Config.bar.showBackground
                            }

                            BrightnessSlider {
                                bar: panel
                                layerEnabled: Config.bar.showBackground
                            }

                            SysTray {
                                bar: panel
                                layer.enabled: false
                            }

                            Weather {
                                id: weatherComponentVert
                                bar: panel
                                layer.enabled: false
                            }

                            Clock {
                                id: clockComponentVert
                                bar: panel
                                layer.enabled: false
                            }
                        }
                    }
                }
            }

            PowerButton {
                id: powerButtonVert
                Layout.preferredHeight: 36
            }
        }
    }
}
