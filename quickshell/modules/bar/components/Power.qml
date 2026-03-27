import QtQuick
import "../../../components"
import "../../../services"
import "../../../config"

// Power button — visual indicator only; power menu lives in the right-edge OSD.
Item {
    id: root

    required property DrawerVisibilities visibilities

    implicitWidth: Config.bar.innerWidth
    implicitHeight: powerIcon.implicitHeight + Appearance.padding.small * 2

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.visibilities.session = !root.visibilities.session
    }

    MaterialIcon {
        id: powerIcon

        anchors.centerIn: parent
        text: "power_settings_new"
        color: Colors.palette.m3error
        font.pointSize: Appearance.font.size.normal
    }
}
