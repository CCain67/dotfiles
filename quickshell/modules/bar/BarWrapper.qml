pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../components"
import "../../config"

// Wraps Bar with a width animation. The bar is always persistent in Phase 2.
// Exposes exclusiveZone so Exclusions can request the correct left-edge reservation.
Item {
    id: root

    required property ShellScreen screen
    required property DrawerVisibilities visibilities

    readonly property int contentWidth: Config.bar.innerWidth + Appearance.padding.normal * 2.5
    readonly property int exclusiveZone: contentWidth

    implicitWidth: contentWidth

    states: State {
        name: "visible"
        when: true

        PropertyChanges {
            root.implicitWidth: root.contentWidth
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            Anim {
                target: root
                property: "implicitWidth"
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
        },
        Transition {
            from: "visible"
            to: ""

            Anim {
                target: root
                property: "implicitWidth"
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }
    ]

    Bar {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: root.contentWidth
        screen: root.screen
        visibilities: root.visibilities
    }
}
