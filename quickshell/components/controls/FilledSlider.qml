import QtQuick
import QtQuick.Controls
import ".."
import "../../services"
import "../../config"

// Vertical slider with a filled track and a square icon handle.
// Bind `value` to the source (e.g. Brightness.brightness) and call the
// service in `onMoved`. A smooth value animation keeps the handle in sync
// with external changes without breaking user-initiated drags.
Slider {
    id: root

    required property string icon

    orientation: Qt.Vertical

    background: Rectangle {
        color: Colors.palette.m3surfaceContainerHighest
        radius: Appearance.rounding.full

        // Filled portion: bottom of track up to handle
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height - root.handle.y
            color: Colors.palette.m3primary
            radius: parent.radius
        }
    }

    handle: Item {
        y: root.visualPosition * (root.availableHeight - height)
        implicitWidth: root.width
        implicitHeight: root.width

        Rectangle {
            anchors.fill: parent
            color: Colors.palette.m3inverseSurface
            radius: Appearance.rounding.full

            MaterialIcon {
                text: root.icon
                color: Colors.palette.m3inverseOnSurface
                anchors.centerIn: parent
                font.pointSize: Appearance.font.size.larger
            }
        }
    }

    Behavior on value {
        NumberAnimation { duration: Appearance.anim.durations.large }
    }
}
