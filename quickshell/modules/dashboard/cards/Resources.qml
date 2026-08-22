pragma ComponentBehavior: Bound

import QtQuick
import "../../../components"
import "../../../config"
import "../../../services"

// Live resource meters, all sourced from the shared SysUsage service.
Card {
    title: "Resources"
    icon: "monitor_heart"

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Appearance.spacing.normal

        UsageRow {
            icon: "developer_board"
            label: "CPU"
            perc: SysUsage.cpuUtil / 100
            detail: `${SysUsage.cpuTemp}°`
        }
        UsageRow {
            icon: "memory"
            label: "RAM"
            perc: SysUsage.ramPerc
            detail: `${SysUsage.ramUsedStr} / ${SysUsage.ramTotalStr}`
        }
        UsageRow {
            icon: "network_intelligence"
            label: "GPU"
            perc: SysUsage.gpuUtil / 100
            detail: `${SysUsage.gpuTemp}°`
        }
        UsageRow {
            icon: "hard_drive"
            label: "Disk"
            perc: SysUsage.diskPerc
            detail: `${Math.round(SysUsage.diskTotalGb - SysUsage.diskUsedGb)}G free`
        }
    }

    component UsageRow: Item {
        id: row

        required property string icon
        required property string label
        required property real perc
        required property string detail

        width: parent.width
        implicitHeight: labelRow.implicitHeight + Appearance.spacing.small + 6

        Item {
            id: labelRow

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            implicitHeight: rowLabel.implicitHeight

            MaterialIcon {
                id: rowIcon

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: row.icon
                color: Colors.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
            }

            StyledText {
                id: rowLabel

                anchors.left: rowIcon.right
                anchors.leftMargin: Appearance.spacing.small
                anchors.verticalCenter: parent.verticalCenter
                text: row.label
                color: Colors.palette.m3onSurface
                font.pointSize: Appearance.font.size.small
            }

            StyledText {
                anchors.left: rowLabel.right
                anchors.leftMargin: Appearance.spacing.small
                anchors.right: percText.left
                anchors.rightMargin: Appearance.spacing.small
                anchors.verticalCenter: parent.verticalCenter
                text: row.detail
                color: Colors.palette.m3outline
                font.pointSize: Appearance.font.size.small
                font.family: Appearance.font.family.mono
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideRight
            }

            StyledText {
                id: percText

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: `${Math.round(row.perc * 100)}%`
                color: Colors.palette.m3onSurface
                font.pointSize: Appearance.font.size.small
                font.family: Appearance.font.family.mono
            }
        }

        // Track
        Rectangle {
            id: track

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            implicitHeight: 6
            radius: Appearance.rounding.full
            color: Colors.palette.m3surfaceContainerLowest

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * Math.max(0, Math.min(1, row.perc))
                radius: parent.radius
                color: SysUsage.loadColor(row.perc)

                Behavior on width { Anim {} }
                Behavior on color { CAnim {} }
            }
        }
    }
}
