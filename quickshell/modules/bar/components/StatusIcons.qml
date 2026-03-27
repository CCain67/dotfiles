import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../services"
import "../../../config"

// Status icon strip. Phase 2: wifi placeholder only.
// Audio, network service, Bluetooth added when those services are ported (Phase 3).
Rectangle {
    id: root

    implicitWidth: Config.bar.innerWidth + Appearance.padding.smaller
    implicitHeight: iconCol.implicitHeight + Appearance.padding.normal
    color: Colors.palette.m3surface
    radius: 6

    ColumnLayout {
        id: iconCol

        anchors.centerIn: parent
        spacing: 1
        
        MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            text: "wifi"
            color: Colors.green
            font.pointSize: Appearance.font.size.normal
        }
    }
}
