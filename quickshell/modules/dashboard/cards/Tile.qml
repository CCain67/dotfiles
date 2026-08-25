import QtQuick
import "../../../components"
import "../../../config"
import "../../../services"

// Mini-card used inside Specs/Resources: a shadowed container with an
// accent-tinted icon badge on the left. Children are parented into the area
// right of the badge.
StyledRect {
    id: root

    property string icon: ""
    property color accent: Colors.palette.m3primary
    // When false the icon sits on the tile directly; the badge box is kept as a
    // transparent spacer so text still lines up across tiles.
    property bool showBadge: true
    property int pad: Appearance.padding.smaller
    property int badgeSize: 22

    default property alias content: body.data

    radius: Appearance.rounding.small
    color: Colors.palette.m3surfaceContainerHighest
    border.width: Appearance.outline.width
    border.color: Appearance.outline.color

    layer.enabled: !Theme.flat
    layer.effect: Elevation {
        level: "low"
    }

    StyledRect {
        id: badge

        anchors.left: parent.left
        anchors.leftMargin: root.pad
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: root.badgeSize
        implicitHeight: root.badgeSize
        radius: Appearance.rounding.small
        color: root.showBadge ? Qt.alpha(root.accent, 0.22) : "transparent"

        MaterialIcon {
            anchors.centerIn: parent
            text: root.icon
            color: root.accent
            font.pointSize: Appearance.font.size.small
        }
    }

    Item {
        id: body

        anchors.left: badge.right
        anchors.leftMargin: Appearance.spacing.small
        anchors.right: parent.right
        anchors.rightMargin: root.pad
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
}
