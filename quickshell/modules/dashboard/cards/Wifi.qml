pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../config"
import "../../../services"

// Active network link, from the Network service. Sits directly on the dashboard
// base like Profile — one row on the card itself, no inner Tile. The title row
// is dropped because the left column can't spare the ~30px.
Card {
    RowLayout {
        anchors.fill: parent
        spacing: Appearance.spacing.small

        MaterialIcon {
            text: Network.icon
            color: Network.connected ? Colors.green : Colors.red
            font.pointSize: Appearance.font.size.normal
        }

        StyledText {
            Layout.fillWidth: true
            text: Network.nameStr
            color: Colors.palette.m3onSurface
            font.pointSize: Appearance.font.size.small
            elide: Text.ElideRight
        }

        RateItem {
            glyph: "arrow_downward"
            glyphColor: Colors.orange
            value: Network.fmtRate(Network.rxRate)
        }

        RateItem {
            glyph: "arrow_upward"
            glyphColor: Colors.purple
            value: Network.fmtRate(Network.txRate)
        }
    }

    // Arrow + figure. The figure gets a floor width so the name beside it
    // doesn't shuffle sideways every time the rate gains or loses a digit.
    component RateItem: RowLayout {
        id: item

        required property string glyph
        required property color glyphColor
        required property string value

        Layout.fillWidth: false
        spacing: 2

        MaterialIcon {
            text: item.glyph
            color: item.glyphColor
            font.pointSize: Appearance.font.size.small
        }

        StyledText {
            Layout.minimumWidth: 38
            text: item.value
            color: Colors.palette.m3onSurface
            font.pointSize: Appearance.font.size.small
            font.family: Appearance.font.family.mono
            horizontalAlignment: Text.AlignRight
        }
    }
}
