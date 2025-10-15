import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.modules.theme
import qs.modules.globals
import qs.config

Item {
    property bool schemeListExpanded: false
    readonly property var schemeDisplayNames: ["Content", "Expressive", "Fidelity", "Fruit Salad", "Monochrome", "Neutral", "Rainbow", "Tonal Spot"]
    
    function getSchemeDisplayName(scheme) {
        const map = {
            "scheme-content": "Content",
            "scheme-expressive": "Expressive",
            "scheme-fidelity": "Fidelity",
            "scheme-fruit-salad": "Fruit Salad",
            "scheme-monochrome": "Monochrome",
            "scheme-neutral": "Neutral",
            "scheme-rainbow": "Rainbow",
            "scheme-tonal-spot": "Tonal Spot"
        };
        return map[scheme] || scheme;
    }
    
    Layout.fillWidth: true
    implicitHeight: mainLayout.implicitHeight + 8
    
    Rectangle {
        color: Colors.surface
        radius: Config.roundness > 0 ? Config.roundness + 4 : 0
        anchors.fill: parent
        
        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            anchors.margins: 4
            spacing: 0

            // Top row with scheme button and dark/light button
            RowLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    text: getSchemeDisplayName(Config.theme.matugenScheme) || "Selecciona esquema"
                    onClicked: schemeListExpanded = !schemeListExpanded
                    
                    background: Rectangle {
                        color: Colors.background
                        radius: Config.roundness
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: Colors.overSurface
                        font.family: Config.theme.font
                        font.pixelSize: Config.theme.fontSize
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                    }
                }
                
                Button {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    onClicked: {
                        Config.theme.lightMode = !Config.theme.lightMode;
                    }
                    
                    background: Rectangle {
                        color: Colors.background
                        radius: Config.roundness
                    }
                    
                    contentItem: Text {
                        text: Config.theme.lightMode ? Icons.sun : Icons.moon
                        color: Colors.primary
                        font.family: Icons.font
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

                
            Flickable {
                id: schemeFlickable
                Layout.fillWidth: true
                Layout.preferredHeight: schemeListExpanded ? 40 * 3 : 0
                Layout.topMargin: schemeListExpanded ? 4 : 0
                contentHeight: schemeColumn.height
                clip: true
                Column {
                    id: schemeColumn
                    width: parent.width
                    spacing: 0
                    
                    Repeater {
                        model: ["scheme-content", "scheme-expressive", "scheme-fidelity", "scheme-fruit-salad", "scheme-monochrome", "scheme-neutral", "scheme-rainbow", "scheme-tonal-spot"]
                        
                        Button {
                            width: parent.width
                            height: 40
                            text: schemeDisplayNames[index]
                            onClicked: {
                                Config.theme.matugenScheme = modelData;
                                schemeListExpanded = false;
                                if (GlobalStates.wallpaperManager) {
                                    GlobalStates.wallpaperManager.runMatugenForCurrentWallpaper();
                                }
                            }
                            
                            background: Rectangle {
                                color: "transparent"
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: Colors.overSurface
                                font.family: Config.theme.font
                                font.pixelSize: Config.theme.fontSize
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 8
                            }
                        }
                    }
                }

                // Animate topMargin for Flickable
                Behavior on Layout.topMargin {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
                
                ScrollBar.vertical: ScrollBar {
                    parent: schemeFlickable
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    height: parent.height
                    width: 8
                    policy: ScrollBar.AlwaysOn
                    
                    background: Rectangle {
                        color: Colors.background
                        radius: Config.roundness
                    }
                    
                    contentItem: Rectangle {
                        color: Colors.primary
                        radius: Config.roundness
                    }
                }
                
                Behavior on Layout.preferredHeight {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
