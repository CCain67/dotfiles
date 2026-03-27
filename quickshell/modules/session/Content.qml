pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../components"
import "../../services"
import "../../config"

// Session power menu card: logout / shutdown / hibernate / reboot buttons.
// Keyboard navigation: Tab / Shift+Tab cycle buttons, Enter/Return triggers,
// Escape dismisses. Ctrl+J/K vim nav when Config.session.vimKeybinds is true.
Item {
    id: root

    required property DrawerVisibilities visibilities

    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight

    // Background card
    Rectangle {
        id: card

        implicitWidth: buttons.implicitWidth + Appearance.padding.large * 2
        implicitHeight: buttons.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.large
        color: Colors.palette.m3surface

        Behavior on color { CAnim {} }

        Column {
            id: buttons

            anchors.centerIn: parent
            spacing: Appearance.spacing.normal

            SessionButton {
                id: logout

                icon: Config.session.icons.logout
                command: Config.session.commands.logout

                KeyNavigation.down: shutdown

                Component.onCompleted: Qt.callLater(forceActiveFocus)

                Connections {
                    target: root.visibilities

                    function onSessionChanged(): void {
                        if (root.visibilities.session)
                            logout.forceActiveFocus();
                    }
                }
            }

            SessionButton {
                id: shutdown

                icon: Config.session.icons.shutdown
                command: Config.session.commands.shutdown

                KeyNavigation.up: logout
                KeyNavigation.down: hibernate
            }

            SessionButton {
                id: hibernate

                icon: Config.session.icons.hibernate
                command: Config.session.commands.hibernate

                KeyNavigation.up: shutdown
                KeyNavigation.down: reboot
            }

            SessionButton {
                id: reboot

                icon: Config.session.icons.reboot
                command: Config.session.commands.reboot

                KeyNavigation.up: hibernate
            }
        }
    }

    component SessionButton: Rectangle {
        id: button

        required property string icon
        required property list<string> command

        implicitWidth: 48
        implicitHeight: 48

        radius: Appearance.rounding.large

        color: button.activeFocus
            ? Colors.palette.m3secondaryContainer
            : Colors.palette.m3surfaceContainerHighest

        Behavior on color { CAnim {} }

        Keys.onEnterPressed: Quickshell.execDetached(button.command)
        Keys.onReturnPressed: Quickshell.execDetached(button.command)
        Keys.onEscapePressed: root.visibilities.session = false
        Keys.onPressed: event => {
            if (!Config.session.vimKeybinds)
                return;

            if (event.modifiers & Qt.ControlModifier) {
                if (event.key === Qt.Key_J && KeyNavigation.down) {
                    KeyNavigation.down.focus = true;
                    event.accepted = true;
                } else if (event.key === Qt.Key_K && KeyNavigation.up) {
                    KeyNavigation.up.focus = true;
                    event.accepted = true;
                }
            } else if (event.key === Qt.Key_Tab && KeyNavigation.down) {
                KeyNavigation.down.focus = true;
                event.accepted = true;
            } else if (event.key === Qt.Key_Backtab ||
                       (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                if (KeyNavigation.up) {
                    KeyNavigation.up.focus = true;
                    event.accepted = true;
                }
            }
        }

        StateLayer {
            function onClicked(): void {
                Quickshell.execDetached(button.command);
            }

            radius: parent.radius
            color: button.activeFocus
                ? Colors.palette.m3onSecondaryContainer
                : Colors.palette.m3onSurface
        }

        MaterialIcon {
            anchors.centerIn: parent

            text: button.icon
            color: button.activeFocus
                ? Colors.palette.m3onSecondaryContainer
                : Colors.palette.m3onSurface
            font.pointSize: Appearance.font.size.extraLarge
            font.weight: 500
        }
    }
}
