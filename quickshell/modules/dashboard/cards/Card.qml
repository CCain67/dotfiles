import QtQuick
import QtQuick.Effects
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
    border.width: 1
    border.color: Colors.palette.m3outlineVariant

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        blurMax: 14
        shadowVerticalOffset: 2
        shadowColor: Qt.alpha(Colors.palette.m3shadow, 0.8)
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
