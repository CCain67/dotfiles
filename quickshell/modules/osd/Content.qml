import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../components"
import "../../components/controls"
import "../../services"
import "../../config"
import "../../utils"

// OSD content: brightness slider + power buttons in a single rounded card.
Item {
    id: root

    implicitWidth: layout.implicitWidth + Appearance.padding.larger * 2
    implicitHeight: layout.implicitHeight + Appearance.padding.large * 2

    Rectangle {
        anchors.fill: parent
        color: Colors.palette.m3surface
        radius: Config.border.rounding

        Behavior on color { CAnim {} }
    }

    ColumnLayout {
        id: layout
        anchors.centerIn: parent
        spacing: Appearance.spacing.normal

        // Brightness slider
        Item {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: Config.osd.sliderWidth
            implicitHeight: Config.osd.sliderHeight

            FilledSlider {
                id: brightnessSlider
                anchors.fill: parent
                icon: `brightness_${Math.round(value * 6) + 1}`
                value: Brightness.brightness
                onMoved: Brightness.setBrightness(value)
            }

            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: event => {
                    if (event.angleDelta.y > 0) Brightness.increase();
                    else Brightness.decrease();
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Colors.palette.m3outline
            opacity: 0.3
        }

        // Power buttons
        Column {
            Layout.alignment: Qt.AlignHCenter
            spacing: Appearance.spacing.normal

            Item {
                implicitWidth: 1
                implicitHeight: 10
            }
            PowerButton {
                icon: Config.session.icons.logout
                command: Config.session.commands.logout
            }
            Item {
                implicitWidth: 1
                implicitHeight: 10
            }
            PowerButton {
                icon: Config.session.icons.shutdown
                command: Config.session.commands.shutdown
            }
            Item {
                implicitWidth: 1
                implicitHeight: 10
            }
            PowerButton {
                icon: Config.session.icons.hibernate
                command: Config.session.commands.hibernate
            }
            Item {
                implicitWidth: 1
                implicitHeight: 10
            }
            PowerButton {
                icon: Config.session.icons.reboot
                command: Config.session.commands.reboot
            }
        }
    }

    component PowerButton: Rectangle {
        id: button

        required property string icon
        required property list<string> command

        implicitWidth: 48
        implicitHeight: 48
        radius: Appearance.rounding.large
        color: Colors.palette.m3surfaceContainerHighest

        Behavior on color { CAnim {} }

        StateLayer {
            function onClicked(): void {
                Quickshell.execDetached(button.command)
            }
            radius: parent.radius
            color: Colors.palette.m3onSurface
        }

        MaterialIcon {
            anchors.centerIn: parent
            text: button.icon
            color: Colors.palette.m3onSurface
            font.pointSize: Appearance.font.size.extraLarge
            font.weight: 500
        }
    }
}
