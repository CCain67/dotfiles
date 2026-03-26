pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../components"
import "../../services"
import "../../config"
import "components"

ColumnLayout {
    id: root

    required property ShellScreen screen
    required property DrawerVisibilities visibilities

    readonly property int vPadding: Appearance.padding.large

    spacing: Appearance.spacing.normal

    // Top padding
    Item {
        implicitWidth: 1
        implicitHeight: 0
    }

    Clock {
        Layout.alignment: Qt.AlignHCenter
    }

    Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 22
            height: 2
            color: Colors.palette.m3surfaceBright
    }
    Apps {
        Layout.alignment: Qt.AlignHCenter
    }
    Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 22
            height: 2
            color: Colors.palette.m3surfaceBright
    }

    Workspaces {
        Layout.alignment: Qt.AlignHCenter
    }
    Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 22
            height: 2
            color: Colors.palette.m3surfaceBright
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

    RamMeter {
        Layout.alignment: Qt.AlignHCenter
    }

    CpuMeter {
        Layout.alignment: Qt.AlignHCenter
    }

    GpuMeter {
        Layout.alignment: Qt.AlignHCenter
    }

    // Power {
    //     Layout.alignment: Qt.AlignHCenter
    //     visibilities: root.visibilities
    // }

    // Bottom padding
    Item {
        implicitWidth: 1
        implicitHeight: 0
    }
}
