pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../config"
import "../cards"

// The card grid — the dashboard's default page. Moved out of Content.qml when
// the app launcher became a second page.
//
// Layout gotcha: nested Layouts default to fillWidth/fillHeight, which silently
// overrides Layout.preferredWidth/Height. The left column and the top row must
// keep their explicit fillWidth/fillHeight false or the grid collapses.
RowLayout {
    id: root

    required property DrawerVisibilities visibilities

    spacing: Appearance.spacing.normal

    // ── Left column: profile over power actions ──
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

        Wifi {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
        }

        Power {
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
                Layout.preferredWidth: 125
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
