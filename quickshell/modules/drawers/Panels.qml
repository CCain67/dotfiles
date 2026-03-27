pragma ComponentBehavior: Bound

import QtQuick
import "../../components"
import "../../config"
import "../launcher" as Launcher
import "../session" as Session

// Panel content area: launcher at top-left, session at bottom-left.
Item {
    id: root

    required property DrawerVisibilities visibilities

    // App launcher — slides down from top
    Launcher.Wrapper {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: Appearance.padding.large
        anchors.leftMargin: Appearance.padding.large
        visibilities: root.visibilities
    }

    // Power/session menu — slides in from left at bottom
    Session.Wrapper {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: Appearance.padding.large
        anchors.leftMargin: Appearance.padding.large
        visibilities: root.visibilities
    }
}
