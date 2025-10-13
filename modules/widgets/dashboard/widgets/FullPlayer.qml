import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.modules.theme
import qs.modules.components
import qs.modules.services
import qs.config

PaneRect {
    id: player

    height: MprisController.activePlayer ? layout.implicitHeight + layout.anchors.margins * 2 : 40

    property bool isPlaying: MprisController.activePlayer?.playbackState === MprisPlaybackState.Playing
    property real position: MprisController.activePlayer?.position ?? 0.0
    property real length: MprisController.activePlayer?.length ?? 1.0
    property bool hasArtwork: (MprisController.activePlayer?.trackArtUrl ?? "") !== ""
    property var playerColors: hasArtwork ? PlayerColors.getColorsForPlayer(MprisController.activePlayer) : null

    function formatTime(seconds) {
        const totalSeconds = Math.floor(seconds);
        const hours = Math.floor(totalSeconds / 3600);
        const minutes = Math.floor((totalSeconds % 3600) / 60);
        const secs = totalSeconds % 60;

        if (hours > 0) {
            return hours + ":" + (minutes < 10 ? "0" : "") + minutes + ":" + (secs < 10 ? "0" : "") + secs;
        } else {
            return minutes + ":" + (secs < 10 ? "0" : "") + secs;
        }
    }

     Timer {
         running: player.isPlaying
         interval: 1000
         repeat: true
         onTriggered: {
             if (!positionSlider.isDragging) {
                 positionSlider.value = player.length > 0 ? Math.min(1.0, player.position / player.length) : 0;
             }
             MprisController.activePlayer?.positionChanged();
         }
     }

    ClippingRectangle {
        anchors.fill: parent
        radius: Config.roundness > 0 ? Config.roundness + 4 : 0
        color: Colors.surface

        Item {
            id: noPlayerContainer
            anchors.fill: parent
            anchors.margins: 4
            visible: !MprisController.activePlayer

             WavyLine {
                 id: noPlayerWavyLine
                 anchors.left: parent.left
                 anchors.right: parent.right
                 anchors.verticalCenter: parent.verticalCenter
                 frequency: 2
                 color: Colors.outline
                 amplitudeMultiplier: 1
                 height: 16
                 lineWidth: 4
                 fullLength: width
                 visible: true
                 opacity: 1.0

                 Behavior on color {
                     ColorAnimation {
                         duration: Config.animDuration
                         easing.type: Easing.OutQuart
                     }
                 }

                 FrameAnimation {
                     running: noPlayerWavyLine.visible
                     onTriggered: noPlayerWavyLine.requestPaint()
                 }
             }
        }

        Image {
            id: backgroundArt
            anchors.fill: parent
            source: MprisController.activePlayer?.trackArtUrl ?? ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: false
        }

        MultiEffect {
            anchors.fill: parent
            source: backgroundArt
            brightness: -0.15
            contrast: -0.5
            saturation: -0.25
            // blurEnabled: true
            blurMax: 32
            blur: 0.75
            opacity: (MprisController.activePlayer?.trackArtUrl ?? "") !== "" ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: Config.animDuration
                    easing.type: Easing.OutQuart
                }
            }
        }

        ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8
            visible: MprisController.activePlayer
            layer.enabled: true
            layer.effect: Shadow {
                shadowBlur: 0.5
                shadowOpacity: 1
                shadowVerticalOffset: 2
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                spacing: 8

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 0

                    Text {
                        Layout.fillWidth: true
                        text: MprisController.activePlayer?.trackTitle ?? "No hay reproducción activa"
                        textFormat: Text.PlainText
                        color: player.hasArtwork && player.playerColors ? player.playerColors.overBackground : Colors.whiteSource
                        font.pixelSize: Config.theme.fontSize
                        font.weight: Font.Bold
                        font.family: Config.theme.font
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: MprisController.activePlayer?.trackArtist ?? ""
                        textFormat: Text.PlainText
                        color: player.hasArtwork && player.playerColors ? player.playerColors.overBackground : Colors.whiteSource
                        font.pixelSize: Config.theme.fontSize
                        font.family: Config.theme.font
                        // opacity: 0.7
                        elide: Text.ElideRight
                        visible: text !== ""
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: player.formatTime(player.position)
                            textFormat: Text.PlainText
                            color: player.hasArtwork && player.playerColors ? player.playerColors.overBackground : Colors.whiteSource
                            font.pixelSize: Config.theme.fontSize
                            font.family: Config.theme.font
                            visible: MprisController.activePlayer !== null
                        }

                        Text {
                            text: "/ " + player.formatTime(player.length)
                            textFormat: Text.PlainText
                            color: player.hasArtwork && player.playerColors ? player.playerColors.overBackground : Colors.whiteSource
                            font.pixelSize: Config.theme.fontSize
                            font.family: Config.theme.font
                            opacity: 0.5
                            visible: MprisController.activePlayer !== null
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    color: playPauseHover.hovered ? (player.hasArtwork && player.playerColors ? player.playerColors.overBackground : Colors.whiteSource) : (player.hasArtwork && player.playerColors ? player.playerColors.primary : Colors.primaryFixed)
                    radius: player.isPlaying ? Math.max(0, Config.roundness - 4) : Config.roundness > 0 ? Config.roundness + 4 : 0
                    opacity: MprisController.canTogglePlaying ? 1.0 : 0.3

                    Behavior on radius {
                        NumberAnimation {
                            duration: Config.animDuration
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.5
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.animDuration
                            easing.type: Easing.OutQuart
                        }
                    }

                    Text {
                        id: playPauseBtn
                        anchors.centerIn: parent
                        text: player.isPlaying ? Icons.pause : Icons.play
                        textFormat: Text.RichText
                        color: Colors.shadow
                        font.pixelSize: 20
                        font.family: Icons.font
                    }

                    HoverHandler {
                        id: playPauseHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: MprisController.canTogglePlaying
                        onClicked: MprisController.togglePlaying()
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                // Layout.preferredHeight: 40
                spacing: 8

                Text {
                    id: previousBtn
                    text: Icons.previous
                    textFormat: Text.RichText
                    color: previousHover.hovered ? (player.hasArtwork && player.playerColors ? player.playerColors.primary : Colors.primaryFixed) : (player.hasArtwork && player.playerColors ? player.playerColors.overBackground : Colors.whiteSource)
                    font.pixelSize: 20
                    font.family: Icons.font
                    opacity: MprisController.canGoPrevious ? 1.0 : 0.3

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.animDuration
                            easing.type: Easing.OutQuart
                        }
                    }

                    HoverHandler {
                        id: previousHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: MprisController.canGoPrevious
                        onClicked: MprisController.previous()
                    }
                }

                 StyledSlider {
                     id: positionSlider
                     Layout.fillWidth: true
                     Layout.preferredHeight: 4

                     value: player.length > 0 ? Math.min(1.0, player.position / player.length) : 0
                     progressColor: player.hasArtwork && player.playerColors ? player.playerColors.primary : Colors.primaryFixed
                     backgroundColor: player.hasArtwork && player.playerColors ? player.playerColors.shadow : Colors.shadow
                     wavy: player.isPlaying
                     wavyAmplitude: player.isPlaying ? 0.5 : 0.0
                     wavyFrequency: player.isPlaying ? 4 : 0
                     heightMultiplier: MprisController.activePlayer ? 8 : 4
                     resizeAnim: false
                     scroll: false
                     tooltip: false

                     onValueChanged: {
                         if (isDragging && MprisController.activePlayer && MprisController.activePlayer.canSeek) {
                             MprisController.activePlayer.position = value * player.length;
                         }
                     }
                 }

                Text {
                    id: nextBtn
                    text: Icons.next
                    textFormat: Text.RichText
                    color: nextHover.hovered ? (player.hasArtwork && player.playerColors ? player.playerColors.primary : Colors.primaryFixed) : (player.hasArtwork && player.playerColors ? player.playerColors.overBackground : Colors.whiteSource)
                    font.pixelSize: 20
                    font.family: Icons.font
                    opacity: MprisController.canGoNext ? 1.0 : 0.3

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.animDuration
                            easing.type: Easing.OutQuart
                        }
                    }

                    HoverHandler {
                        id: nextHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: MprisController.canGoNext
                        onClicked: MprisController.next()
                    }
                }

                Text {
                    id: modeBtn
                    text: {
                        if (MprisController.hasShuffle)
                            return Icons.shuffle;
                        switch (MprisController.loopState) {
                        case MprisLoopState.Track:
                            return Icons.repeatOnce;
                        case MprisLoopState.Playlist:
                            return Icons.repeat;
                        default:
                            return Icons.shuffle;
                        }
                    }
                    textFormat: Text.RichText
                    color: modeHover.hovered ? (player.hasArtwork && player.playerColors ? player.playerColors.primary : Colors.primaryFixed) : (player.hasArtwork && player.playerColors ? player.playerColors.overBackground : Colors.whiteSource)
                    font.pixelSize: 20
                    font.family: Icons.font
                    opacity: {
                        if (!(MprisController.shuffleSupported || MprisController.loopSupported))
                            return 0.3;
                        if (!MprisController.hasShuffle && MprisController.loopState === MprisLoopState.None)
                            return 0.3;
                        return 1.0;
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.animDuration
                            easing.type: Easing.OutQuart
                        }
                    }

                    HoverHandler {
                        id: modeHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: MprisController.shuffleSupported || MprisController.loopSupported
                        onClicked: {
                            if (MprisController.hasShuffle) {
                                MprisController.setShuffle(false);
                                MprisController.setLoopState(MprisLoopState.Playlist);
                            } else if (MprisController.loopState === MprisLoopState.Playlist) {
                                MprisController.setLoopState(MprisLoopState.Track);
                            } else if (MprisController.loopState === MprisLoopState.Track) {
                                MprisController.setLoopState(MprisLoopState.None);
                            } else {
                                MprisController.setShuffle(true);
                            }
                        }
                    }
                }

                Text {
                    id: playerIcon
                    text: {
                        if (!MprisController.activePlayer)
                            return Icons.player;
                        const dbusName = (MprisController.activePlayer.dbusName || "").toLowerCase();
                        const desktopEntry = (MprisController.activePlayer.desktopEntry || "").toLowerCase();
                        const identity = (MprisController.activePlayer.identity || "").toLowerCase();

                        if (dbusName.includes("spotify") || desktopEntry.includes("spotify") || identity.includes("spotify"))
                            return Icons.spotify;
                        if (dbusName.includes("chromium") || dbusName.includes("chrome") || desktopEntry.includes("chromium") || desktopEntry.includes("chrome"))
                            return Icons.chromium;
                        if (dbusName.includes("firefox") || desktopEntry.includes("firefox"))
                            return Icons.firefox;
                        if (dbusName.includes("telegram") || desktopEntry.includes("telegram") || identity.includes("telegram"))
                            return Icons.telegram;
                        return Icons.player;
                    }
                    textFormat: Text.RichText
                    color: playerIconHover.hovered ? (player.hasArtwork && player.playerColors ? player.playerColors.primary : Colors.primaryFixed) : (player.hasArtwork && player.playerColors ? player.playerColors.overBackground : Colors.whiteSource)
                    font.pixelSize: 20
                    font.family: Icons.font
                    opacity: MprisController.activePlayer ? 1.0 : 0.3

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.animDuration
                            easing.type: Easing.OutQuart
                        }
                    }

                    HoverHandler {
                        id: playerIconHover
                    }

                    Timer {
                        id: pressAndHoldTimer
                        interval: 1000
                        repeat: false
                        onTriggered: {
                            playersMenu.updateMenuItems();
                            playersMenu.popup(playerIcon);
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onPressed: mouse => {
                            if (mouse.button === Qt.LeftButton) {
                                pressAndHoldTimer.start();
                            }
                        }
                        onReleased: {
                            pressAndHoldTimer.stop();
                        }
                        onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton) {
                                MprisController.cyclePlayer(1);
                            } else if (mouse.button === Qt.RightButton) {
                                playersMenu.updateMenuItems();
                                playersMenu.popup(playerIcon);
                            }
                        }
                    }

                    OptionsMenu {
                        id: playersMenu

                        function getPlayerIcon(player) {
                            if (!player)
                                return Icons.player;
                            const dbusName = (player.dbusName || "").toLowerCase();
                            const desktopEntry = (player.desktopEntry || "").toLowerCase();
                            const identity = (player.identity || "").toLowerCase();

                            if (dbusName.includes("spotify") || desktopEntry.includes("spotify") || identity.includes("spotify"))
                                return Icons.spotify;
                            if (dbusName.includes("chromium") || dbusName.includes("chrome") || desktopEntry.includes("chromium") || desktopEntry.includes("chrome"))
                                return Icons.chromium;
                            if (dbusName.includes("firefox") || desktopEntry.includes("firefox"))
                                return Icons.firefox;
                            if (dbusName.includes("telegram") || desktopEntry.includes("telegram") || identity.includes("telegram"))
                                return Icons.telegram;
                            return Icons.player;
                        }

                        function updateMenuItems() {
                            const players = MprisController.filteredPlayers;
                            const menuItems = [];

                            for (let i = 0; i < players.length; i++) {
                                const player = players[i];
                                const isActive = player === MprisController.activePlayer;
                                const playerColors = PlayerColors.getColorsForPlayer(player);

                                menuItems.push({
                                    text: player.trackTitle || player.identity || "Unknown Player",
                                    icon: getPlayerIcon(player),
                                    highlightColor: playerColors.primary,
                                    textColor: playerColors.overPrimary,
                                    onTriggered: () => {
                                        MprisController.setActivePlayer(player);
                                        playersMenu.close();
                                    }
                                });
                            }

                            playersMenu.items = menuItems;
                        }
                    }
                }
            }
        }
    }
}
