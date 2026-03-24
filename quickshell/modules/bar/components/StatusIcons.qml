import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../services"
import "../../../config"

// Status icon strip. Phase 2: wifi placeholder only.
// Audio, network service, Bluetooth added when those services are ported (Phase 3).
Item {
    id: root

    implicitWidth: Config.bar.innerWidth
    implicitHeight: iconCol.implicitHeight + Appearance.padding.small * 2

    ColumnLayout {
        id: iconCol

        anchors.centerIn: parent
        spacing: Appearance.spacing.small / 2

        MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            text: "wifi"
            color: Colors.palette.m3secondary
            font.pointSize: Appearance.font.size.normal
        }
    }
}
