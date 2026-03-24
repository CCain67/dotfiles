pragma Singleton

import Quickshell

// Single-monitor — no exclusion logic needed
Singleton {
    readonly property ShellScreen screen: Quickshell.screens[0]
    readonly property list<ShellScreen> screens: Quickshell.screens
}
