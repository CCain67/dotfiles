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

    MaterialIcon {
        id: powerIcon

        anchors.centerIn: parent
        text: "power_settings_new"
        color: Colors.palette.m3error
        font.pointSize: Appearance.font.size.normal
    }
}
