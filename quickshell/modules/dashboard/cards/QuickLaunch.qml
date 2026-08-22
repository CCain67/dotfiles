pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../../../components"
import "../../../config"
import "../../../services"

// Quick-launch column driven by Config.dashboard.shortcuts.
// Entries resolve through DesktopEntries; the Material Symbol from config is
// used whenever no themed app icon is available.
Card {
    id: root

    required property DrawerVisibilities visibilities

    ColumnLayout {
        anchors.fill: parent
        spacing: Appearance.spacing.small

        Repeater {
            model: Config.dashboard.shortcuts

            Rectangle {
                id: item

                required property var modelData

                readonly property var entry: DesktopEntries.heuristicLookup(modelData.entry)
                readonly property string iconPath: (Config.dashboard.useAppIcons && entry?.icon) ? Quickshell.iconPath(entry.icon, true) : ""

                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Appearance.rounding.small
                color: Colors.palette.m3surfaceContainerHighest

                Behavior on color { CAnim {} }

                StateLayer {
                    function onClicked(): void {
                        if (item.entry) {
                            const base = Array.from(item.entry.command);
                            Quickshell.execDetached({
                                command: item.entry.runInTerminal ? [Config.terminal, "-e", ...base] : base,
                                workingDirectory: item.entry.workingDirectory || ""
                            });
                        }
                        root.visibilities.dashboard = false;
                    }
                    radius: parent.radius
                }

                IconImage {
                    id: appIcon

                    anchors.left: parent.left
                    anchors.leftMargin: Appearance.padding.normal
                    anchors.verticalCenter: parent.verticalCenter
                    asynchronous: true
                    implicitSize: 20
                    source: item.iconPath
                    visible: item.iconPath.length > 0
                }

                MaterialIcon {
                    anchors.left: parent.left
                    anchors.leftMargin: Appearance.padding.normal
                    anchors.verticalCenter: parent.verticalCenter
                    text: item.modelData.icon
                    color: Colors.palette.m3primary
                    font.pointSize: Appearance.font.size.larger
                    visible: !appIcon.visible
                }

                StyledText {
                    anchors.left: parent.left
                    anchors.leftMargin: Appearance.padding.normal + 20 + Appearance.spacing.normal
                    anchors.right: parent.right
                    anchors.rightMargin: Appearance.padding.normal
                    anchors.verticalCenter: parent.verticalCenter
                    text: item.modelData.label
                    font.pointSize: Appearance.font.size.normal
                    color: item.entry ? Colors.palette.m3onSurface : Colors.palette.m3outline
                    elide: Text.ElideRight
                }
            }
        }
    }
}
