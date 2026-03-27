pragma ComponentBehavior: Bound

import QtQuick
import "../../components"
import "../../config"
import "../../services"

// Launcher card: app results above, search bar below.
Item {
    id: root

    required property DrawerVisibilities visibilities

    readonly property int pad: Appearance.padding.large
    readonly property int searchRowHeight: 44

    implicitWidth: Config.launcher.itemWidth + pad * 2
    implicitHeight: pad + appList.implicitHeight + Appearance.spacing.normal + searchRowHeight + pad

    // Background card
    StyledRect {
        anchors.fill: parent
        radius: Appearance.rounding.large
        color: Colors.palette.m3surfaceContainerHigh
        Behavior on color { CAnim {} }
    }

    AppList {
        id: appList
        anchors.top: parent.top
        anchors.topMargin: root.pad
        anchors.left: parent.left
        anchors.leftMargin: root.pad
        anchors.right: parent.right
        anchors.rightMargin: root.pad
        searchText: searchInput.text
        visibilities: root.visibilities
    }

    // Search pill
    StyledRect {
        id: searchBar
        anchors.top: appList.bottom
        anchors.topMargin: Appearance.spacing.normal
        anchors.left: parent.left
        anchors.leftMargin: root.pad
        anchors.right: parent.right
        anchors.rightMargin: root.pad
        height: root.searchRowHeight
        radius: Appearance.rounding.full
        color: Colors.palette.m3surfaceContainerHighest
        Behavior on color { CAnim {} }

        MaterialIcon {
            id: searchIcon
            anchors.left: parent.left
            anchors.leftMargin: root.pad
            anchors.verticalCenter: parent.verticalCenter
            text: "search"
            color: Colors.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.normal
        }

        // Placeholder shown when input is empty
        StyledText {
            anchors.left: searchIcon.right
            anchors.leftMargin: Appearance.spacing.small
            anchors.right: clearBtn.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Search applications..."
            color: Colors.palette.m3onSurfaceVariant
            opacity: 0.6
            visible: !searchInput.text
        }

        TextInput {
            id: searchInput
            anchors.left: searchIcon.right
            anchors.leftMargin: Appearance.spacing.small
            anchors.right: clearBtn.left
            anchors.rightMargin: Appearance.spacing.small
            anchors.verticalCenter: parent.verticalCenter
            color: Colors.palette.m3onSurface
            font.family: Appearance.font.family.sans
            font.pointSize: Appearance.font.size.normal
            clip: true

            Component.onCompleted: Qt.callLater(forceActiveFocus)

            Keys.onUpPressed: appList.decrementCurrentIndex()
            Keys.onDownPressed: appList.incrementCurrentIndex()
            Keys.onEscapePressed: root.visibilities.launcher = false
            Keys.onReturnPressed: {
                appList.launchCurrent()
                root.visibilities.launcher = false
            }
            Keys.onEnterPressed: {
                appList.launchCurrent()
                root.visibilities.launcher = false
            }

            Connections {
                target: root.visibilities
                function onLauncherChanged(): void {
                    if (root.visibilities.launcher)
                        searchInput.forceActiveFocus()
                    else
                        searchInput.text = ""
                }
            }
        }

        MaterialIcon {
            id: clearBtn
            anchors.right: parent.right
            anchors.rightMargin: root.pad
            anchors.verticalCenter: parent.verticalCenter
            text: "close"
            color: Colors.palette.m3onSurfaceVariant
            opacity: searchInput.text ? 1 : 0
            visible: opacity > 0

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: searchInput.text = ""
            }

            Behavior on opacity {
                Anim { duration: Appearance.anim.durations.small }
            }
        }
    }
}
