import Quickshell
import Quickshell.Hyprland
import "../services"

Scope {
    // Both shortcuts open the same dashboard window, just on different pages.
    // Each toggles: pressing it while its own page is up closes the dashboard,
    // pressing it while the other page is up switches to this one.
    GlobalShortcut {
        name: "launcher"
        description: "Toggle app launcher"
        onPressed: {
            const vis = Visibilities.visibilities;
            if (vis.dashboard && vis.page === "apps") {
                vis.dashboard = false;
            } else {
                vis.page = "apps";
                vis.dashboard = true;
            }
        }
    }

    GlobalShortcut {
        name: "dashboard"
        description: "Toggle dashboard"
        onPressed: {
            const vis = Visibilities.visibilities;
            if (vis.dashboard && vis.page === "info") {
                vis.dashboard = false;
            } else {
                vis.page = "info";
                vis.dashboard = true;
            }
        }
    }

    GlobalShortcut {
        name: "session"
        description: "Toggle power menu"
        onPressed: Visibilities.visibilities.session = !Visibilities.visibilities.session
    }
}
