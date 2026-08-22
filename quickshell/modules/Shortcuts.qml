import Quickshell
import Quickshell.Hyprland
import "../services"

Scope {
    GlobalShortcut {
        name: "launcher"
        description: "Toggle app launcher"
        onPressed: Visibilities.visibilities.launcher = !Visibilities.visibilities.launcher
    }

    GlobalShortcut {
        name: "dashboard"
        description: "Toggle dashboard"
        onPressed: Visibilities.visibilities.dashboard = !Visibilities.visibilities.dashboard
    }

    GlobalShortcut {
        name: "session"
        description: "Toggle power menu"
        onPressed: Visibilities.visibilities.session = !Visibilities.visibilities.session
    }
}
