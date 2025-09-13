import QtQuick
import qs.modules.globals
import qs.modules.services
import qs.config
import qs.modules.components

ToggleButton {
    buttonIcon: Config.bar.launcherIcon
    tooltipText: "Open Application Launcher"

    onToggle: function () {
        if (GlobalStates.launcherOpen) {
            GlobalStates.clearLauncherState();
            Visibilities.setActiveModule("");
        } else {
            GlobalStates.launcherCurrentTab = 0;
            Visibilities.setActiveModule("launcher");
        }
    }
}
