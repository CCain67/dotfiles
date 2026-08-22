pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../config"
import "../../../services"

// Live resource meters, all sourced from the shared SysUsage service.
// Each meter sits in its own tile.
Card {
    title: "Resources"
    icon: "monitor_heart"

    // Keeps the detail column narrow: 3664G reads as 3.6T.
    function fmtSize(gb: real): string {
        return gb >= 1000 ? `${(gb / 1024).toFixed(1)}T` : `${Math.round(gb)}G`;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Appearance.spacing.small

        UsageTile {
            icon: "developer_board"
            label: "CPU"
            perc: SysUsage.cpuUtil / 100
            detail: `${SysUsage.cpuTemp}°`
            accent: Colors.red
        }
        UsageTile {
            icon: "memory"
            label: "RAM"
            perc: SysUsage.ramPerc
            detail: SysUsage.ramTotalStr
            accent: Colors.blue
        }
        UsageTile {
            icon: "network_intelligence"
            label: "GPU"
            perc: SysUsage.gpuUtil / 100
            detail: `${SysUsage.gpuTemp}°`
            accent: Colors.purple
        }
        UsageTile {
            icon: "hard_drive"
            label: "Disk"
            perc: SysUsage.diskPerc
            detail: fmtSize(SysUsage.diskTotalGb)
            accent: Colors.green
        }
    }

    component UsageTile: Tile {
        id: tile

        required property string label
        required property real perc
        required property string detail

        showBadge: false

        // Nested layouts default to filling; both axes are set explicitly here
        Layout.fillWidth: true
        Layout.fillHeight: true

        StyledText {
            id: tileLabel

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: tile.label
            color: Colors.palette.m3onSurface
            font.pointSize: Appearance.font.size.small
        }

        Row {
            id: percText

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Appearance.spacing.small / 2

            StyledText {
                text: `${Math.round(tile.perc * 100)}%`
                color: Colors.palette.m3onSurface
                font.pointSize: Appearance.font.size.small
                font.family: Appearance.font.family.mono
            }

            StyledText {
                text: "|"
                color: Colors.palette.m3outlineVariant
                font.pointSize: Appearance.font.size.small
                font.family: Appearance.font.family.mono
            }

            StyledText {
                text: tile.detail
                color: Colors.palette.m3outline
                font.pointSize: Appearance.font.size.small
                font.family: Appearance.font.family.mono
            }
        }

        // Track
        Rectangle {
            anchors.left: tileLabel.right
            anchors.leftMargin: Appearance.spacing.small
            anchors.right: percText.left
            anchors.rightMargin: Appearance.spacing.small
            anchors.verticalCenter: parent.verticalCenter
            implicitHeight: 6
            radius: Appearance.rounding.full
            color: Colors.palette.m3surfaceContainerLowest

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * Math.max(0, Math.min(1, tile.perc))
                radius: parent.radius
                color: SysUsage.loadColor(tile.perc)

                Behavior on width { Anim {} }
                Behavior on color { CAnim {} }
            }
        }
    }
}
