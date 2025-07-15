import QtQuick
import QtQuick.Layouts
import "../theme"

StyledContainer {
    id: clockContainer

    property string currentTime: ""
    radius: 16

    Layout.preferredWidth: timeDisplay.implicitWidth + 18
    Layout.preferredHeight: timeDisplay.implicitHeight + 18

    Text {
        id: timeDisplay
        anchors.centerIn: parent

        text: clockContainer.currentTime
        color: Colors.foreground
        font.pixelSize: 14
        font.family: "Iosevka Nerd Font"
        font.bold: true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date();
            clockContainer.currentTime = Qt.formatDateTime(now, "hh:mm:ss");
        }
    }
}
