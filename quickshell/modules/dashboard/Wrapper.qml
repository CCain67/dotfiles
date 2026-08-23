pragma ComponentBehavior: Bound

import QtQuick
import "../../components"
import "../../config"

// Centered dashboard overlay. Unlike the launcher/session panels this one
// does not attach to the screen border, so it needs no ShapePath background —
// the card in Content.qml draws itself.
//
// Fills the whole Panels area to catch click-outside dismissal; kept
// `visible: false` while hidden so that MouseArea doesn't eat desktop clicks.
Item {
    id: root

    required property DrawerVisibilities visibilities

    visible: opacity > 0
    opacity: 0

    // Click-outside-to-dismiss. Deliberately undimmed — no scrim.
    MouseArea {
        anchors.fill: parent
        onClicked: root.visibilities.dashboard = false
    }

    Loader {
        id: content

        anchors.centerIn: parent
        active: false
        scale: 0.92

        Connections {
            target: root.visibilities

            function onDashboardChanged(): void {
                if (root.visibilities.dashboard)
                    content.active = true;
            }
        }

        sourceComponent: Content {
            visibilities: root.visibilities
        }
    }

    states: State {
        name: "visible"
        when: root.visibilities.dashboard

        PropertyChanges {
            root.opacity: 1
            content.scale: 1
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            ParallelAnimation {
                Anim {
                    target: root
                    property: "opacity"
                    duration: Appearance.anim.durations.small
                }
                Anim {
                    target: content
                    property: "scale"
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                }
            }
        },
        Transition {
            from: "visible"
            to: ""

            ParallelAnimation {
                Anim {
                    target: root
                    property: "opacity"
                    duration: Appearance.anim.durations.small
                }
                Anim {
                    target: content
                    property: "scale"
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                }
            }
        }
    ]
}
