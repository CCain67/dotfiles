pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../components"
import "../../../config"
import "../../../services"

// 2x2 grid of the session power actions, mirroring the session menu but
// two-stage: the first click arms a tile, the second runs the command. Arming
// a tile disarms any other, and an armed tile lapses after `disarmDelay`.
Card {
    id: root

    required property DrawerVisibilities visibilities

    readonly property int disarmDelay: 3000

    // The armed tile, or null. Bound by the tiles themselves on click.
    property Item armed: null

    title: "Power"
    icon: "power_settings_new"

    Timer {
        id: disarmTimer

        interval: root.disarmDelay
        onTriggered: root.armed = null
    }

    onArmedChanged: {
        if (armed)
            disarmTimer.restart();
        else
            disarmTimer.stop();
    }

    // Never leave a tile armed across an open/close of the dashboard.
    Connections {
        target: root.visibilities

        function onDashboardChanged(): void {
            root.armed = null;
        }
    }

    GridLayout {
        anchors.fill: parent
        columns: 2
        rowSpacing: Appearance.spacing.normal
        columnSpacing: Appearance.spacing.normal

        PowerTile {
            label: "Log out"
            icon: Config.session.icons.logout
            command: Config.session.commands.logout
        }

        PowerTile {
            label: "Shut down"
            icon: Config.session.icons.shutdown
            command: Config.session.commands.shutdown
        }

        PowerTile {
            label: "Hibernate"
            icon: Config.session.icons.hibernate
            command: Config.session.commands.hibernate
        }

        PowerTile {
            label: "Reboot"
            icon: Config.session.icons.reboot
            command: Config.session.commands.reboot
        }
    }

    // Border/shadow match cards/Tile.qml so the grid sits at the same
    // elevation as the Specs and Resources tiles.
    component PowerTile: StyledRect {
        id: tile

        required property string label
        required property string icon
        required property list<string> command

        readonly property bool armed: root.armed === tile
        readonly property color accent: armed ? Colors.red : Colors.palette.m3onSurface

        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: Appearance.rounding.small
        color: armed ? Qt.alpha(Colors.red, 0.18) : Colors.palette.m3surfaceContainerHighest
        border.width: Appearance.outline.width
        border.color: Appearance.outline.color

        layer.enabled: !Theme.flat
        layer.effect: Elevation {
            level: "low"
        }

        StateLayer {
            function onClicked(): void {
                if (tile.armed) {
                    root.armed = null;
                    root.visibilities.dashboard = false;
                    Quickshell.execDetached(tile.command);
                } else {
                    root.armed = tile;
                }
            }
            radius: parent.radius
            color: tile.accent
        }

        Column {
            anchors.centerIn: parent
            spacing: Appearance.spacing.small

            MaterialIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                text: tile.armed ? "check" : tile.icon
                color: tile.accent
                font.pointSize: Appearance.font.size.extraLarge
                font.weight: 500

                Behavior on color { CAnim {} }
            }

            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: tile.armed ? "Confirm?" : tile.label
                color: tile.accent
                font.pointSize: Appearance.font.size.small

                Behavior on color { CAnim {} }
            }
        }
    }
}
