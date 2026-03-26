import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../services"
import "../../../config"

// Vertical clock: optional calendar icon, then HH / MM in monospace.
Rectangle {
    id: root

    implicitWidth: Config.bar.innerWidth
    implicitHeight: clockLayout.implicitHeight + Appearance.padding.normal
    color: Colors.palette.m3surfaceDim
    radius: 6

    ColumnLayout {
        id: clockLayout

        anchors.centerIn: parent
        spacing: 1

        MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            text: "calendar_month"
            color: Colors.palette.m3tertiary
            visible: Config.bar.clock.showIcon
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Time.format("hh ap").split(" ")[0]
            font.pointSize: Appearance.font.size.normal
            font.family: Appearance.font.family.mono
            color: Colors.palette.m3tertiary
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Time.format("mm")
            font.pointSize: Appearance.font.size.normal
            font.family: Appearance.font.family.mono
            color: Colors.palette.m3tertiary
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            visible: Config.bar.clock.showDate
            text: Time.format("ddd\nd")
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: Appearance.font.size.normal
            font.family: Appearance.font.family.mono
            color: Colors.palette.m3tertiary
        }
        
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 2
            Layout.bottomMargin: 4
            width: 22
            height: 2
            color: Colors.palette.m3surface
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Time.format("ddd")
            color: "#d4be98"
            font.pointSize: 9
            font.family: Appearance.font.family.mono
        }
    }
}
