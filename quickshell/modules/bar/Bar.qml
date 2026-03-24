pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../components"
import "../../services"
import "../../config"
import "components"

// Vertical left-edge bar. Column layout top-to-bottom:
//   OsIcon → Workspaces → ActiveWindow (fill) → StatusIcons → Power → Clock
ColumnLayout {
    id: root

    required property ShellScreen screen
    required property DrawerVisibilities visibilities

    readonly property int vPadding: Appearance.padding.large

    spacing: Appearance.spacing.normal

    // Top padding
    Item {
        implicitWidth: 1
        implicitHeight: root.vPadding
    }

    OsIcon {
        Layout.alignment: Qt.AlignHCenter
    }

    Workspaces {
        Layout.alignment: Qt.AlignHCenter
    }

    ActiveWindow {
        Layout.fillHeight: true
        Layout.fillWidth: true
    }

    Tray {
        Layout.alignment: Qt.AlignHCenter
    }

    StatusIcons {
        Layout.alignment: Qt.AlignHCenter
    }

    Clock {
        Layout.alignment: Qt.AlignHCenter
    }

    Power {
        Layout.alignment: Qt.AlignHCenter
        visibilities: root.visibilities
    }

    // Bottom padding
    Item {
        implicitWidth: 1
        implicitHeight: root.vPadding
    }
}
