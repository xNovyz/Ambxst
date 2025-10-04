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

    // Determina la posición. Actualmente soporta "top" y "bottom".
    // Si se provee un valor no reconocido, se usa "top" por defecto para evitar estados inconsistentes.
    property string position: (Config.bar.position === "bottom" || Config.bar.position === "top") ? Config.bar.position : "top"

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

    Rectangle {
        id: bar
        anchors.left: parent.left
        anchors.right: parent.right
        // Control vertical manual para evitar efectos colaterales de anchors dinámicos.
        property int barHeight: 44
        height: Visibilities.contextMenuOpen ? Screen.height : barHeight
        y: panel.position === "top" ? 0 : parent.height - height
        color: "transparent"

        Rectangle {
            id: barBg
            anchors.fill: parent
            property color bgColor: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, Config.bar.bgOpacity)
            color: Config.bar.showBackground ? bgColor : "transparent"

            // Esquinas visibles hacia fuera de la barra. Para bottom se invierten a BottomLeft/BottomRight y se posicionan arriba de la barra.
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

        // Lado izquierdo de la barra
        RowLayout {
            id: barStart
            anchors.left: parent.left
            anchors.top: panel.position === "top" ? parent.top : undefined
            anchors.bottom: panel.position === "bottom" ? parent.bottom : undefined
            anchors.margins: 4
            spacing: 4

            LauncherButton {
                id: launcherButton
            }

            Workspaces {
                bar: QtObject {
                    property var screen: panel.screen
                }
            }

            OverviewButton {
                id: overviewButton
            }
        }

        // Lado derecho de la barra
        RowLayout {
            id: barEnd
            anchors.right: parent.right
            anchors.top: panel.position === "top" ? parent.top : undefined
            anchors.bottom: panel.position === "bottom" ? parent.bottom : undefined
            anchors.margins: 4
            spacing: 4

            SysTray {
                bar: panel
            }

            Clock {
                id: clockComponent
            }

            PowerButton {
                id: powerButton
            }
        }
    }
}
