import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.theme
import qs.modules.components

BgRect {
    id: clockContainer

    // Time values
    property string currentHours: ""
    property string currentMinutes: ""

    required property var bar
    property bool vertical: bar.orientation === "vertical"

    Layout.preferredWidth: vertical ? 36 : (clockIndicator.implicitWidth + hoursDisplay.implicitWidth + minutesDisplay.implicitWidth + 36)
    implicitHeight: vertical ? columnLayout.implicitHeight + 24 : 36
    Layout.preferredHeight: implicitHeight

    RowLayout { // horizontal layout
        id: rowLayout
        visible: !vertical
        anchors.centerIn: parent
        spacing: 4

        Text {
            id: hoursDisplay
            text: clockContainer.currentHours
            color: Colors.overBackground
            font.pixelSize: Config.theme.fontSize
            font.family: Config.theme.font
            font.bold: true
        }

        Item {
            Layout.preferredWidth: clockIndicator.implicitWidth
            Layout.preferredHeight: hoursDisplay.height
            ClockIndicator {
                id: clockIndicator
                anchors.centerIn: parent
            }
        }

        Text {
            id: minutesDisplay
            text: clockContainer.currentMinutes
            color: Colors.overBackground
            font.pixelSize: Config.theme.fontSize
            font.family: Config.theme.font
            font.bold: true
        }
    }

    ColumnLayout { // vertical layout
        id: columnLayout
        visible: vertical
        anchors.centerIn: parent
        spacing: 4
        Layout.alignment: Qt.AlignHCenter

        Text {
            id: hoursDisplayV
            text: clockContainer.currentHours
            color: Colors.overBackground
            font.pixelSize: Config.theme.fontSize
            font.family: Config.theme.font
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.NoWrap
            Layout.alignment: Qt.AlignHCenter
        }

        ClockIndicator {
            id: clockIndicatorV
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            id: minutesDisplayV
            text: clockContainer.currentMinutes
            color: Colors.overBackground
            font.pixelSize: Config.theme.fontSize
            font.family: Config.theme.font
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.NoWrap
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date();
            var formatted = Qt.formatDateTime(now, "hh:mm");
            var parts = formatted.split(":");
            clockContainer.currentHours = parts[0];
            clockContainer.currentMinutes = parts[1];
        }
    }

    Component.onCompleted: {
        var now = new Date();
        var formatted = Qt.formatDateTime(now, "hh:mm");
        var parts = formatted.split(":");
        clockContainer.currentHours = parts[0];
        clockContainer.currentMinutes = parts[1];
    }
}
