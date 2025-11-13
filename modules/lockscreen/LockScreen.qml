pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.modules.components
import qs.modules.corners
import qs.modules.theme
import qs.modules.globals
import qs.config

PanelWindow {
    id: root

    property bool unlocking: false
    property bool authenticating: false
    property string errorMessage: ""
    property int failLockSecondsLeft: 0

    visible: GlobalStates.lockscreenVisible || unlocking
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    focusable: true
    mask: null
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "ambxst-lockscreen"

    // Screen capture background
    ScreencopyView {
        id: screencopyBackground
        anchors.fill: parent
        captureSource: root.screen
        live: false
        paintCursor: false
        visible: false
    }

    // Blur effect
    MultiEffect {
        id: blurEffect
        anchors.fill: parent
        source: screencopyBackground
        autoPaddingEnabled: false
        blurEnabled: true
        blur: 0
        blurMax: 64
        visible: false
        opacity: (GlobalStates.lockscreenVisible && !unlocking) ? 1 : 0

        property real zoomScale: (GlobalStates.lockscreenVisible && !unlocking) ? 1.1 : 1.0

        transform: Scale {
            origin.x: blurEffect.width / 2
            origin.y: blurEffect.height / 2
            xScale: blurEffect.zoomScale
            yScale: blurEffect.zoomScale
        }

        Behavior on blur {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutCubic
            }
        }

        Behavior on zoomScale {
            NumberAnimation {
                duration: Config.animDuration * 1.5
                easing.type: Easing.OutCubic
            }
        }
    }

    // Overlay for dimming
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: (GlobalStates.lockscreenVisible && !unlocking) ? 0.25 : 0

        property real zoomScale: (GlobalStates.lockscreenVisible && !unlocking) ? 1.1 : 1.0

        transform: Scale {
            origin.x: parent.width / 2
            origin.y: parent.height / 2
            xScale: parent.zoomScale
            yScale: parent.zoomScale
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutCubic
            }
        }

        Behavior on zoomScale {
            NumberAnimation {
                duration: Config.animDuration * 1.5
                easing.type: Easing.OutCubic
            }
        }
    }

    // Password input container (slides from bottom)
    Item {
        id: passwordContainer
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 32
        }
        width: 400
        height: 80

        transform: Translate {
            y: (GlobalStates.lockscreenVisible && !unlocking) ? 0 : passwordContainer.height + 32

            Behavior on y {
                NumberAnimation {
                    duration: Config.animDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        // Password input with avatar
        BgRect {
            id: passwordInputBox
            anchors.centerIn: parent
            width: parent.width
            height: 80
            radius: Config.roundness > 0 ? (height / 2) * (Config.roundness / 16) : 0

            property real shakeOffset: 0

            transform: Translate {
                x: passwordInputBox.shakeOffset
            }

            Row {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // Avatar (48x48)
                Rectangle {
                    id: avatarContainer
                    width: 48
                    height: 48
                    radius: Config.roundness > 0 ? (height / 2) * (Config.roundness / 16) : 0
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter

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

                    // Fallback icon if image not found
                    Text {
                        anchors.centerIn: parent
                        text: "👤"
                        font.pixelSize: 24
                        visible: userAvatar.status !== Image.Ready
                    }
                }

                // Password field
                Rectangle {
                    width: parent.width - avatarContainer.width - parent.spacing
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter
                    color: Colors.surface
                    radius: Config.roundness > 0 ? (height / 2) * (Config.roundness / 16) : 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 8

                        // User icon
                        Text {
                            text: Icons.user
                            font.family: Icons.font
                            font.pixelSize: 24
                            color: Colors.overBackground
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            Layout.alignment: Qt.AlignVCenter
                            z: 10
                        }

                        // Text field
                        TextField {
                            id: passwordInput
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            placeholderText: usernameCollector.text.trim()
                            placeholderTextColor: Colors.outline
                            font.family: Config.theme.font
                            font.pixelSize: Config.theme.fontSize
                            color: Colors.overBackground
                            background: null
                            echoMode: TextInput.Password
                            verticalAlignment: TextInput.AlignVCenter
                            enabled: !authenticating

                            onAccepted: {
                                if (passwordInput.text.trim() === "") return;
                                
                                // Guardar contraseña y limpiar campo inmediatamente
                                authPasswordHolder.password = passwordInput.text;
                                passwordInput.text = "";
                                
                                authenticating = true;
                                errorMessage = "";
                                pamAuth.running = true;
                            }

                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Escape) {
                                    unlocking = true;
                                    unlockResetTimer.start();
                                    GlobalStates.lockscreenVisible = false;
                                    passwordInput.text = "";
                                    errorMessage = "";
                                    event.accepted = true;
                                }
                            }

                            Component.onCompleted: {
                                if (GlobalStates.lockscreenVisible) {
                                    passwordInput.forceActiveFocus();
                                }
                            }
                        }
                    }
                }
            }

            SequentialAnimation {
                id: wrongPasswordAnim
                NumberAnimation {
                    target: passwordInputBox
                    property: "shakeOffset"
                    to: 10
                    duration: 50
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: passwordInputBox
                    property: "shakeOffset"
                    to: -10
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: passwordInputBox
                    property: "shakeOffset"
                    to: 10
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: passwordInputBox
                    property: "shakeOffset"
                    to: 0
                    duration: 50
                    easing.type: Easing.InOutQuad
                }
                ScriptAction {
                    script: {
                        passwordInput.text = "";
                        authenticating = false;
                    }
                }
            }
        }

        // Error message text
        Text {
            anchors {
                top: passwordInputBox.bottom
                topMargin: 8
                horizontalCenter: passwordInputBox.horizontalCenter
            }
            
            function formatErrorMessage() {
                if (failLockSecondsLeft > 0) {
                    const minutes = Math.floor(failLockSecondsLeft / 60);
                    const seconds = failLockSecondsLeft % 60;
                    
                    if (minutes > 0) {
                        return `${errorMessage} (${minutes}m ${seconds}s restantes)`;
                    } else {
                        return `${errorMessage} (${seconds}s restantes)`;
                    }
                }
                return errorMessage;
            }
            
            text: formatErrorMessage()
            font.family: Config.theme.font
            font.pixelSize: Config.theme.fontSize - 2
            color: Colors.error || "#f44336"
            visible: errorMessage !== ""
        }
    }

    // Timer to animate blur after capture
    Timer {
        id: blurAnimTimer
        interval: 50
        onTriggered: {
            blurEffect.blur = 1;
        }
    }

    // Timer to reset unlocking state after animation starts
    Timer {
        id: unlockResetTimer
        interval: Config.animDuration
        onTriggered: {
            unlocking = false;
        }
    }

    // Focus the input when lockscreen becomes visible
    onVisibleChanged: {
        if (visible && GlobalStates.lockscreenVisible) {
            blurEffect.blur = 0;
            screencopyBackground.captureFrame();
            blurEffect.visible = true;
            blurAnimTimer.start();
            passwordInput.forceActiveFocus();
        } else if (!visible) {
            blurAnimTimer.stop();
            unlockResetTimer.stop();
            failLockCountdown.stop();
            blurEffect.visible = false;
            blurEffect.blur = 0;
            errorMessage = "";
            failLockSecondsLeft = 0;
        }
    }

    // Processes for user info
    Process {
        id: usernameProc
        command: ["whoami"]
        running: true

        stdout: StdioCollector {
            id: usernameCollector
            waitForEnd: true
        }
    }

    Process {
        id: hostnameProc
        command: ["hostname"]
        running: true

        stdout: StdioCollector {
            id: hostnameCollector
            waitForEnd: true
        }
    }

    // Holder temporal para la contraseña durante autenticación
    QtObject {
        id: authPasswordHolder
        property string password: ""
    }

    // Proceso para verificar tiempo de faillock
    Process {
        id: failLockCheck
        command: ["bash", "-c", `faillock --user '${usernameCollector.text.trim()}' 2>/dev/null | grep -oP 'left \\K[0-9]+' | head -1`]
        running: false

        stdout: StdioCollector {
            id: failLockCollector
            
            onStreamFinished: {
                const output = text.trim();
                const seconds = parseInt(output);
                
                if (!isNaN(seconds) && seconds > 0) {
                    failLockSecondsLeft = seconds;
                    failLockCountdown.start();
                } else {
                    failLockSecondsLeft = 0;
                }
            }
        }
    }

    // Timer para actualizar el countdown de faillock
    Timer {
        id: failLockCountdown
        interval: 1000
        repeat: true
        running: false

        onTriggered: {
            if (failLockSecondsLeft > 0) {
                failLockSecondsLeft--;
            } else {
                stop();
                errorMessage = "";
            }
        }
    }

    // PAM authentication process
    Process {
        id: pamAuth
        command: ["modules/lockscreen/pam-auth-stdin.sh"]
        running: false
        environment: {
            "PAM_USER": usernameCollector.text.trim(),
            "PAM_PASSWORD": authPasswordHolder.password
        }

        onExited: exitCode => {
            // Limpiar contraseña
            authPasswordHolder.password = "";

            if (exitCode === 0) {
                // Autenticación exitosa
                unlocking = true;
                unlockResetTimer.start();
                GlobalStates.lockscreenVisible = false;
                errorMessage = "";
                authenticating = false;
            } else {
                // Error de autenticación
                let msg = "";
                switch (exitCode) {
                    case 10:
                        msg = "Usuario no encontrado";
                        break;
                    case 11:
                        msg = "Contraseña incorrecta";
                        break;
                    case 12:
                        msg = "Error de autenticación";
                        break;
                    case 20:
                        msg = "Cuenta expirada";
                        break;
                    case 21:
                        msg = "Debe cambiar su contraseña";
                        break;
                    case 22:
                        msg = "Cuenta bloqueada";
                        break;
                    case 23:
                        msg = "Error de estado de cuenta";
                        break;
                    case 30:
                        // Faillock detectado - verificar tiempo restante
                        failLockCheck.running = true;
                        msg = "Cuenta bloqueada por intentos fallidos";
                        break;
                    case 100:
                        msg = "Error: parámetro inválido";
                        break;
                    case 101:
                        msg = "Error leyendo contraseña";
                        break;
                    case 102:
                        msg = "Error inicializando PAM";
                        break;
                    case 103:
                        msg = "Timeout esperando contraseña";
                        break;
                    case 104:
                        msg = "Error interno";
                        break;
                    default:
                        msg = `Error desconocido (${exitCode})`;
                }
                
                errorMessage = msg;
                console.warn("PAM auth failed:", exitCode, msg);
                wrongPasswordAnim.start();
            }
        }
    }

    // Screen corners
    RoundCorner {
        id: topLeft
        size: Config.roundness > 0 ? Config.roundness + 4 : 0
        anchors.left: parent.left
        anchors.top: parent.top
        corner: RoundCorner.CornerEnum.TopLeft
    }

    RoundCorner {
        id: topRight
        size: Config.roundness > 0 ? Config.roundness + 4 : 0
        anchors.right: parent.right
        anchors.top: parent.top
        corner: RoundCorner.CornerEnum.TopRight
    }

    RoundCorner {
        id: bottomLeft
        size: Config.roundness > 0 ? Config.roundness + 4 : 0
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        corner: RoundCorner.CornerEnum.BottomLeft
    }

    RoundCorner {
        id: bottomRight
        size: Config.roundness > 0 ? Config.roundness + 4 : 0
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        corner: RoundCorner.CornerEnum.BottomRight
    }

    // Capture all keyboard input
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            unlocking = true;
            unlockResetTimer.start();
            GlobalStates.lockscreenVisible = false;
            passwordInput.text = "";
            event.accepted = true;
        }
    }
}
