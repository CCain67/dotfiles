pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../../components"
import "../../../services"
import "../../../config"

// Workspace dot strip. Tapping a dot switches to that workspace.
Item {
    id: root

    implicitWidth: Config.bar.innerWidth
    implicitHeight: wsColumn.implicitHeight + Appearance.padding.small * 2

    ColumnLayout {
        id: wsColumn

        anchors.centerIn: parent
        spacing: Appearance.spacing.small / 2

        Repeater {
            model: Config.bar.workspaces.shown

            delegate: Item {
                required property int index

                readonly property int wsId: index + 1
                readonly property bool isActive: Hyprland.focusedWorkspace?.id === wsId
                readonly property bool isOccupied: {
                    for (const ws of Hyprland.workspaces.values) {
                        if (ws.id === wsId && ws.lastIpcObject.windows > 0)
                            return true
                    }
                    return false
                }

                Layout.alignment: Qt.AlignHCenter
                implicitWidth: Config.bar.innerWidth - Appearance.padding.small * 4
                implicitHeight: implicitWidth + Appearance.padding.small

                // Active indicator pill
                Rectangle {
                    anchors.fill: parent
                    radius: 2
                    color: Colors.palette.m3primary
                    opacity: parent.isActive ? 1 : 0

                    Behavior on opacity {
                        Anim {}
                    }
                }

                StyledText {
                    anchors.centerIn: parent
                    text: parent.wsId
                    color: parent.isActive
                        ? Colors.palette.m3surface
                        : parent.isOccupied
                            ? Colors.palette.m3onSurface
                            : Colors.palette.m3outlineVariant
                    font.family: Appearance.font.family.mono
                    font.pointSize: Appearance.font.size.smaller

                    Behavior on color {
                        CAnim {}
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    // NOTE: Hyprland is now on a Lua config (hypr/hyprland.lua), which
                    // parses whatever this sends as a Lua expression rather than the
                    // classic dispatcher string. `workspace ${id}` is no longer valid;
                    // this must be the real hl.dsp.focus() call.
                    onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${parent.wsId} })`)
                }
            }
        }
    }
}
