import QtQuick
import Quickshell.Hyprland._GlobalShortcuts
import qs.modules.globals
import qs.modules.services

Item {
    id: root

    readonly property string appId: "ambxst"
    readonly property int mediaSeekStepMs: 5000

    function toggleSimpleModule(moduleName) {
        if (Visibilities.currentActiveModule === moduleName) {
            Visibilities.setActiveModule("");
        } else {
            Visibilities.setActiveModule(moduleName);
        }
    }

    function toggleLauncherTab(tabIndex) {
        const isActive = Visibilities.currentActiveModule === "launcher";
        if (isActive && GlobalStates.launcherCurrentTab === tabIndex) {
            GlobalStates.clearLauncherState();
            Visibilities.setActiveModule("");
            return;
        }

        GlobalStates.launcherCurrentTab = tabIndex;
        if (!isActive) {
            Visibilities.setActiveModule("launcher");
        }
    }

    function toggleDashboardTab(tabIndex) {
        const isActive = Visibilities.currentActiveModule === "dashboard";
        if (isActive && GlobalStates.dashboardCurrentTab === tabIndex) {
            Visibilities.setActiveModule("");
            return;
        }

        GlobalStates.dashboardCurrentTab = tabIndex;
        if (!isActive) {
            Visibilities.setActiveModule("dashboard");
        }
    }

    function seekActivePlayer(offset) {
        const player = MprisController.activePlayer;
        if (!player || !player.canSeek) {
            return;
        }

        const maxLength = typeof player.length === "number" && !isNaN(player.length)
                ? player.length
                : Number.MAX_SAFE_INTEGER;
        const clamped = Math.max(0, Math.min(maxLength, player.position + offset));
        player.position = clamped;
    }

    GlobalShortcut {
        appid: root.appId
        name: "overview"
        description: "Toggle window overview"

        onPressed: toggleSimpleModule("overview")
    }

    GlobalShortcut {
        appid: root.appId
        name: "powermenu"
        description: "Toggle power menu"

        onPressed: toggleSimpleModule("powermenu")
    }

    // Launcher tab shortcuts
    GlobalShortcut {
        appid: root.appId
        name: "launcher-apps"
        description: "Open launcher apps tab"

        onPressed: toggleLauncherTab(0)
    }

    GlobalShortcut {
        appid: root.appId
        name: "launcher-tmux"
        description: "Open launcher tmux tab"

        onPressed: toggleLauncherTab(1)
    }

    GlobalShortcut {
        appid: root.appId
        name: "launcher-clipboard"
        description: "Open launcher clipboard tab"

        onPressed: toggleLauncherTab(2)
    }

    // Dashboard tab shortcuts
    GlobalShortcut {
        appid: root.appId
        name: "dashboard-widgets"
        description: "Open dashboard widgets tab"

        onPressed: toggleDashboardTab(0)
    }

    GlobalShortcut {
        appid: root.appId
        name: "dashboard-pins"
        description: "Open dashboard pins tab"

        onPressed: toggleDashboardTab(1)
    }

    GlobalShortcut {
        appid: root.appId
        name: "dashboard-kanban"
        description: "Open dashboard kanban tab"

        onPressed: toggleDashboardTab(2)
    }

    GlobalShortcut {
        appid: root.appId
        name: "dashboard-wallpapers"
        description: "Open dashboard wallpapers tab"

        onPressed: toggleDashboardTab(3)
    }

    GlobalShortcut {
        appid: root.appId
        name: "dashboard-assistant"
        description: "Open dashboard assistant tab"

        onPressed: toggleDashboardTab(4)
    }

    GlobalShortcut {
        appid: root.appId
        name: "launcher-emoji"
        description: "Open launcher emoji tab"

        onPressed: toggleLauncherTab(3)
    }

    // Media player shortcuts
    GlobalShortcut {
        appid: root.appId
        name: "media-seek-backward"
        description: "Seek backward in media player"

        onPressed: seekActivePlayer(-mediaSeekStepMs)
    }

    GlobalShortcut {
        appid: root.appId
        name: "media-seek-forward"
        description: "Seek forward in media player"

        onPressed: seekActivePlayer(mediaSeekStepMs)
    }

    GlobalShortcut {
        appid: root.appId
        name: "media-play-pause"
        description: "Toggle play/pause in media player"

        onPressed: {
            if (MprisController.canTogglePlaying) {
                MprisController.togglePlaying();
            }
        }
    }
}
