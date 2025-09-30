import QtQuick
import QtQuick.Controls
import qs.modules.theme
import qs.config

Button {
    id: root
    property int count: 1
    property bool expanded: false
    property real fontSize: Config.theme.fontSize

    visible: count > 1
    implicitWidth: contentRow.implicitWidth + 12
    implicitHeight: 24

    background: Rectangle {
        color: root.expanded ? Colors.adapter.primary : (root.pressed ? Colors.adapter.primary : (root.hovered ? Colors.surfaceBright : Colors.surfaceContainerHigh))
        radius: Config.roundness

        Behavior on color {
            ColorAnimation {
                duration: Config.animDuration / 4
            }
        }
    }

    contentItem: Row {
        id: contentRow
        spacing: 2
        anchors.centerIn: parent

        Text {
            text: root.count.toString()
            font.family: Config.theme.font
            font.pixelSize: Config.theme.fontSize
            font.weight: Font.Bold
            color: root.expanded ? Colors.adapter.overPrimary : (root.pressed ? Colors.adapter.overPrimary : (root.hovered ? Colors.adapter.overBackground : Colors.adapter.primary))
            verticalAlignment: Text.AlignVCenter
            leftPadding: 4
            rightPadding: 4
        }

        Text {
            text: root.expanded ? Icons.caretUp : Icons.caretDown
            font.family: Icons.font
            font.pixelSize: Config.theme.fontSize
            color: root.expanded ? Colors.adapter.overPrimary : (root.pressed ? Colors.adapter.overPrimary : (root.hovered ? Colors.adapter.overBackground : Colors.adapter.primary))
            verticalAlignment: Text.AlignVCenter
        }
    }
}
