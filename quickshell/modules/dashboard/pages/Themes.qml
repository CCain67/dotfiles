pragma ComponentBehavior: Bound

import QtQuick
import "../../../components"
import "../../../config"
import "../../../services"
import "../cards"

// Theme picker page. One tile per themes/*.json — wallpaper thumbnail, label and
// a strip of accent chips — with the active theme outlined.
//
// Clicking a tile calls Theme.apply(), which repaints the shell (every colour in
// Colors.qml is a binding onto Theme.raw), swaps the wallpaper via hyprpaper's
// IPC, and persists the choice.
//
// Root is a Card so the page matches the Info page's outlined containers;
// children land in the Card's body, so `parent` below is that body.
Card {
    id: root

    // Re-scan on open so a JSON file dropped into themes/ appears without a
    // shell restart — the loader is otherwise a one-shot at startup.
    onVisibleChanged: if (visible)
        Theme.reload()

    GridView {
        id: grid

        anchors.fill: parent
        clip: true

        readonly property int columns: 3
        readonly property int gap: Appearance.spacing.normal

        cellWidth: Math.floor(width / columns)
        cellHeight: 250

        model: Theme.themes

        delegate: Item {
            id: cell

            required property var modelData

            readonly property bool active: Theme.currentName === modelData.name

            width: grid.cellWidth
            height: grid.cellHeight

            StyledRect {
                anchors.fill: parent
                anchors.margins: grid.gap / 2

                radius: Appearance.rounding.normal
                color: cell.active ? Colors.palette.m3surfaceContainerHighest : Colors.palette.m3surfaceContainer
                border.width: cell.active ? 2 : 1
                border.color: cell.active ? Colors.palette.m3primary : Colors.palette.m3outlineVariant

                Behavior on color {
                    CAnim {}
                }

                Behavior on border.color {
                    CAnim {}
                }

                StateLayer {
                    function onClicked(): void {
                        Theme.apply(cell.modelData.name);
                    }
                    radius: parent.radius
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: Appearance.padding.larger
                    spacing: Appearance.spacing.smaller

                    // Wallpaper preview. sourceSize caps decoding at the tile
                    // size — without it a 4K wallpaper is decoded in full for a
                    // ~150px thumbnail, once per theme.
                    StyledClippingRect {
                        width: parent.width
                        height: 140
                        radius: Appearance.rounding.small
                        color: Colors.palette.m3surfaceContainerLowest

                        Image {
                            id: thumb

                            anchors.fill: parent
                            source: cell.modelData.wallpaperPath ? `file://${cell.modelData.wallpaperPath}` : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            sourceSize.width: 512
                            visible: status === Image.Ready
                        }

                        // Shown when the theme names no wallpaper, or the file is
                        // missing/undecodable.
                        MaterialIcon {
                            anchors.centerIn: parent
                            text: "wallpaper"
                            color: Colors.palette.m3onSurfaceVariant
                            font.pointSize: Appearance.font.size.extraLarge
                            visible: !thumb.visible
                        }
                    }

                    Item {
                        width: parent.width
                        height: labelText.implicitHeight

                        StyledText {
                            id: labelText

                            anchors.left: parent.left
                            anchors.right: checkIcon.left
                            anchors.rightMargin: Appearance.spacing.small
                            anchors.verticalCenter: parent.verticalCenter

                            text: cell.modelData.label ?? cell.modelData.name
                            color: Colors.palette.m3onSurface
                            font.pointSize: Appearance.font.size.normal
                            elide: Text.ElideRight
                        }

                        MaterialIcon {
                            id: checkIcon

                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: "check_circle"
                            fill: 1
                            color: Colors.palette.m3primary
                            font.pointSize: Appearance.font.size.normal
                            opacity: cell.active ? 1 : 0
                            visible: opacity > 0

                            Behavior on opacity {
                                Anim {
                                    duration: Appearance.anim.durations.small
                                }
                            }
                        }
                    }

                    // Accent chips — enough of the palette to tell two themes
                    // apart at a glance.
                    Row {
                        spacing: Appearance.spacing.small

                        Repeater {
                            model: ["background", "foreground", "blue", "purple", "yellow", "red", "green"]

                            StyledRect {
                                required property string modelData

                                implicitWidth: 20
                                implicitHeight: 20
                                radius: Appearance.rounding.full
                                color: cell.modelData[modelData] ?? "transparent"
                                border.width: 1
                                border.color: Colors.palette.m3outlineVariant
                            }
                        }
                    }
                }
            }
        }
    }

    // Only reachable if themes/ is empty or unparseable — Theme falls back to a
    // built-in palette in that case, so the shell still renders.
    Column {
        anchors.centerIn: parent
        spacing: Appearance.spacing.normal
        visible: !Theme.loaded

        MaterialIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "palette"
            color: Colors.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.extraLarge
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "No themes found in ~/dotfiles/themes"
            color: Colors.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.normal
        }
    }
}
