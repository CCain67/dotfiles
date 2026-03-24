pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../components"
import "../../components/containers"
import "../../services"
import "../../config"
import "../bar"

// Single-monitor drawers: full-screen overlay containing bar, border, and panel slots.
// Input mask punches out the empty interior so clicks pass through to the desktop.
Scope {
    id: root

    readonly property ShellScreen screen: Screens.screen

    Exclusions {
        screen: root.screen
        bar: bar
    }

    StyledWindow {
        id: win

        screen: root.screen
        name: "drawers"
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: visibilities.launcher || visibilities.session
            ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        // XOR mask: start with full window, subtract interior → only bar + border edges are interactive
        mask: Region {
            x: bar.implicitWidth
            y: Config.border.thickness
            width: win.width - bar.implicitWidth - Config.border.thickness
            height: win.height - Config.border.thickness * 2
            intersection: Intersection.Xor
        }

        DrawerVisibilities {
            id: visibilities
        }

        // Screen border drawn behind everything
        Border {
            bar: bar
        }

        // Panel slide-in backgrounds (empty Phase 2 stub)
        Backgrounds {
            panels: panels
            bar: bar
        }

        // Panel content area — populated Phase 3+
        Panels {
            id: panels

            anchors.fill: parent
            anchors.topMargin: Config.border.thickness
            anchors.bottomMargin: Config.border.thickness
            anchors.leftMargin: bar.implicitWidth
            anchors.rightMargin: Config.border.thickness

            visibilities: visibilities
        }

        // Left-edge bar
        BarWrapper {
            id: bar

            anchors.top: parent.top
            anchors.bottom: parent.bottom

            screen: root.screen
            visibilities: visibilities
        }
    }
}
