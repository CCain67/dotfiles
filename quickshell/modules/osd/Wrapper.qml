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
    readonly property real contentHeight: content.implicitHeight

    onExpandedChanged: visibilities.osd = expanded

    implicitWidth: expanded
        ? content.implicitWidth + Appearance.padding.large
        : Config.border.thickness

    Behavior on implicitWidth {
        Anim {
            easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
            duration: Appearance.anim.durations.expressiveFastSpatial
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
            SequentialAnimation {
                // Delay only on reveal so content appears after the shape has extended
                PauseAnimation { duration: content.opacity === 0 ? Config.osd.contentRevealDelay : 0 }
                Anim { duration: Appearance.anim.durations.small }
            }
        }
    }
}
