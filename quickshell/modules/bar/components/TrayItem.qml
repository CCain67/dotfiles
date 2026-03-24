pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.SystemTray
import "../../../config"
import "../../../services"
import "../../../utils"

// Single system-tray icon. Left-click activates; right-click secondary-activates.
Item {
    id: root

    required property SystemTrayItem modelData

    implicitWidth: Config.bar.innerWidth - Appearance.padding.small * 4
    implicitHeight: implicitWidth

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor

        onClicked: event => {
            if (event.button === Qt.LeftButton)
                root.modelData.activate();
            else
                root.modelData.secondaryActivate();
        }
    }

    Image {
        anchors.fill: parent
        source: Icons.getTrayIcon(root.modelData.id, root.modelData.icon)
        fillMode: Image.PreserveAspectFit
        smooth: true
    }
}
