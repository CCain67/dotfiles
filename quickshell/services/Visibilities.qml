pragma Singleton

import Quickshell
import "../components"

// Single-monitor — one DrawerVisibilities instance, no screen map needed
Singleton {
    readonly property DrawerVisibilities visibilities: DrawerVisibilities {}

    function getForActive(): DrawerVisibilities {
        return visibilities;
    }
}
