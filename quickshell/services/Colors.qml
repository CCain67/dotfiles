pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

// The palette, as a *mapping* rather than as data.
//
// Every colour below is a binding onto Theme.raw — the active theme's ~22 raw
// colours — so switching themes repaints the whole shell with no call site
// changing. `readonly` is kept throughout: it forbids assignment, not
// re-evaluation, and these are bindings.
//
// The M3 role mapping lives here and only here. A theme file supplies raw
// colours; the 53 m3* roles are derived, so any new theme gets the full set for
// free. The mapping is: primary=blue, secondary=purple, tertiary=yellow,
// error=red, success=green, with each accent's dark variant as its container.
Singleton {
    id: root

    readonly property var t: Theme.raw
    readonly property bool light: Theme.light

    // Raw theme colors
    readonly property color red: t.red
    readonly property color dark_red: t.darkRed
    readonly property color orange: t.orange
    readonly property color dark_orange: t.darkOrange
    readonly property color yellow: t.yellow
    readonly property color dark_yellow: t.darkYellow
    readonly property color green: t.green
    readonly property color dark_green: t.darkGreen
    readonly property color cyan: t.cyan
    readonly property color dark_cyan: t.darkCyan
    readonly property color blue: t.blue
    readonly property color dark_blue: t.darkBlue
    readonly property color purple: t.purple
    readonly property color dark_purple: t.darkPurple

    readonly property color grey: t.grey
    readonly property color greyDark: t.greyDark
    readonly property color greyLight: t.greyLight

    readonly property color background: t.background
    readonly property color backgroundDark: t.backgroundDark
    readonly property color backgroundLight: t.backgroundLight
    readonly property color foreground: t.foreground
    readonly property color foregroundDark: t.foregroundDark
    readonly property color foregroundLight: t.foregroundLight

    // The surface ladder needs two shades that are not accents and not part of
    // the background triple. Gruvbox's ladder is not a uniform lightness ramp, so
    // these are explicit theme fields; the derived fallbacks are only for a theme
    // file that omits them.
    readonly property color surfaceLowest: t.surfaceLowest ?? Qt.darker(t.backgroundDark, 1.25)
    readonly property color surfaceHigh: t.surfaceHigh ?? Qt.lighter(t.background, 1.15)

    // M3-compatible palette, derived from the raw colors above
    readonly property QtObject palette: QtObject {
        // Backgrounds / surfaces
        readonly property color m3background: root.background
        readonly property color m3onBackground: root.foreground
        readonly property color m3surface: root.background
        readonly property color m3surfaceDim: root.backgroundDark
        readonly property color m3surfaceBright: root.backgroundLight
        readonly property color m3surfaceContainerLowest: root.surfaceLowest
        readonly property color m3surfaceContainerLow: root.backgroundDark
        readonly property color m3surfaceContainer: root.background
        readonly property color m3surfaceContainerHigh: root.surfaceHigh
        readonly property color m3surfaceContainerHighest: root.backgroundLight
        readonly property color m3onSurface: root.foreground
        readonly property color m3surfaceVariant: root.backgroundLight
        readonly property color m3onSurfaceVariant: root.greyLight
        readonly property color m3inverseSurface: root.foreground
        readonly property color m3inverseOnSurface: root.background
        readonly property color m3outline: root.grey
        readonly property color m3outlineVariant: root.greyDark
        readonly property color m3shadow: root.t.shadow ?? "#000000"
        readonly property color m3scrim: root.t.scrim ?? "#000000"
        readonly property color m3surfaceTint: root.blue

        // Primary — blue
        readonly property color m3primary: root.blue
        readonly property color m3onPrimary: root.backgroundDark
        readonly property color m3primaryContainer: root.dark_blue
        readonly property color m3onPrimaryContainer: root.foregroundLight
        readonly property color m3inversePrimary: root.dark_blue
        readonly property color m3primaryFixed: root.blue
        readonly property color m3primaryFixedDim: root.dark_blue
        readonly property color m3onPrimaryFixed: root.backgroundDark
        readonly property color m3onPrimaryFixedVariant: root.background

        // Secondary — purple
        readonly property color m3secondary: root.purple
        readonly property color m3onSecondary: root.backgroundDark
        readonly property color m3secondaryContainer: root.dark_purple
        readonly property color m3onSecondaryContainer: root.foregroundLight
        readonly property color m3secondaryFixed: root.purple
        readonly property color m3secondaryFixedDim: root.dark_purple
        readonly property color m3onSecondaryFixed: root.backgroundDark
        readonly property color m3onSecondaryFixedVariant: root.background

        // Tertiary — yellow
        readonly property color m3tertiary: root.yellow
        readonly property color m3onTertiary: root.backgroundDark
        readonly property color m3tertiaryContainer: root.dark_yellow
        readonly property color m3onTertiaryContainer: root.foregroundLight
        readonly property color m3tertiaryFixed: root.yellow
        readonly property color m3tertiaryFixedDim: root.dark_yellow
        readonly property color m3onTertiaryFixed: root.backgroundDark
        readonly property color m3onTertiaryFixedVariant: root.background

        // Error — red
        readonly property color m3error: root.red
        readonly property color m3onError: root.backgroundDark
        readonly property color m3errorContainer: root.dark_red
        readonly property color m3onErrorContainer: root.foregroundLight

        // Success — green
        readonly property color m3success: root.green
        readonly property color m3onSuccess: root.backgroundDark
        readonly property color m3successContainer: root.dark_green
        readonly property color m3onSuccessContainer: root.foregroundLight
    }
}
