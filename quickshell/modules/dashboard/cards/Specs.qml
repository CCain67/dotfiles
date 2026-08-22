pragma ComponentBehavior: Bound

import QtQuick
import "../../../components"
import "../../../config"
import "../../../services"

// System identity, from the SysInfo service.
Card {
    title: "System Specs"
    icon: "monitor"

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Appearance.spacing.small

        SpecRow {
            icon: "public"
            label: "OS"
            value: SysInfo.os
        }
        SpecRow {
            icon: "desktop_windows"
            label: "WM"
            value: SysInfo.wm
        }
        SpecRow {
            icon: "terminal"
            label: "Shell"
            value: SysInfo.shell
        }
        SpecRow {
            icon: "dns"
            label: "Host"
            value: SysInfo.host
        }
        SpecRow {
            icon: "schedule"
            label: "Uptime"
            value: SysInfo.uptime
        }
        SpecRow {
            icon: "inventory_2"
            label: "Packages"
            value: SysInfo.packages
        }
    }

    component SpecRow: Item {
        id: row

        required property string icon
        required property string label
        required property string value

        width: parent.width
        implicitHeight: 24

        MaterialIcon {
            id: rowIcon

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: row.icon
            color: Colors.palette.m3primary
            font.pointSize: Appearance.font.size.small
        }

        StyledText {
            id: rowLabel

            anchors.left: rowIcon.right
            anchors.leftMargin: Appearance.spacing.small
            anchors.verticalCenter: parent.verticalCenter
            text: row.label
            color: Colors.palette.m3outline
            font.pointSize: Appearance.font.size.small
        }

        StyledText {
            anchors.left: rowLabel.right
            anchors.leftMargin: Appearance.spacing.small
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: row.value
            color: Colors.palette.m3onSurface
            font.pointSize: Appearance.font.size.small
            font.family: Appearance.font.family.mono
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
        }
    }
}
