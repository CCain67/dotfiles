import QtQuick
import "../../../components"
import "../../../services"
import "../../../config"

// OS logo button — opens the dashboard on its app launcher page.
Item {
    id: root

    required property DrawerVisibilities visibilities

    implicitWidth: Config.bar.innerWidth
    implicitHeight: Config.bar.innerWidth

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.visibilities.dashboard && root.visibilities.page === "apps") {
                root.visibilities.dashboard = false;
            } else {
                root.visibilities.page = "apps";
                root.visibilities.dashboard = true;
            }
        }
    }

    MaterialIcon {
        anchors.centerIn: parent
        text: "apps"
        color: Colors.palette.m3tertiary
        font.pointSize: Appearance.font.size.large
    }
}
