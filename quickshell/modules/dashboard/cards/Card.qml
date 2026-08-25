import QtQuick
import "../../../components"
import "../../../config"
import "../../../services"

// Outlined container shared by every dashboard card.
// Children are parented into the body area below the optional title row.
StyledRect {
    id: root

    property string title: ""
    property string icon: ""
    property int pad: Appearance.padding.larger

    default property alias content: body.data

    radius: Appearance.rounding.normal
    color: Colors.palette.m3surfaceContainerHigh
    border.width: Appearance.outline.width
    border.color: Appearance.outline.color

    layer.enabled: !Theme.flat
    layer.effect: Elevation {
        level: "medium"
    }

    Row {
        id: titleRow

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: root.pad
        anchors.leftMargin: root.pad
        spacing: Appearance.spacing.small
        visible: root.title.length > 0

        MaterialIcon {
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: Colors.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.normal
            visible: root.icon.length > 0
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: root.title
            color: Colors.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
        }
    }

    Item {
        id: body

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: titleRow.visible ? titleRow.bottom : parent.top
        anchors.margins: root.pad
        anchors.topMargin: titleRow.visible ? Appearance.spacing.normal : root.pad
    }
}
