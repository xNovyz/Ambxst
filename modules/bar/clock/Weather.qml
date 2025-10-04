import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.config
import qs.modules.theme
import qs.modules.components

BgRect {
    id: weatherContainer
    visible: weatherVisible

    // Day + weather raw values
    property string currentDayAbbrev: ""
    property string weatherSymbol: ""            // weather icon / emoji
    property string weatherTemp: ""              // temperature text

    property bool weatherVisible: false
    required property var bar
    property bool vertical: bar.orientation === "vertical"

    // Weather retry / backoff
    property int weatherRetryCount: 0
    property int weatherMaxRetries: 5

    Layout.preferredWidth: vertical ? 36 : (dayDisplay.implicitWidth + (weatherVisible ? separator.implicitWidth + symbolDisplay.implicitWidth + tempDisplay.implicitWidth + 16 : 0) + (weatherVisible ? 20 : 20))
    implicitHeight: vertical ? columnLayout.implicitHeight + 20 : 36
    Layout.preferredHeight: implicitHeight

    RowLayout { // horizontal layout
        id: rowLayout
        visible: !vertical
        anchors.centerIn: parent
        spacing: 4

        Text {
            id: dayDisplay
            text: weatherContainer.currentDayAbbrev
            color: Colors.overBackground
            font.pixelSize: Config.theme.fontSize
            font.family: Config.theme.font
            font.bold: true
        }

        Separator {
            id: separator
            visible: weatherContainer.weatherVisible
        }

        Text {
            id: symbolDisplay
            text: weatherContainer.weatherSymbol
            color: Colors.overBackground
            font.pixelSize: 16
            font.family: Config.theme.font
            font.bold: true
            visible: weatherContainer.weatherVisible
        }

        Text {
            id: tempDisplay
            text: weatherContainer.weatherTemp
            color: Colors.overBackground
            font.pixelSize: Config.theme.fontSize
            font.family: Config.theme.font
            font.bold: true
            visible: weatherContainer.weatherVisible
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
            text: weatherContainer.currentDayAbbrev
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
            visible: weatherContainer.weatherVisible
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            id: symbolDisplayV
            text: weatherContainer.weatherSymbol
            color: Colors.overBackground
            font.pixelSize: 16
            font.family: Config.theme.font
            font.bold: true
            visible: weatherContainer.weatherVisible
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.NoWrap
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            id: tempDisplayV
            text: weatherContainer.vertical && weatherContainer.weatherTemp.length > 0 ? weatherContainer.weatherTemp.slice(0, -1) : weatherContainer.weatherTemp
            color: Colors.overBackground
            font.pixelSize: Config.theme.fontSize
            font.family: Config.theme.font
            font.bold: true
            visible: weatherContainer.weatherVisible
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.NoWrap
            Layout.alignment: Qt.AlignHCenter
        }
    }

    function buildWeatherUrl() {
        var base = "wttr.in/";
        if (Config.weather.location.length > 0) {
            base += Config.weather.location;
        }
        base += "?format=%c+%t";
        if (Config.weather.unit === "C") {
            base += "&m";
        } else if (Config.weather.unit === "F") {
            base += "&u";
        }
        return base;
    }

    function scheduleNextDayUpdate() {
        var now = new Date();
        var next = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1, 0, 0, 1); // 1 second after midnight
        var ms = next - now;
        dayUpdateTimer.interval = ms;
        dayUpdateTimer.start();
    }

    function updateDay() {
        var now = new Date();
        var day = Qt.formatDateTime(now, Qt.locale(), "ddd");
        weatherContainer.currentDayAbbrev = day.slice(0, 3).charAt(0).toUpperCase() + day.slice(1, 3);
        scheduleNextDayUpdate();
    }

    function updateWeather() {
        weatherProcess.command = ["curl", buildWeatherUrl()];
        weatherProcess.running = true;
    }

    Process {
        id: weatherProcess
        running: false
        command: ["curl", buildWeatherUrl()]

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var raw = text.trim();
                if (raw.length > 0) {
                    // Expect format: <symbol> <temp>
                    var parts = raw.split(/ +/);
                    weatherContainer.weatherSymbol = parts.length > 0 ? parts[0] : "";
                    weatherContainer.weatherTemp = parts.length > 1 ? parts.slice(1).join(" ") : "";
                    weatherContainer.weatherVisible = true;
                    weatherContainer.weatherRetryCount = 0; // success resets retry count
                } else {
                    weatherContainer.weatherVisible = false;
                    if (weatherContainer.weatherRetryCount < weatherContainer.weatherMaxRetries) {
                        weatherContainer.weatherRetryCount++;
                        weatherRetryTimer.interval = Math.min(600000, 5000 * Math.pow(2, weatherContainer.weatherRetryCount - 1));
                        weatherRetryTimer.start();
                    }
                }
            }
        }

        onExited: function (code) {
            if (code !== 0) {
                console.log("Weather fetch failed");
                weatherContainer.weatherVisible = false;
                if (weatherContainer.weatherRetryCount < weatherContainer.weatherMaxRetries) {
                    weatherContainer.weatherRetryCount++;
                    weatherRetryTimer.interval = Math.min(600000, 5000 * Math.pow(2, weatherContainer.weatherRetryCount - 1));
                    weatherRetryTimer.start();
                }
            }
        }
    }

    Timer { // retry weather with exponential backoff on failure
        id: weatherRetryTimer
        repeat: false
        running: false
        onTriggered: updateWeather()
    }

    Timer {
        // periodic weather refresh (every 10 minutes)
        interval: 600000
        running: true
        repeat: true
        onTriggered: updateWeather()
    }

    Timer { // schedule-based day update (fires at next midnight + 1s)
        id: dayUpdateTimer
        repeat: false
        running: false
        onTriggered: updateDay()
    }

    Connections {
        target: Config.weather
        function onLocationChanged() {
            updateWeather();
        }
        function onUnitChanged() {
            updateWeather();
        }
    }

    Component.onCompleted: {
        updateWeather();
        updateDay();
    }
}
