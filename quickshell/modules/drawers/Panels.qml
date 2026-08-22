pragma ComponentBehavior: Bound

import QtQuick
import "../../components"
import "../../config"
import "../session" as Session
import "../dashboard" as Dashboard

// Panel content area: session at bottom-left, dashboard centered.
Item {
    id: root

    required property DrawerVisibilities visibilities

    // Power/session menu — slides in from left at bottom
    Session.Wrapper {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: Appearance.padding.large
        anchors.leftMargin: Appearance.padding.large
        visibilities: root.visibilities
    }

    // Centered dashboard — fills the interior so its scrim can dim the desktop
    Dashboard.Wrapper {
        anchors.fill: parent
        visibilities: root.visibilities
    }
}
