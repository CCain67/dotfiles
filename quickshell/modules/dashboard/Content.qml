pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import "../../components"
import "../../config"
import "../../services"
import "pages"

// Dashboard card: a page switcher.
//   info   → the card grid (pages/Info.qml)
//   apps   → the app launcher (pages/Apps.qml)
//   themes → the colour theme picker (pages/Themes.qml)
// The page is state on Visibilities so the global shortcuts can open the
// dashboard straight onto a given page (SUPER+SPACE → info, SUPER+D → apps).
// Themes has no shortcut — it is reached through the tab strip.
Item {
    id: root

    required property DrawerVisibilities visibilities

    readonly property int pad: Appearance.padding.large
    readonly property string page: visibilities.page

    implicitWidth: Config.dashboard.width
    implicitHeight: Config.dashboard.height

    focus: true
    Keys.onEscapePressed: root.visibilities.dashboard = false

    // Only one thing claims focus per open: the Apps search field when that page
    // is up, otherwise this item (which owns Escape). Without this the search
    // field would silently keep focus after a page switch and swallow Escape.
    // The Themes page has no text input, so it takes the else branch and Escape
    // keeps working there.
    function syncFocus(): void {
        if (!root.visibilities.dashboard)
            return;

        if (root.page === "apps")
            appsPage.focusSearch();
        else
            root.forceActiveFocus();
    }

    onPageChanged: syncFocus()
    Component.onCompleted: Qt.callLater(syncFocus)

    Connections {
        target: root.visibilities

        function onDashboardChanged(): void {
            if (root.visibilities.dashboard)
                Qt.callLater(root.syncFocus);
        }
    }

    // Background card. Swallows clicks so the dismiss handler behind it doesn't fire.
    StyledRect {
        anchors.fill: parent

        radius: Appearance.rounding.large
        color: Colors.palette.m3surface

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            blurMax: 24
            shadowVerticalOffset: 4
            shadowColor: Qt.alpha(Colors.palette.m3shadow, 0.8)
        }

        MouseArea {
            anchors.fill: parent
        }
    }

    Row {
        id: pageSwitcher

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: root.pad
        anchors.leftMargin: root.pad
        height: Config.dashboard.pageHeader
        spacing: Appearance.spacing.small

        Repeater {
            model: [
                {
                    page: "info",
                    label: "Dashboard",
                    icon: "dashboard"
                },
                {
                    page: "apps",
                    label: "Apps",
                    icon: "apps"
                },
                {
                    page: "themes",
                    label: "Themes",
                    icon: "palette"
                }
            ]

            StyledRect {
                id: tab

                required property var modelData

                readonly property bool active: root.page === modelData.page
                readonly property color fg: active ? Colors.palette.m3primary : Colors.palette.m3onSurfaceVariant

                implicitWidth: tabRow.implicitWidth + Appearance.padding.large * 2
                implicitHeight: pageSwitcher.height
                radius: Appearance.rounding.full
                color: active ? Colors.palette.m3surfaceContainerHigh : "transparent"

                Behavior on color {
                    CAnim {}
                }

                StateLayer {
                    function onClicked(): void {
                        root.visibilities.page = tab.modelData.page;
                    }
                    radius: parent.radius
                }

                Row {
                    id: tabRow

                    anchors.centerIn: parent
                    spacing: Appearance.spacing.small

                    MaterialIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        text: tab.modelData.icon
                        color: tab.fg
                        font.pointSize: Appearance.font.size.normal

                        Behavior on color {
                            CAnim {}
                        }
                    }

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: tab.modelData.label
                        color: tab.fg
                        font.pointSize: Appearance.font.size.small

                        Behavior on color {
                            CAnim {}
                        }
                    }
                }
            }
        }
    }

    // Page area. Both pages stay alive once built and cross-fade — the Info page
    // owns no pollers of its own (SysUsage et al. are singletons), so keeping it
    // instantiated costs nothing.
    Item {
        id: pageArea

        anchors.top: pageSwitcher.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: Appearance.spacing.normal
        anchors.leftMargin: root.pad
        anchors.rightMargin: root.pad
        anchors.bottomMargin: root.pad

        Info {
            anchors.fill: parent

            visibilities: root.visibilities
            opacity: root.page === "info" ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                Anim {
                    duration: Appearance.anim.durations.small
                }
            }
        }

        Apps {
            id: appsPage

            anchors.fill: parent

            visibilities: root.visibilities
            opacity: root.page === "apps" ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                Anim {
                    duration: Appearance.anim.durations.small
                }
            }
        }

        Themes {
            anchors.fill: parent

            opacity: root.page === "themes" ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                Anim {
                    duration: Appearance.anim.durations.small
                }
            }
        }
    }
}
