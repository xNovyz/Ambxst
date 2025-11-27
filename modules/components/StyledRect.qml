pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell.Widgets
import qs.modules.theme
import qs.config

ClippingRectangle {
    id: root

    clip: true
    antialiasing: true

    required property string variant

    property string gradientOrientation: "vertical"
    property bool enableShadow: false

    readonly property var gradientStops: {
        switch (variant) {
        case "bg":
            return Config.theme.gradBg;
        case "pane":
            return Config.theme.gradPane;
        case "common":
            return Config.theme.gradCommon;
        case "focus":
            return Config.theme.gradFocus;
        case "primary":
            return Config.theme.gradPrimary;
        case "primaryfocus":
            return Config.theme.gradPrimaryFocus;
        case "overprimary":
            return Config.theme.gradOverPrimary;
        case "secondary":
            return Config.theme.gradSecondary;
        case "secondaryfocus":
            return Config.theme.gradSecondaryFocus;
        case "oversecondary":
            return Config.theme.gradOverSecondary;
        case "tertiary":
            return Config.theme.gradTertiary;
        case "tertiaryfocus":
            return Config.theme.gradTertiaryFocus;
        case "overtertiary":
            return Config.theme.gradOverTertiary;
        case "error":
            return Config.theme.gradError;
        case "errorfocus":
            return Config.theme.gradErrorFocus;
        case "overerror":
            return Config.theme.gradOverError;
        default:
            return Config.theme.gradCommon;
        }
    }

    readonly property string gradientType: {
        switch (variant) {
        case "bg":
            return Config.theme.gradBgType;
        case "pane":
            return Config.theme.gradPaneType;
        case "common":
            return Config.theme.gradCommonType;
        case "focus":
            return Config.theme.gradFocusType;
        case "primary":
            return Config.theme.gradPrimaryType;
        case "primaryfocus":
            return Config.theme.gradPrimaryFocusType;
        case "overprimary":
            return Config.theme.gradOverPrimaryType;
        case "secondary":
            return Config.theme.gradSecondaryType;
        case "secondaryfocus":
            return Config.theme.gradSecondaryFocusType;
        case "oversecondary":
            return Config.theme.gradOverSecondaryType;
        case "tertiary":
            return Config.theme.gradTertiaryType;
        case "tertiaryfocus":
            return Config.theme.gradTertiaryFocusType;
        case "overtertiary":
            return Config.theme.gradOverTertiaryType;
        case "error":
            return Config.theme.gradErrorType;
        case "errorfocus":
            return Config.theme.gradErrorFocusType;
        case "overerror":
            return Config.theme.gradOverErrorType;
        default:
            return Config.theme.gradCommonType;
        }
    }

    readonly property real gradientAngle: {
        switch (variant) {
        case "bg":
            return Config.theme.gradBgAngle;
        case "pane":
            return Config.theme.gradPaneAngle;
        case "common":
            return Config.theme.gradCommonAngle;
        case "focus":
            return Config.theme.gradFocusAngle;
        case "primary":
            return Config.theme.gradPrimaryAngle;
        case "primaryfocus":
            return Config.theme.gradPrimaryFocusAngle;
        case "overprimary":
            return Config.theme.gradOverPrimaryAngle;
        case "secondary":
            return Config.theme.gradSecondaryAngle;
        case "secondaryfocus":
            return Config.theme.gradSecondaryFocusAngle;
        case "oversecondary":
            return Config.theme.gradOverSecondaryAngle;
        case "tertiary":
            return Config.theme.gradTertiaryAngle;
        case "tertiaryfocus":
            return Config.theme.gradTertiaryFocusAngle;
        case "overtertiary":
            return Config.theme.gradOverTertiaryAngle;
        case "error":
            return Config.theme.gradErrorAngle;
        case "errorfocus":
            return Config.theme.gradErrorFocusAngle;
        case "overerror":
            return Config.theme.gradOverErrorAngle;
        default:
            return Config.theme.gradCommonAngle;
        }
    }

    readonly property real gradientCenterX: {
        switch (variant) {
        case "bg":
            return Config.theme.gradBgCenterX;
        case "pane":
            return Config.theme.gradPaneCenterX;
        case "common":
            return Config.theme.gradCommonCenterX;
        case "focus":
            return Config.theme.gradFocusCenterX;
        case "primary":
            return Config.theme.gradPrimaryCenterX;
        case "primaryfocus":
            return Config.theme.gradPrimaryFocusCenterX;
        case "overprimary":
            return Config.theme.gradOverPrimaryCenterX;
        case "secondary":
            return Config.theme.gradSecondaryCenterX;
        case "secondaryfocus":
            return Config.theme.gradSecondaryFocusCenterX;
        case "oversecondary":
            return Config.theme.gradOverSecondaryCenterX;
        case "tertiary":
            return Config.theme.gradTertiaryCenterX;
        case "tertiaryfocus":
            return Config.theme.gradTertiaryFocusCenterX;
        case "overtertiary":
            return Config.theme.gradOverTertiaryCenterX;
        case "error":
            return Config.theme.gradErrorCenterX;
        case "errorfocus":
            return Config.theme.gradErrorFocusCenterX;
        case "overerror":
            return Config.theme.gradOverErrorCenterX;
        default:
            return Config.theme.gradCommonCenterX;
        }
    }

    readonly property real gradientCenterY: {
        switch (variant) {
        case "bg":
            return Config.theme.gradBgCenterY;
        case "pane":
            return Config.theme.gradPaneCenterY;
        case "common":
            return Config.theme.gradCommonCenterY;
        case "focus":
            return Config.theme.gradFocusCenterY;
        case "primary":
            return Config.theme.gradPrimaryCenterY;
        case "primaryfocus":
            return Config.theme.gradPrimaryFocusCenterY;
        case "overprimary":
            return Config.theme.gradOverPrimaryCenterY;
        case "secondary":
            return Config.theme.gradSecondaryCenterY;
        case "secondaryfocus":
            return Config.theme.gradSecondaryFocusCenterY;
        case "oversecondary":
            return Config.theme.gradOverSecondaryCenterY;
        case "tertiary":
            return Config.theme.gradTertiaryCenterY;
        case "tertiaryfocus":
            return Config.theme.gradTertiaryFocusCenterY;
        case "overtertiary":
            return Config.theme.gradOverTertiaryCenterY;
        case "error":
            return Config.theme.gradErrorCenterY;
        case "errorfocus":
            return Config.theme.gradErrorFocusCenterY;
        case "overerror":
            return Config.theme.gradOverErrorCenterY;
        default:
            return Config.theme.gradCommonCenterY;
        }
    }

    readonly property real halftoneDotMin: {
        switch (variant) {
        case "bg":
            return Config.theme.gradBgHalftoneDotMin;
        case "pane":
            return Config.theme.gradPaneHalftoneDotMin;
        case "common":
            return Config.theme.gradCommonHalftoneDotMin;
        case "focus":
            return Config.theme.gradFocusHalftoneDotMin;
        case "primary":
            return Config.theme.gradPrimaryHalftoneDotMin;
        case "primaryfocus":
            return Config.theme.gradPrimaryFocusHalftoneDotMin;
        case "overprimary":
            return Config.theme.gradOverPrimaryHalftoneDotMin;
        case "secondary":
            return Config.theme.gradSecondaryHalftoneDotMin;
        case "secondaryfocus":
            return Config.theme.gradSecondaryFocusHalftoneDotMin;
        case "oversecondary":
            return Config.theme.gradOverSecondaryHalftoneDotMin;
        case "tertiary":
            return Config.theme.gradTertiaryHalftoneDotMin;
        case "tertiaryfocus":
            return Config.theme.gradTertiaryFocusHalftoneDotMin;
        case "overtertiary":
            return Config.theme.gradOverTertiaryHalftoneDotMin;
        case "error":
            return Config.theme.gradErrorHalftoneDotMin;
        case "errorfocus":
            return Config.theme.gradErrorFocusHalftoneDotMin;
        case "overerror":
            return Config.theme.gradOverErrorHalftoneDotMin;
        default:
            return Config.theme.gradCommonHalftoneDotMin;
        }
    }

    readonly property real halftoneDotMax: {
        switch (variant) {
        case "bg":
            return Config.theme.gradBgHalftoneDotMax;
        case "pane":
            return Config.theme.gradPaneHalftoneDotMax;
        case "common":
            return Config.theme.gradCommonHalftoneDotMax;
        case "focus":
            return Config.theme.gradFocusHalftoneDotMax;
        case "primary":
            return Config.theme.gradPrimaryHalftoneDotMax;
        case "primaryfocus":
            return Config.theme.gradPrimaryFocusHalftoneDotMax;
        case "overprimary":
            return Config.theme.gradOverPrimaryHalftoneDotMax;
        case "secondary":
            return Config.theme.gradSecondaryHalftoneDotMax;
        case "secondaryfocus":
            return Config.theme.gradSecondaryFocusHalftoneDotMax;
        case "oversecondary":
            return Config.theme.gradOverSecondaryHalftoneDotMax;
        case "tertiary":
            return Config.theme.gradTertiaryHalftoneDotMax;
        case "tertiaryfocus":
            return Config.theme.gradTertiaryFocusHalftoneDotMax;
        case "overtertiary":
            return Config.theme.gradOverTertiaryHalftoneDotMax;
        case "error":
            return Config.theme.gradErrorHalftoneDotMax;
        case "errorfocus":
            return Config.theme.gradErrorFocusHalftoneDotMax;
        case "overerror":
            return Config.theme.gradOverErrorHalftoneDotMax;
        default:
            return Config.theme.gradCommonHalftoneDotMax;
        }
    }

    readonly property real halftoneStart: {
        switch (variant) {
        case "bg":
            return Config.theme.gradBgHalftoneStart;
        case "pane":
            return Config.theme.gradPaneHalftoneStart;
        case "common":
            return Config.theme.gradCommonHalftoneStart;
        case "focus":
            return Config.theme.gradFocusHalftoneStart;
        case "primary":
            return Config.theme.gradPrimaryHalftoneStart;
        case "primaryfocus":
            return Config.theme.gradPrimaryFocusHalftoneStart;
        case "overprimary":
            return Config.theme.gradOverPrimaryHalftoneStart;
        case "secondary":
            return Config.theme.gradSecondaryHalftoneStart;
        case "secondaryfocus":
            return Config.theme.gradSecondaryFocusHalftoneStart;
        case "oversecondary":
            return Config.theme.gradOverSecondaryHalftoneStart;
        case "tertiary":
            return Config.theme.gradTertiaryHalftoneStart;
        case "tertiaryfocus":
            return Config.theme.gradTertiaryFocusHalftoneStart;
        case "overtertiary":
            return Config.theme.gradOverTertiaryHalftoneStart;
        case "error":
            return Config.theme.gradErrorHalftoneStart;
        case "errorfocus":
            return Config.theme.gradErrorFocusHalftoneStart;
        case "overerror":
            return Config.theme.gradOverErrorHalftoneStart;
        default:
            return Config.theme.gradCommonHalftoneStart;
        }
    }

    readonly property real halftoneEnd: {
        switch (variant) {
        case "bg":
            return Config.theme.gradBgHalftoneEnd;
        case "pane":
            return Config.theme.gradPaneHalftoneEnd;
        case "common":
            return Config.theme.gradCommonHalftoneEnd;
        case "focus":
            return Config.theme.gradFocusHalftoneEnd;
        case "primary":
            return Config.theme.gradPrimaryHalftoneEnd;
        case "primaryfocus":
            return Config.theme.gradPrimaryFocusHalftoneEnd;
        case "overprimary":
            return Config.theme.gradOverPrimaryHalftoneEnd;
        case "secondary":
            return Config.theme.gradSecondaryHalftoneEnd;
        case "secondaryfocus":
            return Config.theme.gradSecondaryFocusHalftoneEnd;
        case "oversecondary":
            return Config.theme.gradOverSecondaryHalftoneEnd;
        case "tertiary":
            return Config.theme.gradTertiaryHalftoneEnd;
        case "tertiaryfocus":
            return Config.theme.gradTertiaryFocusHalftoneEnd;
        case "overtertiary":
            return Config.theme.gradOverTertiaryHalftoneEnd;
        case "error":
            return Config.theme.gradErrorHalftoneEnd;
        case "errorfocus":
            return Config.theme.gradErrorFocusHalftoneEnd;
        case "overerror":
            return Config.theme.gradOverErrorHalftoneEnd;
        default:
            return Config.theme.gradCommonHalftoneEnd;
        }
    }

    readonly property color halftoneDotColor: {
        switch (variant) {
        case "bg":
            return Config.resolveColor(Config.theme.gradBgHalftoneDotColor);
        case "pane":
            return Config.resolveColor(Config.theme.gradPaneHalftoneDotColor);
        case "common":
            return Config.resolveColor(Config.theme.gradCommonHalftoneDotColor);
        case "focus":
            return Config.resolveColor(Config.theme.gradFocusHalftoneDotColor);
        case "primary":
            return Config.resolveColor(Config.theme.gradPrimaryHalftoneDotColor);
        case "primaryfocus":
            return Config.resolveColor(Config.theme.gradPrimaryFocusHalftoneDotColor);
        case "overprimary":
            return Config.resolveColor(Config.theme.gradOverPrimaryHalftoneDotColor);
        case "secondary":
            return Config.resolveColor(Config.theme.gradSecondaryHalftoneDotColor);
        case "secondaryfocus":
            return Config.resolveColor(Config.theme.gradSecondaryFocusHalftoneDotColor);
        case "oversecondary":
            return Config.resolveColor(Config.theme.gradOverSecondaryHalftoneDotColor);
        case "tertiary":
            return Config.resolveColor(Config.theme.gradTertiaryHalftoneDotColor);
        case "tertiaryfocus":
            return Config.resolveColor(Config.theme.gradTertiaryFocusHalftoneDotColor);
        case "overtertiary":
            return Config.resolveColor(Config.theme.gradOverTertiaryHalftoneDotColor);
        case "error":
            return Config.resolveColor(Config.theme.gradErrorHalftoneDotColor);
        case "errorfocus":
            return Config.resolveColor(Config.theme.gradErrorFocusHalftoneDotColor);
        case "overerror":
            return Config.resolveColor(Config.theme.gradOverErrorHalftoneDotColor);
        default:
            return Config.resolveColor(Config.theme.gradCommonHalftoneDotColor);
        }
    }

    readonly property color halftoneBackgroundColor: {
        switch (variant) {
        case "bg":
            return Config.resolveColor(Config.theme.gradBgHalftoneBackgroundColor);
        case "pane":
            return Config.resolveColor(Config.theme.gradPaneHalftoneBackgroundColor);
        case "common":
            return Config.resolveColor(Config.theme.gradCommonHalftoneBackgroundColor);
        case "focus":
            return Config.resolveColor(Config.theme.gradFocusHalftoneBackgroundColor);
        case "primary":
            return Config.resolveColor(Config.theme.gradPrimaryHalftoneBackgroundColor);
        case "primaryfocus":
            return Config.resolveColor(Config.theme.gradPrimaryFocusHalftoneBackgroundColor);
        case "overprimary":
            return Config.resolveColor(Config.theme.gradOverPrimaryHalftoneBackgroundColor);
        case "secondary":
            return Config.resolveColor(Config.theme.gradSecondaryHalftoneBackgroundColor);
        case "secondaryfocus":
            return Config.resolveColor(Config.theme.gradSecondaryFocusHalftoneBackgroundColor);
        case "oversecondary":
            return Config.resolveColor(Config.theme.gradOverSecondaryHalftoneBackgroundColor);
        case "tertiary":
            return Config.resolveColor(Config.theme.gradTertiaryHalftoneBackgroundColor);
        case "tertiaryfocus":
            return Config.resolveColor(Config.theme.gradTertiaryFocusHalftoneBackgroundColor);
        case "overtertiary":
            return Config.resolveColor(Config.theme.gradOverTertiaryHalftoneBackgroundColor);
        case "error":
            return Config.resolveColor(Config.theme.gradErrorHalftoneBackgroundColor);
        case "errorfocus":
            return Config.resolveColor(Config.theme.gradErrorFocusHalftoneBackgroundColor);
        case "overerror":
            return Config.resolveColor(Config.theme.gradOverErrorHalftoneBackgroundColor);
        default:
            return Config.resolveColor(Config.theme.gradCommonHalftoneBackgroundColor);
        }
    }

    readonly property var borderData: {
        switch (variant) {
        case "bg":
            return Config.theme.borderBg;
        case "pane":
            return Config.theme.borderPane;
        case "common":
            return Config.theme.borderCommon;
        case "focus":
            return Config.theme.borderFocus;
        case "primary":
            return Config.theme.borderPrimary;
        case "primaryfocus":
            return Config.theme.borderPrimaryFocus;
        case "overprimary":
            return Config.theme.borderOverPrimary;
        case "secondary":
            return Config.theme.borderSecondary;
        case "secondaryfocus":
            return Config.theme.borderSecondaryFocus;
        case "oversecondary":
            return Config.theme.borderOverSecondary;
        case "tertiary":
            return Config.theme.borderTertiary;
        case "tertiaryfocus":
            return Config.theme.borderTertiaryFocus;
        case "overtertiary":
            return Config.theme.borderOverTertiary;
        case "error":
            return Config.theme.borderError;
        case "errorfocus":
            return Config.theme.borderErrorFocus;
        case "overerror":
            return Config.theme.borderOverError;
        default:
            return Config.theme.borderCommon;
        }
    }

    readonly property color itemColor: {
        switch (variant) {
        case "bg":
            return Config.resolveColor(Config.theme.itemBg);
        case "pane":
            return Config.resolveColor(Config.theme.itemPane);
        case "common":
            return Config.resolveColor(Config.theme.itemCommon);
        case "focus":
            return Config.resolveColor(Config.theme.itemFocus);
        case "primary":
            return Config.resolveColor(Config.theme.itemPrimary);
        case "primaryfocus":
            return Config.resolveColor(Config.theme.itemPrimaryFocus);
        case "overprimary":
            return Config.resolveColor(Config.theme.itemOverPrimary);
        case "secondary":
            return Config.resolveColor(Config.theme.itemSecondary);
        case "secondaryfocus":
            return Config.resolveColor(Config.theme.itemSecondaryFocus);
        case "oversecondary":
            return Config.resolveColor(Config.theme.itemOverSecondary);
        case "tertiary":
            return Config.resolveColor(Config.theme.itemTertiary);
        case "tertiaryfocus":
            return Config.resolveColor(Config.theme.itemTertiaryFocus);
        case "overtertiary":
            return Config.resolveColor(Config.theme.itemOverTertiary);
        case "error":
            return Config.resolveColor(Config.theme.itemError);
        case "errorfocus":
            return Config.resolveColor(Config.theme.itemErrorFocus);
        case "overerror":
            return Config.resolveColor(Config.theme.itemOverError);
        default:
            return Config.resolveColor(Config.theme.itemCommon);
        }
    }

    radius: Config.roundness
    color: "transparent"

    // Linear gradient
    Rectangle {
        readonly property real diagonal: Math.sqrt(parent.width * parent.width + parent.height * parent.height)
        width: diagonal
        height: diagonal
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        visible: gradientType === "linear"
        rotation: gradientAngle
        transformOrigin: Item.Center
        gradient: Gradient {
            orientation: gradientOrientation === "horizontal" ? Gradient.Horizontal : Gradient.Vertical

            GradientStop {
                property var stopData: gradientStops[0] || ["surface", 0.0]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[1] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[2] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[3] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[4] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }
        }
    }

    // Radial gradient
    Shape {
        id: radialShape
        readonly property real maxDim: Math.max(parent.width, parent.height)
        width: maxDim + 2
        height: maxDim + 2
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        visible: gradientType === "radial"
        layer.enabled: true
        layer.smooth: true

        transform: Scale {
            xScale: radialShape.parent.width / radialShape.maxDim
            yScale: radialShape.parent.height / radialShape.maxDim
            origin.x: radialShape.width / 2
            origin.y: radialShape.height / 2
        }

        ShapePath {
            fillGradient: RadialGradient {
                centerX: radialShape.width * gradientCenterX
                centerY: radialShape.height * gradientCenterY
                centerRadius: radialShape.maxDim
                focalX: centerX
                focalY: centerY

                GradientStop {
                    property var stopData: gradientStops[0] || ["surface", 0.0]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[1] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[2] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[3] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[4] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }
            }

            startX: 0
            startY: 0

            PathLine {
                x: radialShape.width
                y: 0
            }
            PathLine {
                x: radialShape.width
                y: radialShape.height
            }
            PathLine {
                x: 0
                y: radialShape.height
            }
            PathLine {
                x: 0
                y: 0
            }
        }
    }

    // Halftone gradient
    ShaderEffect {
        anchors.fill: parent
        visible: gradientType === "halftone"
        
        property real angle: gradientAngle
        property real dotMinSize: halftoneDotMin
        property real dotMaxSize: halftoneDotMax
        property real gradientStart: halftoneStart
        property real gradientEnd: halftoneEnd
        property vector4d dotColor: {
            const c = halftoneDotColor || Qt.rgba(1, 1, 1, 1);
            return Qt.vector4d(c.r, c.g, c.b, c.a);
        }
        property vector4d backgroundColor: {
            const c = halftoneBackgroundColor || Qt.rgba(0, 0.5, 1, 1);
            return Qt.vector4d(c.r, c.g, c.b, c.a);
        }
        property real canvasWidth: width
        property real canvasHeight: height

        vertexShader: "halftone.vert.qsb"
        fragmentShader: "halftone.frag.qsb"
    }

    // Shadow effect
    layer.enabled: enableShadow
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowHorizontalOffset: Config.theme.shadowXOffset
        shadowVerticalOffset: Config.theme.shadowYOffset
        shadowBlur: Config.theme.shadowBlur
        shadowColor: Config.resolveColor(Config.theme.shadowColor)
        shadowOpacity: Config.theme.shadowOpacity
    }

    // Border overlay to avoid ClippingRectangle artifacts
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        border.color: Config.resolveColor(borderData[0])
        border.width: borderData[1]
    }
}
