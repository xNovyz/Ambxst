import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.theme
import qs.modules.components

StyledRect {
    id: clockContainer
    variant: "bg"

    property string currentTime: ""
    property string currentDayAbbrev: ""
    property string currentHours: ""
    property string currentMinutes: ""

    required property var bar
    property bool vertical: bar.orientation === "vertical"

    Layout.preferredWidth: vertical ? 36 : rowLayout.implicitWidth + 24
    implicitHeight: vertical ? columnLayout.implicitHeight + 24 : 36
    Layout.preferredHeight: implicitHeight

    RowLayout { // horizontal layout
        id: rowLayout
        visible: !vertical
        anchors.centerIn: parent
        spacing: 8

        Text {
            id: dayDisplay
            text: clockContainer.currentDayAbbrev
            color: Colors.overBackground
            font.pixelSize: Config.theme.fontSize
            font.family: Config.theme.font
            font.bold: true
        }

        Separator {
            id: separator
            vert: true
        }

        Text {
            id: timeDisplay
            text: clockContainer.currentTime
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
            id: dayDisplayV
            text: clockContainer.currentDayAbbrev
            color: Colors.overBackground
            font.pixelSize: Config.theme.fontSize
            font.family: Config.theme.font
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.NoWrap
            Layout.alignment: Qt.AlignHCenter
        }

        Separator {
            id: separatorV
            vert: true
            Layout.alignment: Qt.AlignHCenter
        }

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

    function scheduleNextDayUpdate() {
        var now = new Date();
        var next = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1, 0, 0, 1);
        var ms = next - now;
        dayUpdateTimer.interval = ms;
        dayUpdateTimer.start();
    }

    function updateDay() {
        var now = new Date();
        var day = Qt.formatDateTime(now, Qt.locale(), "ddd");
        clockContainer.currentDayAbbrev = day.slice(0, 3).charAt(0).toUpperCase() + day.slice(1, 3);
        scheduleNextDayUpdate();
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date();
            var formatted = Qt.formatDateTime(now, "hh:mm");
            var parts = formatted.split(":");
            clockContainer.currentTime = formatted;
            clockContainer.currentHours = parts[0];
            clockContainer.currentMinutes = parts[1];
        }
    }

    Timer {
        id: dayUpdateTimer
        repeat: false
        running: false
        onTriggered: updateDay()
    }

    Component.onCompleted: {
        var now = new Date();
        var formatted = Qt.formatDateTime(now, "hh:mm");
        var parts = formatted.split(":");
        clockContainer.currentTime = formatted;
        clockContainer.currentHours = parts[0];
        clockContainer.currentMinutes = parts[1];
        updateDay();
    }
}
