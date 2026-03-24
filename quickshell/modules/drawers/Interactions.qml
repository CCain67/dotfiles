import QtQuick
import Quickshell
import "../../components"

// Phase 2 stub — hover/drag gesture handling added in Phase 3
// (session drag-to-reveal, launcher hover, bar hover-to-show)
Item {
    required property ShellScreen screen
    required property DrawerVisibilities visibilities
    required property Item panels
    required property Item bar

    anchors.fill: parent
}
