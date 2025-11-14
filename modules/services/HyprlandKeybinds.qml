import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.config

QtObject {
    id: root

    property Process hyprctlProcess: Process {}

    property Timer applyTimer: Timer {
        interval: 100
        repeat: false
        onTriggered: applyKeybindsInternal()
    }

    function applyKeybinds() {
        applyTimer.restart();
    }

    function applyKeybindsInternal() {
        // Verificar que el adapter esté cargado
        if (!Config.keybindsLoader.loaded) {
            console.log("HyprlandKeybinds: Esperando que se cargue el adapter...");
            return;
        }

        console.log("HyprlandKeybinds: Aplicando keybindings...");

        // Primero unbind todas las keybindings de Ambxst para evitar duplicados
        const unbindCommand = "keyword unbind SUPER,R; keyword unbind SUPER,T; keyword unbind SUPER,V; keyword unbind SUPER,PERIOD; keyword unbind SUPER,D; keyword unbind SUPER,Q; keyword unbind SUPER,N; keyword unbind SUPER,COMMA; keyword unbind SUPER,A; keyword unbind SUPER,TAB; keyword unbind SUPER,ESCAPE; keyword unbind SUPER SHIFT,C; keyword unbind SUPER,L";

        // Construir batch command con todos los binds
        let batchCommands = [];

        // Helper function para formatear modifiers
        function formatModifiers(modifiers) {
            if (!modifiers || modifiers.length === 0) return "";
            return modifiers.join(" ");
        }

        // Helper function para crear un bind command
        function createBindCommand(keybind) {
            const mods = formatModifiers(keybind.modifiers);
            const key = keybind.key;
            const dispatcher = keybind.dispatcher;
            const argument = keybind.argument;
            return `keyword bind ${mods},${key},${dispatcher},${argument}`;
        }

        // Launcher keybinds
        const launcher = Config.keybindsLoader.adapter.launcher;
        batchCommands.push(createBindCommand(launcher.apps));
        batchCommands.push(createBindCommand(launcher.tmux));
        batchCommands.push(createBindCommand(launcher.clipboard));
        batchCommands.push(createBindCommand(launcher.emoji));

        // Dashboard keybinds
        const dashboard = Config.keybindsLoader.adapter.dashboard;
        batchCommands.push(createBindCommand(dashboard.widgets));
        batchCommands.push(createBindCommand(dashboard.pins));
        batchCommands.push(createBindCommand(dashboard.kanban));
        batchCommands.push(createBindCommand(dashboard.wallpapers));
        batchCommands.push(createBindCommand(dashboard.assistant));

        // System keybinds
        const system = Config.keybindsLoader.adapter.system;
        batchCommands.push(createBindCommand(system.overview));
        batchCommands.push(createBindCommand(system.powermenu));
        batchCommands.push(createBindCommand(system.config));
        batchCommands.push(createBindCommand(system.lockscreen));

        // Combinar unbind y bind en un solo batch
        const fullBatchCommand = unbindCommand + "; " + batchCommands.join("; ");

        console.log("HyprlandKeybinds: Ejecutando batch command");
        hyprctlProcess.command = ["sh", "-c", `hyprctl --batch "${fullBatchCommand}"`];
        hyprctlProcess.running = true;
    }

    property Connections configConnections: Connections {
        target: Config.keybindsLoader
        function onFileChanged() {
            applyKeybinds();
        }
        function onLoaded() {
            applyKeybinds();
        }
    }

    property Connections hyprlandConnections: Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "configreloaded") {
                console.log("HyprlandKeybinds: Detectado configreloaded, reaplicando keybindings...");
                applyKeybinds();
            }
        }
    }

    Component.onCompleted: {
        // Si el loader ya está cargado, aplicar inmediatamente
        if (Config.keybindsLoader.loaded) {
            applyKeybinds();
        }
    }
}
