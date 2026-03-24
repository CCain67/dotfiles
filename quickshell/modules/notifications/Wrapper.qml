import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../components/containers"
import "../../config"
import "../../services"

// Standalone layer-shell window for notification popups.
// Anchored top-right, sized to content. Destroyed when no popups
// to avoid "Cannot use same item on different windows" crashes.
Scope {
    Variants {
        model: Notifs.popups.length > 0 ? [Screens.screen] : []

        delegate: Component {
            StyledWindow {
                id: win

                required property ShellScreen modelData

                name: "notifications"
                screen: modelData

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                WlrLayershell.margins.top: Config.border.thickness
                WlrLayershell.margins.right: Config.border.thickness

                anchors.top: true
                anchors.right: true

                implicitWidth: content.implicitWidth
                implicitHeight: content.implicitHeight

                Content {
                    id: content
                }
            }
        }
    }
}
