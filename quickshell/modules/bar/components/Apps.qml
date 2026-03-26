import QtQuick
import "../../../components"
import "../../../services"
import "../../../config"

// OS logo button. Will toggle the launcher in Phase 4.
Item {
    id: root

    implicitWidth: Config.bar.innerWidth
    implicitHeight: Config.bar.innerWidth

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        // onClicked: will toggle launcher (Phase 4)
    }

    MaterialIcon {
        anchors.centerIn: parent
        text: "apps"
        color: Colors.palette.m3tertiary
        font.pointSize: Appearance.font.size.large
    }
}
