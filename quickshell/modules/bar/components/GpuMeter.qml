import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../services"
import "../../../config"

// Vertical GPU meter: GPU icon, utilization %, temperature with color coding.
// Values come from the shared SysUsage service.
Rectangle {
    id: root

    implicitWidth: Config.bar.innerWidth + Appearance.padding.smaller
    implicitHeight: gpuLayout.implicitHeight + Appearance.padding.normal
    color: Colors.palette.m3surface
    radius: 6

    readonly property color tempColor: SysUsage.tempColor(SysUsage.gpuTemp, 50, 70, 82)

    ColumnLayout {
        id: gpuLayout

        anchors.centerIn: parent
        spacing: 1

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: SysUsage.gpuUtil.toString().padStart(2, "0") + "%"
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
            text: "network_intelligence"
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
            text: SysUsage.gpuTemp.toString().padStart(2, "0") + "°"
            font.pointSize: Appearance.font.size.small
            font.family: Appearance.font.family.mono
            color: root.tempColor
        }
    }
}
