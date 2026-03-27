import QtQuick
import "../../../components"
import "../../../services"
import "../../../config"

// OS logo button — toggles the app launcher.
Item {
    id: root

    required property DrawerVisibilities visibilities

    implicitWidth: Config.bar.innerWidth
    implicitHeight: Config.bar.innerWidth

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.visibilities.launcher = !root.visibilities.launcher
    }

    MaterialIcon {
        anchors.centerIn: parent
        text: "apps"
        color: Colors.palette.m3tertiary
        font.pointSize: Appearance.font.size.large
    }
}
