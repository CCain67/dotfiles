import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../services"
import "../../../config"

// Vertical CPU meter: utilization %, CPU label, temperature with color coding.
// Values come from the shared SysUsage service.
Rectangle {
    id: root

    implicitWidth: Config.bar.innerWidth + Appearance.padding.smaller
    implicitHeight: cpuLayout.implicitHeight + Appearance.padding.normal
    color: Colors.palette.m3surface
    radius: 6

    readonly property color tempColor: SysUsage.tempColor(SysUsage.cpuTemp, 55, 75, 88)

    ColumnLayout {
        id: cpuLayout

        anchors.centerIn: parent
        spacing: 1

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: SysUsage.cpuUtil.toString().padStart(2, "0") + "%"
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
            text: "developer_board"
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
            text: SysUsage.cpuTemp.toString().padStart(2, "0") + "°"
            font.pointSize: Appearance.font.size.small
            font.family: Appearance.font.family.mono
            color: root.tempColor
        }
    }
}
