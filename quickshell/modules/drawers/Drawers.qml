pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../../components"
import "../../components/containers"
import "../../services"
import "../../config"
import "../bar"
import "../osd" as Osd
import "../launcher" as Launcher

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
        WlrLayershell.keyboardFocus: (Visibilities.visibilities.launcher || Visibilities.visibilities.session || Visibilities.visibilities.dashboard)
            ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        // XOR mask: start with full window, subtract interior → only bar + border edges are interactive.
        // Cleared when an overlay panel (launcher, osd, dashboard) is open so the panel receives input.
        mask: (Visibilities.visibilities.osd || Visibilities.visibilities.launcher || Visibilities.visibilities.dashboard) ? null : interiorMask

        Region {
            id: interiorMask
            x: bar.implicitWidth
            y: Config.border.thickness
            width: win.width - bar.implicitWidth - Config.border.thickness
            height: win.height - Config.border.thickness * 2
            intersection: Intersection.Xor
        }

        Item {
            anchors.fill: parent
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                blurMax: 14
                shadowColor: Qt.alpha(Colors.palette.m3shadow, 0.8)
            }

            // Screen border drawn behind everything
            Border {
                bar: bar
            }

            // Panel slide-in backgrounds
            Backgrounds {
                panels: panels
                bar: bar
                osd: osdWrapper
                launcher: launcherWrapper
            }
        }

        // Panel content area — populated Phase 3+
        Panels {
            id: panels

            anchors.fill: parent
            anchors.topMargin: Config.border.thickness
            anchors.bottomMargin: Config.border.thickness
            anchors.leftMargin: bar.implicitWidth
            anchors.rightMargin: Config.border.thickness

            visibilities: Visibilities.visibilities
        }

        // Left-edge launcher — anchored at bar.right, expands rightward
        Launcher.Wrapper {
            id: launcherWrapper

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: bar.right

            visibilities: Visibilities.visibilities
        }

        // Right-edge OSD
        Osd.Wrapper {
            id: osdWrapper

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right

            visibilities: Visibilities.visibilities
        }

        // Left-edge bar
        BarWrapper {
            id: bar

            anchors.top: parent.top
            anchors.bottom: parent.bottom

            screen: root.screen
            visibilities: Visibilities.visibilities
        }
    }
}
