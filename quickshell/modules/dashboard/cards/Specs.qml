pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../config"
import "../../../services"

// System identity, from the SysInfo service. Each spec sits in its own tile.
Card {
    title: "System Specs"
    icon: "monitor"

    // "1 hour, 4 minutes" -> "1h 4m"; the tiles are too narrow for the long form.
    function compactUptime(s: string): string {
        return s.replace(/(\d+)\s*week(s?)/g, "$1w")
                .replace(/(\d+)\s*day(s?)/g, "$1d")
                .replace(/(\d+)\s*hour(s?)/g, "$1h")
                .replace(/(\d+)\s*minute(s?)/g, "$1m")
                .replace(/,/g, "");
    }

    GridLayout {
        anchors.fill: parent
        columns: 2
        columnSpacing: Appearance.spacing.small
        rowSpacing: Appearance.spacing.small

        SpecTile {
            icon: "public"
            label: "OS"
            value: SysInfo.os
            accent: Colors.orange
        }
        SpecTile {
            icon: "desktop_windows"
            label: "WM"
            value: SysInfo.wm
            accent: Colors.blue
        }
        SpecTile {
            icon: "terminal"
            label: "Shell"
            value: SysInfo.shell
            accent: Colors.green
        }
        SpecTile {
            icon: "dns"
            label: "Host"
            value: SysInfo.host
            accent: Colors.red
        }
        SpecTile {
            icon: "schedule"
            label: "Uptime"
            value: compactUptime(SysInfo.uptime)
            accent: Colors.purple
        }
        SpecTile {
            icon: "inventory_2"
            label: "Packages"
            value: SysInfo.updatable && SysInfo.updatable !== "0"
                ? `${SysInfo.packages} (${SysInfo.updatable})`
                : SysInfo.packages
            accent: Colors.cyan
        }
    }

    component SpecTile: Tile {
        id: tile

        showBadge: false

        required property string label
        required property string value

        // Nested layouts default to filling; both axes are set explicitly here
        Layout.fillWidth: true
        Layout.fillHeight: true

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            StyledText {
                width: parent.width
                text: tile.label
                color: Colors.palette.m3outline
                font.pointSize: Appearance.font.size.small
                elide: Text.ElideRight
            }

            StyledText {
                width: parent.width
                text: tile.value
                color: Colors.palette.m3onSurface
                font.pointSize: Appearance.font.size.small
                elide: Text.ElideRight
            }
        }
    }
}
