import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../config"
import "../../../services"

// Big 24-hour clock with the weekday/date stacked alongside, mirroring the
// reference layout. Time comes from the existing Time singleton.
Card {
    RowLayout {
        // Fill rather than centre-overflow: a centred row wider than the card
        // spills out both sides.
        anchors.fill: parent
        spacing: Appearance.spacing.large

        Item { Layout.fillWidth: true }

        StyledText {
            text: Time.timeStr
            font.family: Appearance.font.family.clock
            font.pointSize: 44
            font.weight: 500
            color: Colors.palette.m3onSurface
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.topMargin: Appearance.padding.small
            Layout.bottomMargin: Appearance.padding.small
            implicitWidth: 1
            color: Colors.palette.m3outlineVariant
        }

        ColumnLayout {
            spacing: 2

            StyledText {
                text: Time.format("dddd").toUpperCase()
                font.pointSize: Appearance.font.size.small
                font.letterSpacing: 1.5
                color: Colors.palette.m3tertiary
            }

            StyledText {
                Layout.fillWidth: true
                text: Time.format("MMMM d, yyyy")
                font.pointSize: Appearance.font.size.normal
                color: Colors.palette.m3onSurfaceVariant
                elide: Text.ElideRight
            }
        }

        Item { Layout.fillWidth: true }
    }
}
