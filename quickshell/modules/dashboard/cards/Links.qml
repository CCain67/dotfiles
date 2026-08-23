pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import "../../../components"
import "../../../config"
import "../../../services"

// Row of web-shortcut tiles from Config.dashboard.links, opened with xdg-open.
Card {
    id: root

    required property DrawerVisibilities visibilities

    // Config stores an accent *name* so it stays free of a services import.
    function accentColor(name: string): color {
        switch (name) {
        case "red": return Colors.red;
        case "orange": return Colors.orange;
        case "yellow": return Colors.yellow;
        case "green": return Colors.green;
        case "cyan": return Colors.cyan;
        case "purple": return Colors.purple;
        default: return Colors.blue;
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: Appearance.spacing.normal

        Repeater {
            model: Config.dashboard.links

            Rectangle {
                id: tile

                required property var modelData

                readonly property color accent: root.accentColor(modelData.accent)

                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Appearance.rounding.small
                color: Colors.palette.m3surfaceContainerHighest
                border.color: Colors.palette.m3outlineVariant

                Behavior on color { CAnim {} }

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    blurMax: 10
                    shadowVerticalOffset: 2
                    shadowColor: Qt.alpha(Colors.palette.m3shadow, 0.8)
                }

                StateLayer {
                    function onClicked(): void {
                        Quickshell.execDetached(["xdg-open", tile.modelData.url]);
                        root.visibilities.dashboard = false;
                    }
                    radius: parent.radius
                    color: tile.accent
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    MaterialIcon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: tile.modelData.icon
                        color: tile.accent
                        font.pointSize: Appearance.font.size.large
                    }

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: tile.modelData.label
                        font.pointSize: Appearance.font.size.small
                        color: Colors.palette.m3onSurface
                    }
                }
            }
        }
    }
}
