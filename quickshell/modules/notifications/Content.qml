pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../components"
import "../../services"
import "../../config"

Item {
    id: root

    implicitWidth: Config.notifs.width + Appearance.padding.normal * 2
    implicitHeight: list.count > 0
        ? list.contentHeight + Appearance.padding.normal * 2
        : 0

    ListView {
        id: list

        anchors.fill: parent
        anchors.margins: Appearance.padding.normal

        model: ScriptModel {
            values: Notifs.popups
        }

        orientation: Qt.Vertical
        spacing: Appearance.spacing.smaller
        clip: false

        displaced: Transition {
            NumberAnimation {
                property: "y"
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
        }

        delegate: Component {
            Item {
                id: wrapper

                required property NotifData modelData

                width: ListView.view.width
                height: card.implicitHeight

                SequentialAnimation {
                    id: removeAnim
                    PropertyAction {
                        target: wrapper
                        property: "ListView.delayRemove"
                        value: true
                    }
                    NumberAnimation {
                        target: card
                        property: "x"
                        to: Config.notifs.width * 2
                        duration: Appearance.anim.durations.normal
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.anim.curves.emphasizedAccel
                    }
                    NumberAnimation {
                        target: wrapper
                        property: "height"
                        to: 0
                        duration: Appearance.anim.durations.small
                    }
                    PropertyAction {
                        target: wrapper
                        property: "ListView.delayRemove"
                        value: false
                    }
                }
                ListView.onRemove: removeAnim.start()

                Notification {
                    id: card
                    width: parent.width
                    modelData: wrapper.modelData
                }
            }
        }
    }
}
