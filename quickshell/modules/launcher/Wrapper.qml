pragma ComponentBehavior: Bound

import QtQuick
import "../../components"
import "../../config"

// Slide-down wrapper for the app launcher.
// Animates implicitHeight from 0 to content height when visibilities.launcher is true.
Item {
    id: root

    required property DrawerVisibilities visibilities

    visible: height > 0
    implicitWidth: content.implicitWidth
    implicitHeight: 0

    states: State {
        name: "visible"
        when: root.visibilities.launcher

        PropertyChanges {
            root.implicitHeight: content.implicitHeight
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"
            Anim {
                target: root
                property: "implicitHeight"
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                duration: Appearance.anim.durations.expressiveDefaultSpatial
            }
        },
        Transition {
            from: "visible"
            to: ""
            Anim {
                target: root
                property: "implicitHeight"
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                duration: Appearance.anim.durations.expressiveDefaultSpatial
            }
        }
    ]

    Loader {
        id: content
        anchors.top: parent.top
        anchors.left: parent.left
        active: false

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
