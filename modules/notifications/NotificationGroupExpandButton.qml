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
        color: root.expanded ? Colors.primary : (root.pressed ? Colors.primary : (root.hovered ? Colors.surfaceBright : Colors.surfaceContainerHigh))
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
            color: root.expanded ? Colors.overPrimary : (root.pressed ? Colors.overPrimary : (root.hovered ? Colors.overBackground : Colors.primary))
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: 4
            rightPadding: 4
        }

        Text {
            text: root.expanded ? Icons.caretUp : Icons.caretDown
            textFormat: Text.RichText
            font.family: Icons.font
            font.pixelSize: Config.theme.fontSize
            color: root.expanded ? Colors.overPrimary : (root.pressed ? Colors.overPrimary : (root.hovered ? Colors.overBackground : Colors.primary))
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
