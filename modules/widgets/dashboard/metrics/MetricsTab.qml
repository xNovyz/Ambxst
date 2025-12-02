pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.modules.theme
import qs.modules.components
import qs.modules.services
import qs.config

Rectangle {
    id: root
    color: "transparent"
    implicitWidth: 400
    implicitHeight: 400

    property string hostname: ""

    // Load refresh interval from state
    Component.onCompleted: {
        const savedInterval = StateService.get("metricsRefreshInterval", 2000);
        SystemResources.updateInterval = Math.max(100, savedInterval);
        hostnameReader.running = true;
    }

    // Get hostname
    Process {
        id: hostnameReader
        running: false
        command: ["hostname"]

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const host = text.trim();
                if (host) {
                    root.hostname = host.charAt(0).toUpperCase() + host.slice(1);
                }
            }
        }
    }

    // Watch for history changes to repaint chart
    Connections {
        target: SystemResources
        function onCpuHistoryChanged() {
            chartCanvas.requestPaint();
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 8

        // Left panel - Resources
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 250
            color: "transparent"
            radius: Styling.radius(4)

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                // User avatar
                Rectangle {
                    id: avatarContainer
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 8
                    width: 140
                    height: 140
                    radius: Config.roundness > 0 ? (height / 2) * (Config.roundness / 16) : 0
                    color: "transparent"

                    Image {
                        id: userAvatar
                        anchors.fill: parent
                        source: `file://${Quickshell.env("HOME")}/.face.icon`
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        asynchronous: true
                        visible: status === Image.Ready

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            maskEnabled: true
                            maskThresholdMin: 0.5
                            maskSpreadAtMin: 1.0
                            maskSource: ShaderEffectSource {
                                sourceItem: Rectangle {
                                    width: userAvatar.width
                                    height: userAvatar.height
                                    radius: Config.roundness > 0 ? (height / 2) * (Config.roundness / 16) : 0
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: Icons.user
                        font.family: Icons.font
                        font.pixelSize: 64
                        color: Colors.overSurfaceVariant
                        visible: userAvatar.status !== Image.Ready
                    }
                }

                // Username@Hostname
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 8
                    text: {
                        const user = Quickshell.env("USER") || "user";
                        return root.hostname ? `${user}@${root.hostname.toLowerCase()}` : user;
                    }
                    font.family: Config.theme.font
                    font.pixelSize: Config.theme.fontSize
                    font.weight: Font.Bold
                    color: Colors.overBackground
                    visible: text !== ""
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    contentHeight: resourcesColumn.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: resourcesColumn
                        width: parent.width
                        spacing: 12

                        // CPU
                        ResourceItem {
                            width: parent.width
                            icon: Icons.cpu
                            label: "CPU"
                            value: SystemResources.cpuUsage / 100
                            barColor: Colors.red
                        }

                        // RAM
                        ResourceItem {
                            width: parent.width
                            icon: Icons.ram
                            label: "RAM"
                            value: SystemResources.ramUsage / 100
                            barColor: Colors.blue
                        }

                        // GPU (if detected)
                        ResourceItem {
                            width: parent.width
                            visible: SystemResources.gpuDetected
                            icon: Icons.gpu
                            label: "GPU"
                            value: SystemResources.gpuUsage / 100
                            barColor: Colors.green
                        }

                        // Separator before disks
                        Separator {
                            width: parent.width
                            height: 2
                            gradient: null
                            color: Colors.surface
                        }

                        // Disks
                        Repeater {
                            id: diskRepeater
                            model: SystemResources.validDisks

                            Column {
                                required property string modelData
                                width: parent.width
                                spacing: 4

                                ResourceItem {
                                    width: parent.width
                                    icon: Icons.disk
                                    label: modelData
                                    value: SystemResources.diskUsage[modelData] ? SystemResources.diskUsage[modelData] / 100 : 0
                                    barColor: Colors.yellow
                                }

                                RowLayout {
                                    width: parent.width
                                    spacing: 8

                                    Text {
                                        text: modelData
                                        font.family: Config.theme.font
                                        font.pixelSize: Config.theme.fontSize - 2
                                        color: Colors.surfaceBright
                                        elide: Text.ElideMiddle
                                    }

                                    Separator {
                                        Layout.preferredHeight: 2
                                        Layout.fillWidth: true
                                        gradient: null
                                        color: Colors.surface
                                    }

                                    Text {
                                        text: `${Math.round((SystemResources.diskUsage[modelData] || 0))}%`
                                        font.family: Config.theme.font
                                        font.pixelSize: Math.max(8, Config.theme.fontSize - 2)
                                        font.weight: Font.Medium
                                        color: Colors.surfaceBright
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Right panel - Chart
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            StyledRect {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Styling.radius(4)
                variant: "pane"

                StyledRect {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: Styling.radius(0)
                    variant: "internalbg"

                    // Chart area
                    Canvas {
                        id: chartCanvas
                        anchors.fill: parent

                        onPaint: {
                            const ctx = getContext("2d");
                            const w = width;
                            const h = height;

                            // Clear canvas
                            ctx.clearRect(0, 0, w, h);

                            // Draw background grid (solid lines)
                            ctx.strokeStyle = Colors.surface;
                            ctx.lineWidth = 1;

                            // Horizontal grid lines (25%, 50%, 75%)
                            for (let i = 1; i < 8; i++) {
                                const y = h * (i / 8);
                                ctx.beginPath();
                                ctx.moveTo(0, y);
                                ctx.lineTo(w, y);
                                ctx.stroke();
                            }

                            // Vertical grid lines (every 10% of width)
                            const verticalLines = 10;
                            for (let i = 1; i < verticalLines; i++) {
                                const x = w * (i / verticalLines);
                                ctx.beginPath();
                                ctx.moveTo(x, 0);
                                ctx.lineTo(x, h);
                                ctx.stroke();
                            }

                            if (SystemResources.cpuHistory.length < 2)
                                return;

                            const pointSpacing = w / (SystemResources.maxHistoryPoints - 1);

                            // Helper function to draw a line chart
                            function drawLine(history, color) {
                                if (history.length < 2)
                                    return;

                                ctx.strokeStyle = color;
                                ctx.lineWidth = 2;
                                ctx.lineCap = "round";
                                ctx.lineJoin = "round";
                                ctx.beginPath();

                                const startIndex = Math.max(0, SystemResources.maxHistoryPoints - history.length);

                                for (let i = 0; i < history.length; i++) {
                                    const x = (startIndex + i) * pointSpacing;
                                    const y = h - (history[i] * h);

                                    if (i === 0) {
                                        ctx.moveTo(x, y);
                                    } else {
                                        ctx.lineTo(x, y);
                                    }
                                }

                                ctx.stroke();
                            }

                            // Draw CPU line (red)
                            drawLine(SystemResources.cpuHistory, Colors.red);

                            // Draw RAM line (blue)
                            drawLine(SystemResources.ramHistory, Colors.blue);

                            // Draw GPU line (green) if available
                            if (SystemResources.gpuDetected && SystemResources.gpuHistory.length > 0) {
                                drawLine(SystemResources.gpuHistory, Colors.green);
                            }
                        }
                    }
                }
            }

            // Controls panel
            StyledRect {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                radius: Styling.radius(4)
                variant: "pane"

                StyledRect {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: Styling.radius(0)
                    variant: "internalbg"

                    // Controls at right
                    RowLayout {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 4
                        spacing: 8

                        // Decrease interval button
                        StyledRect {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: Styling.radius(-4)
                            variant: "pane"

                            Text {
                                anchors.centerIn: parent
                                text: Icons.minus
                                font.family: Icons.font
                                font.pixelSize: 18
                                color: Colors.overBackground
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const newInterval = Math.max(100, SystemResources.updateInterval - 100);
                                    SystemResources.updateInterval = newInterval;
                                    StateService.set("metricsRefreshInterval", newInterval);
                                }
                            }

                            Behavior on color {
                                enabled: Config.animDuration > 0
                                ColorAnimation {
                                    duration: Config.animDuration
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        // Interval display
                        Text {
                            text: `${SystemResources.updateInterval}ms`
                            font.family: Config.theme.font
                            font.pixelSize: Config.theme.fontSize
                            font.weight: Font.Bold
                            color: Colors.overBackground
                        }

                        // Increase interval button
                        StyledRect {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: Styling.radius(-4)
                            variant: "pane"

                            Text {
                                anchors.centerIn: parent
                                text: Icons.plus
                                font.family: Icons.font
                                font.pixelSize: 18
                                color: Colors.overBackground
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const newInterval = SystemResources.updateInterval + 100;
                                    SystemResources.updateInterval = newInterval;
                                    StateService.set("metricsRefreshInterval", newInterval);
                                }
                            }

                            Behavior on color {
                                enabled: Config.animDuration > 0
                                ColorAnimation {
                                    duration: Config.animDuration
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
