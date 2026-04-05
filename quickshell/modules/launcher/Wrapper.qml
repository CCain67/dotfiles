pragma ComponentBehavior: Bound

import QtQuick
import "../../components"
import "../../config"

// Launcher panel — collapses to zero width at the bar edge; expands rightward when visible.
// Placed directly in Drawers.qml anchored top/bottom at bar.right, mirroring Osd.Wrapper.
Item {
    id: root

    required property DrawerVisibilities visibilities

    readonly property bool expanded: visibilities.launcher
    readonly property real contentHeight: content.implicitHeight

    clip: true

    implicitWidth: expanded
        ? content.implicitWidth + Appearance.padding.large
        : 0

    Behavior on implicitWidth {
        Anim {
            easing.bezierCurve: Appearance.anim.curves.standard
            duration: Appearance.anim.durations.expressiveFastSpatial
        }
    }

    Loader {
        id: content
        anchors.top: parent.top
        anchors.topMargin: Config.border.thickness
        anchors.left: parent.left
        anchors.leftMargin: Appearance.padding.normal
        active: false

        opacity: root.expanded ? 1 : 0

        Behavior on opacity {
            SequentialAnimation {
                // Delay only on reveal so content appears after the shape has extended
                PauseAnimation { duration: content.opacity === 0 ? Config.osd.contentRevealDelay : 0 }
                Anim { duration: Appearance.anim.durations.small }
            }
        }

        Connections {
            target: root.visibilities
            function onLauncherChanged(): void {
                if (root.visibilities.launcher) content.active = true
            }
        }

        sourceComponent: Content {
            visibilities: root.visibilities
        }
    }
}
