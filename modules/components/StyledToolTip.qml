pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config
import qs.modules.theme
import qs.modules.components

ToolTip {
    id: root
    property string tooltipText: ""
    property bool show: false

    text: tooltipText
    delay: 1000
    timeout: 5000
    visible: show && tooltipText.length > 0

    background: StyledRect {
        variant: "popup"
        radius: Styling.radius(-8)
    }
    contentItem: Text {
        text: root.tooltipText
        color: Colors.overBackground
        font.pixelSize: Config.theme.fontSize
        font.weight: Font.Bold
        font.family: Config.theme.font
    }
}
