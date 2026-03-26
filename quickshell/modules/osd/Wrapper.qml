pragma ComponentBehavior: Bound

import QtQuick
import "../../components"
import "../../config"

// OSD panel — collapses to border-width strip on the right edge; expands left on hover.
// Placed directly in Drawers.qml anchored top/bottom/right so it covers the full right border.
Item {
    id: root

    required property DrawerVisibilities visibilities

    readonly property bool expanded: hoverHandler.hovered || hideTimer.running

    onExpandedChanged: visibilities.osd = expanded

    implicitWidth: expanded
        ? content.implicitWidth + Appearance.padding.large
        : Config.border.thickness

    Behavior on implicitWidth {
        Anim {
            easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            duration: Appearance.anim.durations.expressiveDefaultSpatial
        }
    }

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            if (!hovered) hideTimer.restart();
            else hideTimer.stop();
        }
    }

    Timer {
        id: hideTimer
        interval: 600
    }

    Content {
        id: content
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Appearance.padding.normal
        opacity: root.expanded ? 1 : 0

        Behavior on opacity {
            Anim { duration: Appearance.anim.durations.small }
        }
    }
}
