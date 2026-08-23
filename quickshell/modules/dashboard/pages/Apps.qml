pragma ComponentBehavior: Bound

import QtQuick
import "../../../components"
import "../../../config"
import "../../../services"
import "../cards"

// App launcher page — the old bar launcher, rehoused as a dashboard page.
// Search sits on top here (it was pinned to the bottom in the bar panel, where
// it hugged the bar edge) and the list below it scrolls to fill the page.
//
// Root is a Card so the page matches the outlined containers on the Info page;
// children land in the Card's body, so `parent` below is that body.
Card {
    id: root

    required property DrawerVisibilities visibilities

    readonly property int searchRowHeight: 44

    function focusSearch(): void {
        searchInput.forceActiveFocus();
    }

    // Search pill
    StyledRect {
        id: searchBar

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.searchRowHeight
        radius: Appearance.rounding.full
        color: Colors.palette.m3surfaceContainerHighest

        Behavior on color {
            CAnim {}
        }

        MaterialIcon {
            id: searchIcon

            anchors.left: parent.left
            anchors.leftMargin: Appearance.padding.large
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

            // The search field owns Escape while this page is focused, so it has
            // to close the dashboard itself — Content.qml's own Escape handler
            // does not see the key once this has focus.
            Keys.onEscapePressed: root.visibilities.dashboard = false
            Keys.onUpPressed: appList.selectPrev()
            Keys.onDownPressed: appList.selectNext()
            Keys.onReturnPressed: {
                appList.launchCurrent();
                root.visibilities.dashboard = false;
            }
            Keys.onEnterPressed: {
                appList.launchCurrent();
                root.visibilities.dashboard = false;
            }

            Connections {
                target: root.visibilities

                function onDashboardChanged(): void {
                    if (!root.visibilities.dashboard)
                        searchInput.text = "";
                }
            }
        }

        MaterialIcon {
            id: clearBtn

            anchors.right: parent.right
            anchors.rightMargin: Appearance.padding.large
            anchors.verticalCenter: parent.verticalCenter
            text: "close"
            color: Colors.palette.m3onSurfaceVariant
            opacity: searchInput.text ? 1 : 0
            visible: opacity > 0

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    searchInput.text = "";
                    searchInput.forceActiveFocus();
                }
            }

            Behavior on opacity {
                Anim {
                    duration: Appearance.anim.durations.small
                }
            }
        }
    }

    AppList {
        id: appList

        anchors.top: searchBar.bottom
        anchors.topMargin: Appearance.spacing.normal
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        searchText: searchInput.text
        onLaunched: root.visibilities.dashboard = false
    }
}
