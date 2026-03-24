pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import "../../../components"
import "../../../services"
import "../../../config"

// System tray: shows one icon per SystemTray item (minus any hidden by config).
Item {
    id: root

    implicitWidth: Config.bar.innerWidth
    implicitHeight: trayLayout.implicitHeight + Appearance.padding.small * 2

    ColumnLayout {
        id: trayLayout

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Appearance.padding.small
        spacing: Appearance.spacing.small

        Repeater {
            model: ScriptModel {
                values: SystemTray.items.values.filter(
                    i => !Config.bar.tray.hiddenIcons.includes(i.id)
                )
            }

            TrayItem {}
        }
    }
}
