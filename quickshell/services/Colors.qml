pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property bool light: false

    // Raw Gruvbox Material Dark colors
    readonly property color red: "#ea6962"
    readonly property color dark_red: "#c14a4a"
    readonly property color orange: "#e78a4e"
    readonly property color dark_orange: "#c35e0a"
    readonly property color yellow: "#d8a657"
    readonly property color dark_yellow: "#b47109"
    readonly property color green: "#a9b665"
    readonly property color dark_green: "#6c782e"
    readonly property color cyan: "#89b482"
    readonly property color dark_cyan: "#4c7a5d"
    readonly property color blue: "#7daea3"
    readonly property color dark_blue: "#45707a"
    readonly property color purple: "#d3869b"
    readonly property color dark_purple: "#945e80"

    readonly property color grey: "#928374"
    readonly property color greyDark: "#7c6f64"
    readonly property color greyLight: "#a89984"

    readonly property color background: "#32302f"
    readonly property color backgroundDark: "#252423"
    readonly property color backgroundLight: "#504945"
    readonly property color foreground: "#d4be98"
    readonly property color foregroundDark: "#ddc7a1"
    readonly property color foregroundLight: "#ebdbb2"

    // M3-compatible palette (Gruvbox Material Dark mapping)
    readonly property QtObject palette: QtObject {
        // Backgrounds / surfaces
        readonly property color m3background: "#32302f"
        readonly property color m3onBackground: "#d4be98"
        readonly property color m3surface: "#32302f"
        readonly property color m3surfaceDim: "#252423"
        readonly property color m3surfaceBright: "#504945"
        readonly property color m3surfaceContainerLowest: "#1d1c1a"
        readonly property color m3surfaceContainerLow: "#252423"
        readonly property color m3surfaceContainer: "#32302f"
        readonly property color m3surfaceContainerHigh: "#3c3836"
        readonly property color m3surfaceContainerHighest: "#504945"
        readonly property color m3onSurface: "#d4be98"
        readonly property color m3surfaceVariant: "#504945"
        readonly property color m3onSurfaceVariant: "#a89984"
        readonly property color m3inverseSurface: "#d4be98"
        readonly property color m3inverseOnSurface: "#32302f"
        readonly property color m3outline: "#928374"
        readonly property color m3outlineVariant: "#7c6f64"
        readonly property color m3shadow: "#000000"
        readonly property color m3scrim: "#000000"
        readonly property color m3surfaceTint: "#7daea3"

        // Primary — blue
        readonly property color m3primary: "#7daea3"
        readonly property color m3onPrimary: "#252423"
        readonly property color m3primaryContainer: "#45707a"
        readonly property color m3onPrimaryContainer: "#ebdbb2"
        readonly property color m3inversePrimary: "#45707a"
        readonly property color m3primaryFixed: "#7daea3"
        readonly property color m3primaryFixedDim: "#45707a"
        readonly property color m3onPrimaryFixed: "#252423"
        readonly property color m3onPrimaryFixedVariant: "#32302f"

        // Secondary — purple
        readonly property color m3secondary: "#d3869b"
        readonly property color m3onSecondary: "#252423"
        readonly property color m3secondaryContainer: "#945e80"
        readonly property color m3onSecondaryContainer: "#ebdbb2"
        readonly property color m3secondaryFixed: "#d3869b"
        readonly property color m3secondaryFixedDim: "#945e80"
        readonly property color m3onSecondaryFixed: "#252423"
        readonly property color m3onSecondaryFixedVariant: "#32302f"

        // Tertiary — yellow
        readonly property color m3tertiary: "#d8a657"
        readonly property color m3onTertiary: "#252423"
        readonly property color m3tertiaryContainer: "#b47109"
        readonly property color m3onTertiaryContainer: "#ebdbb2"
        readonly property color m3tertiaryFixed: "#d8a657"
        readonly property color m3tertiaryFixedDim: "#b47109"
        readonly property color m3onTertiaryFixed: "#252423"
        readonly property color m3onTertiaryFixedVariant: "#32302f"

        // Error — red
        readonly property color m3error: "#ea6962"
        readonly property color m3onError: "#252423"
        readonly property color m3errorContainer: "#c14a4a"
        readonly property color m3onErrorContainer: "#ebdbb2"

        // Success — green
        readonly property color m3success: "#a9b665"
        readonly property color m3onSuccess: "#252423"
        readonly property color m3successContainer: "#6c782e"
        readonly property color m3onSuccessContainer: "#ebdbb2"
    }
}
