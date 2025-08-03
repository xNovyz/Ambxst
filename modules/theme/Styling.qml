pragma Singleton
import QtQuick
import qs.config

QtObject {
    readonly property string defaultFont: Configuration.defaultFont
    readonly property string iconFont: Configuration.iconFont === "nerd" ? "Symbols Nerd Font" : Configuration.iconFont === "tabler" ? "tabler-icons" : Configuration.iconFont === "phosphor" ? "Phosphor-Bold" : ""
}
