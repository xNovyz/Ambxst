pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.modules.theme
import qs.modules.components
import qs.modules.services
import qs.config

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // Titlebar
        PanelTitlebar {
            title: "EasyEffects"
            statusText: EasyEffectsService.bypassed ? "Bypassed" : ""
            statusColor: Colors.error
            showToggle: EasyEffectsService.available
            toggleChecked: !EasyEffectsService.bypassed
            
            actions: EasyEffectsService.available ? [
                {
                    icon: Icons.externalLink,
                    tooltip: "Open EasyEffects",
                    onClicked: function() { EasyEffectsService.openApp(); }
                },
                {
                    icon: Icons.sync,
                    tooltip: "Refresh",
                    onClicked: function() { EasyEffectsService.refresh(); }
                }
            ] : []
            
            onToggleChanged: checked => {
                if (checked !== !EasyEffectsService.bypassed) {
                    EasyEffectsService.setBypass(!checked);
                }
            }
        }

        // Not available state
        Text {
            visible: !EasyEffectsService.available
            text: "EasyEffects not installed"
            font.family: Config.theme.font
            font.pixelSize: Config.theme.fontSize
            color: Colors.overSurfaceVariant
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 32
        }

        // Presets section
        Flickable {
            visible: EasyEffectsService.available
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: presetsColumn.implicitHeight
            clip: true

            ColumnLayout {
                id: presetsColumn
                width: parent.width
                spacing: 12

                // Output presets
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    visible: EasyEffectsService.outputPresets.length > 0

                    Text {
                        text: "Output Presets"
                        font.family: Config.theme.font
                        font.pixelSize: Styling.fontSize(-1)
                        font.weight: Font.Medium
                        color: Colors.overSurfaceVariant
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: EasyEffectsService.outputPresets

                            delegate: Button {
                                id: presetButton
                                required property string modelData
                                flat: true
                                
                                property bool isActive: EasyEffectsService.activeOutputPreset === modelData

                                background: StyledRect {
                                    variant: presetButton.isActive ? "primary" : (presetButton.hovered ? "focus" : "common")
                                    radius: Styling.radius(4)
                                }

                                contentItem: Text {
                                    text: presetButton.modelData
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(-1)
                                    color: presetButton.isActive 
                                        ? Config.resolveColor(Config.theme.srPrimary.itemColor)
                                        : Colors.overBackground
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 12
                                    rightPadding: 12
                                    topPadding: 6
                                    bottomPadding: 6
                                }

                                onClicked: EasyEffectsService.loadPreset(modelData)
                            }
                        }
                    }
                }

                // Input presets
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    visible: EasyEffectsService.inputPresets.length > 0

                    Text {
                        text: "Input Presets"
                        font.family: Config.theme.font
                        font.pixelSize: Styling.fontSize(-1)
                        font.weight: Font.Medium
                        color: Colors.overSurfaceVariant
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: EasyEffectsService.inputPresets

                            delegate: Button {
                                id: inputPresetButton
                                required property string modelData
                                flat: true
                                
                                property bool isActive: EasyEffectsService.activeInputPreset === modelData

                                background: StyledRect {
                                    variant: inputPresetButton.isActive ? "primary" : (inputPresetButton.hovered ? "focus" : "common")
                                    radius: Styling.radius(4)
                                }

                                contentItem: Text {
                                    text: inputPresetButton.modelData
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(-1)
                                    color: inputPresetButton.isActive 
                                        ? Config.resolveColor(Config.theme.srPrimary.itemColor)
                                        : Colors.overBackground
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 12
                                    rightPadding: 12
                                    topPadding: 6
                                    bottomPadding: 6
                                }

                                onClicked: EasyEffectsService.loadPreset(modelData)
                            }
                        }
                    }
                }

                // Empty state
                Text {
                    visible: EasyEffectsService.outputPresets.length === 0 && EasyEffectsService.inputPresets.length === 0
                    text: "No presets configured"
                    font.family: Config.theme.font
                    font.pixelSize: Config.theme.fontSize
                    color: Colors.overSurfaceVariant
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 16
                }

                // Current status
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 16
                    spacing: 4
                    visible: EasyEffectsService.activeOutputPreset || EasyEffectsService.activeInputPreset

                    Text {
                        text: "Active"
                        font.family: Config.theme.font
                        font.pixelSize: Styling.fontSize(-1)
                        font.weight: Font.Medium
                        color: Colors.overSurfaceVariant
                    }

                    RowLayout {
                        spacing: 16
                        visible: EasyEffectsService.activeOutputPreset

                        Text {
                            text: Icons.speakerHigh
                            font.family: Icons.font
                            font.pixelSize: 14
                            color: Colors.primary
                        }
                        Text {
                            text: EasyEffectsService.activeOutputPreset
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            color: Colors.overBackground
                        }
                    }

                    RowLayout {
                        spacing: 16
                        visible: EasyEffectsService.activeInputPreset

                        Text {
                            text: Icons.mic
                            font.family: Icons.font
                            font.pixelSize: 14
                            color: Colors.primary
                        }
                        Text {
                            text: EasyEffectsService.activeInputPreset
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            color: Colors.overBackground
                        }
                    }
                }
            }
        }
    }
}
