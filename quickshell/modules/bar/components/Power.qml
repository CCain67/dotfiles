import QtQuick
import "../../../components"
import "../../../services"
import "../../../config"

// Power button — toggles the session menu (implemented Phase 4).
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
