import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../components/controls"
import "../../../config"
import "../../../services"

// Vertical volume + brightness sliders.
Card {
    RowLayout {
        anchors.centerIn: parent
        spacing: Appearance.spacing.normal

        SliderColumn {
            slider.icon: Audio.icon
            slider.value: Audio.volume
            slider.onMoved: Audio.setVolume(slider.value)
            onScrolled: up => up ? Audio.increase() : Audio.decrease()
        }

        SliderColumn {
            slider.icon: `brightness_${Math.round(slider.value * 6) + 1}`
            slider.value: Brightness.brightness
            slider.onMoved: Brightness.setBrightness(slider.value)
            onScrolled: up => up ? Brightness.increase() : Brightness.decrease()
        }
    }

    component SliderColumn: ColumnLayout {
        id: col

        property alias slider: control

        signal scrolled(bool up)

        spacing: Appearance.spacing.small

        Item {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: Config.osd.sliderWidth
            implicitHeight: Config.osd.sliderHeight

            FilledSlider {
                id: control

                anchors.fill: parent
            }

            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: event => col.scrolled(event.angleDelta.y > 0)
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: `${Math.round(control.value * 100)}%`
            font.pointSize: Appearance.font.size.small
            font.family: Appearance.font.family.mono
            color: Colors.palette.m3onSurfaceVariant
        }
    }
}
