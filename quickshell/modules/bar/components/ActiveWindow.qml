import QtQuick
import "../../../components"
import "../../../services"
import "../../../config"
import "../../../utils"

// Shows the active window's app icon and title (rotated 90° to read top-to-bottom).
Item {
    id: root

    readonly property color colour: Colors.palette.m3primary

    readonly property string windowTitle: {
        const title = Hypr.activeToplevel?.title;
        if (!title) return "";
        if (Config.bar.activeWindow.compact) {
            const parts = title.split(/\s+[\-\u2013\u2014]\s+/);
            if (parts.length > 1)
                return parts[parts.length - 1].trim();
        }
        return title;
    }

    clip: true
    implicitWidth: Config.bar.innerWidth

    MaterialIcon {
        id: appIcon

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Appearance.padding.small

        animate: true
        text: Icons.getAppCategoryIcon(
            Hypr.activeToplevel?.lastIpcObject.class ?? "",
            "desktop_windows"
        )
        color: root.colour
    }

    StyledText {
        id: titleText

        // Before rotation the item is tall and narrow (width = visual height, height = visual width).
        // After 90° clockwise rotation it renders as a top-to-bottom label.
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: appIcon.bottom
        anchors.topMargin: Appearance.spacing.small
        anchors.bottom: parent.bottom

        width: height
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter

        text: root.windowTitle
        color: root.colour
        font.pointSize: Appearance.font.size.smaller
        font.family: Appearance.font.family.mono

        transform: [
            Translate { x: -(titleText.implicitWidth - titleText.implicitHeight) / 2 },
            Rotation {
                angle: 90
                origin.x: titleText.width / 2
                origin.y: titleText.height / 2
            }
        ]

        Behavior on text {
            SequentialAnimation {
                NumberAnimation { target: titleText; property: "opacity"; to: 0; duration: 100 }
                PropertyAction {}
                NumberAnimation { target: titleText; property: "opacity"; to: 1; duration: 100 }
            }
        }
    }
}
