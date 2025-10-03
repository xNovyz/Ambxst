import QtQuick
import qs.modules.theme
import qs.modules.services
import qs.config

Item {
    implicitWidth: 24
    implicitHeight: 24

    Item {
        anchors.centerIn: parent
        width: 24
        height: 24

        Text {
            anchors.centerIn: parent
            text: Notifications.list.length > 0 ? Icons.bellRinging : Icons.bell
            textFormat: Text.RichText
            font.family: Icons.font
            font.pixelSize: 20
            color: Notifications.list.length > 0 ? Colors.error : Colors.overBackground
        }
    }
}
