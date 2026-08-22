import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../services"
import "../../../config"

// Vertical RAM meter: used GB, memory icon, total GB.
// Values come from the shared SysUsage service.
Rectangle {
    id: root

    implicitWidth: Config.bar.innerWidth + Appearance.padding.smaller
    implicitHeight: ramLayout.implicitHeight + Appearance.padding.normal
    color: Colors.palette.m3surface
    radius: 6

    ColumnLayout {
        id: ramLayout

        anchors.centerIn: parent
        spacing: 1

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: SysUsage.ramUsedStr
            font.pointSize: Appearance.font.size.small
            font.family: Appearance.font.family.mono
            color: Colors.yellow
        }
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 2
            Layout.bottomMargin: 4
            width: 22
            height: 2
            color: Colors.palette.m3surfaceDim
        }
        MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            text: "memory"
            color: Colors.foreground
            visible: Config.bar.clock.showIcon
        }
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 2
            Layout.bottomMargin: 4
            width: 22
            height: 2
            color: Colors.palette.m3surfaceDim
        }
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: SysUsage.ramTotalStr
            font.pointSize: Appearance.font.size.small
            font.family: Appearance.font.family.mono
            color: Colors.green
        }
    }
}
