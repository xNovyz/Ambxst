import QtQuick
import Quickshell.Services.Mpris
import qs.modules.theme
import qs.modules.services
import qs.modules.notch
import qs.modules.components
import qs.config

Item {
    id: root
    anchors.top: parent.top

    readonly property real mainRowContentWidth: 200 + userInfo.width + separator1.width + separator2.width + notifIndicator.width + (mainRow.spacing * 4) + 32

    implicitWidth: Math.round(hasActiveNotifications ? Math.max(notificationHoverHandler.hovered ? 420 + 32 : 320 + 32, mainRowContentWidth) : (root.notchHovered ? 420 + 32 : mainRowContentWidth))
    implicitHeight: hasActiveNotifications ? (mainRow.height + (notificationHoverHandler.hovered ? notificationView.implicitHeight + (Config.notchTheme === "island" ? 56 : 32) : notificationView.implicitHeight + (Config.notchTheme === "island" ? 40 : 16))) : mainRow.height

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Config.animDuration
            easing.type: Easing.OutQuart
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Config.animDuration
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    readonly property bool hasActiveNotifications: Notifications.popupList.length > 0
    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    property bool notchHovered: false

    HoverHandler {
        id: notificationHoverHandler
        enabled: hasActiveNotifications
    }

    Column {
        anchors.fill: parent
        // anchors.topMargin: hasActiveNotifications ? 0 : ((parent.height - mainRow.height) / 2)
        spacing: hasActiveNotifications ? 4 : 0

        Behavior on spacing {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }
        }

        Row {
            id: mainRow
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 28
            height: Config.bar.showBackground ? (Config.notchTheme === "island" ? 36 : 44) : (Config.notchTheme === "island" ? 36 : 40)
            spacing: 4

            UserInfo {
                id: userInfo
                anchors.verticalCenter: parent.verticalCenter
            }

            Separator {
                id: separator1
                anchors.verticalCenter: parent.verticalCenter
            }

            CompactPlayer {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - userInfo.width - separator1.width - separator2.width - notifIndicator.width - (parent.spacing * 4)
                height: 32
                player: activePlayer
                notchHovered: root.notchHovered
            }

            Separator {
                id: separator2
                anchors.verticalCenter: parent.verticalCenter
            }

            NotificationIndicator {
                id: notifIndicator
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: hasActiveNotifications ? notificationView.implicitHeight : 0
            clip: false
            visible: height > 0

            Behavior on height {
                NumberAnimation {
                    duration: Config.animDuration
                    easing.type: Easing.OutQuart
                }
            }

            NotchNotificationView {
                id: notificationView
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: Config.notchTheme === "island" && hasActiveNotifications ? 8 : 20
                anchors.rightMargin: Config.notchTheme === "island" && hasActiveNotifications ? 8 : 20
                anchors.bottomMargin: 8
                opacity: hasActiveNotifications ? 1 : 0
                notchHovered: notificationHoverHandler.hovered

                Behavior on anchors.leftMargin {
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutQuart
                    }
                }

                Behavior on anchors.rightMargin {
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutQuart
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutQuart
                    }
                }
            }
        }
    }
}
