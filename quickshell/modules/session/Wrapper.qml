pragma ComponentBehavior: Bound

import QtQuick
import "../../components"
import "../../config"

// Slide-in wrapper for the session power menu.
// Animates from zero width to content width when visibilities.session is true.
Item {
    id: root

    required property DrawerVisibilities visibilities

    visible: width > 0
    implicitWidth: 0
    implicitHeight: content.implicitHeight

    states: State {
        name: "visible"
        when: root.visibilities.session

        PropertyChanges {
            root.implicitWidth: content.implicitWidth
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            Anim {
                target: root
                property: "implicitWidth"
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                duration: Appearance.anim.durations.expressiveDefaultSpatial
            }
        },
        Transition {
            from: "visible"
            to: ""

            Anim {
                target: root
                property: "implicitWidth"
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                duration: Appearance.anim.durations.expressiveDefaultSpatial
            }
        }
    ]

    Loader {
        id: content

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        Component.onCompleted: active = Qt.binding(() => root.visibilities.session || root.visible)

        sourceComponent: Content {
            visibilities: root.visibilities
        }
    }
}
