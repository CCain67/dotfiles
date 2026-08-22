import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../config"
import "../../../services"

// Current conditions plus a time-of-day phrase. The phrase is a local static
// table, not something the API returns.
Card {
    ColumnLayout {
        anchors.fill: parent
        spacing: Appearance.spacing.small

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.normal

            StyledText {
                text: Weather.tempStr
                font.pointSize: Appearance.font.size.extraLarge
                font.weight: 500
                color: Colors.palette.m3onSurface
            }

            StyledText {
                Layout.fillWidth: true
                text: Weather.conditionStr
                font.pointSize: Appearance.font.size.normal
                color: Colors.palette.m3onSurfaceVariant
                elide: Text.ElideRight
            }

            MaterialIcon {
                text: Weather.icon
                color: Colors.palette.m3tertiary
                font.pointSize: Appearance.font.size.extraLarge
                fill: 1
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: Weather.quip
            font.pointSize: Appearance.font.size.small
            color: Colors.palette.m3outline
            elide: Text.ElideRight
            visible: text.length > 0
        }
    }
}
