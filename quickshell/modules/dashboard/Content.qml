pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import "../../components"
import "../../config"
import "../../services"
import "cards"

// Dashboard card grid.
Item {
    id: root

    required property DrawerVisibilities visibilities

    readonly property int pad: Appearance.padding.large

    implicitWidth: Config.dashboard.width
    implicitHeight: Config.dashboard.height

    focus: true
    Keys.onEscapePressed: root.visibilities.dashboard = false

    Component.onCompleted: Qt.callLater(forceActiveFocus)

    Connections {
        target: root.visibilities

        function onDashboardChanged(): void {
            if (root.visibilities.dashboard)
                root.forceActiveFocus();
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

    RowLayout {
        anchors.fill: parent
        anchors.margins: root.pad
        spacing: Appearance.spacing.normal

        // ── Left column: profile over quick launch ──
        ColumnLayout {
            // Nested layouts default to filling; pin this one to its width
            Layout.fillWidth: false
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            spacing: Appearance.spacing.normal

            Profile {
                Layout.fillWidth: true
                Layout.preferredHeight: 190
            }

            QuickLaunch {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visibilities: root.visibilities
            }
        }

        // ── Right area ──
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Appearance.spacing.normal

            // Top row: clock + weather, sliders, specs
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: false
                Layout.preferredHeight: 240
                spacing: Appearance.spacing.normal

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Appearance.spacing.normal

                    Clock {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 110
                    }

                    Weather {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }

                Sliders {
                    Layout.preferredWidth: 150
                    Layout.fillHeight: true
                }

                Specs {
                    Layout.preferredWidth: 360
                    Layout.fillHeight: true
                }
            }

            // Middle row: media player + resource usage
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Appearance.spacing.normal

                Media {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Resources {
                    Layout.preferredWidth: 275
                    Layout.fillHeight: true
                }
            }

            // Bottom row: web shortcuts
            Links {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                visibilities: root.visibilities
            }
        }
    }
}
