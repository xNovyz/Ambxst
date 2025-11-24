import QtQuick
import Quickshell.Widgets
import qs.modules.theme
import qs.config
import qs.modules.components

Rectangle {
    id: root
    radius: Config.roundness
    border.color: Config.resolveColor(Config.theme.borderColor)
    border.width: Config.theme.borderSize

    gradient: Gradient {
        orientation: Config.theme.bgOrientation === "horizontal" ? Gradient.Horizontal : Gradient.Vertical

        GradientStop {
            property var stopData: Config.theme.bgColor[0] || ["background", 0.0]
            position: stopData[1]
            color: Config.resolveColor(stopData[0])
        }

        GradientStop {
            property var stopData: Config.theme.bgColor[1] || Config.theme.bgColor[Config.theme.bgColor.length - 1]
            position: stopData[1]
            color: Config.resolveColor(stopData[0])
        }

        GradientStop {
            property var stopData: Config.theme.bgColor[2] || Config.theme.bgColor[Config.theme.bgColor.length - 1]
            position: stopData[1]
            color: Config.resolveColor(stopData[0])
        }

        GradientStop {
            property var stopData: Config.theme.bgColor[3] || Config.theme.bgColor[Config.theme.bgColor.length - 1]
            position: stopData[1]
            color: Config.resolveColor(stopData[0])
        }

        GradientStop {
            property var stopData: Config.theme.bgColor[4] || Config.theme.bgColor[Config.theme.bgColor.length - 1]
            position: stopData[1]
            color: Config.resolveColor(stopData[0])
        }
    }

    // Shadow is now controlled externally via layer.enabled property
    layer.effect: Shadow {}
}
