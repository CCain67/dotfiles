import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../../components"
import "../../../services"
import "../../../config"

// Vertical RAM meter: used GB, memory icon, total GB.
// Polls `free` every 30 seconds.
Rectangle {
    id: root

    implicitWidth: Config.bar.innerWidth + Appearance.padding.smaller
    implicitHeight: ramLayout.implicitHeight + Appearance.padding.normal
    color: Colors.palette.m3surface
    radius: 6

    property string ramUsed: "0G"
    property string ramTotal: "0G"

    Process {
        id: ramPoller
        running: true
        command: ["bash", "-c", "free -b | awk '/Mem:/ { printf \"%.1f\\n%.0f\\n\", $3/1024/1024/1024, $2/1024/1024/1024 }'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                if (lines.length >= 2) {
                    root.ramUsed  = lines[0] + "G"
                    root.ramTotal = lines[1] + "G"
                }
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: {
            ramPoller.running = false
            ramPoller.running = true
        }
    }

    ColumnLayout {
        id: ramLayout

        anchors.centerIn: parent
        spacing: 1

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: root.ramUsed
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
            text: root.ramTotal
            font.pointSize: Appearance.font.size.small
            font.family: Appearance.font.family.mono
            color: Colors.green
        }
    }
}
