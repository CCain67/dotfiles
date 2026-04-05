pragma ComponentBehavior: Bound

import QtQuick
import "../../components"
import "../../config"
import "../session" as Session

// Panel content area: session at bottom-left.
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
}
