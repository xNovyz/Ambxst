import QtQuick
import Qt5Compat.GraphicalEffects

Rectangle {
    color: Colors.surface
    radius: 16
    border.color: Colors.surfaceBright
    border.width: 0

    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 0
        radius: 8
        samples: 16
        color: "#88000000"
        transparentBorder: true
    }
}
