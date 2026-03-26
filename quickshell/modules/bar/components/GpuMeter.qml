import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../../components"
import "../../../services"
import "../../../config"

// Vertical GPU meter: GPU icon, utilization %, temperature with color coding.
// Polls nvidia-smi every 3 seconds.
Rectangle {
    id: root

    implicitWidth: Config.bar.innerWidth + Appearance.padding.smaller
    implicitHeight: gpuLayout.implicitHeight + Appearance.padding.normal
    color: Colors.palette.m3surfaceDim
    radius: 6

    property int gpuUtil: 0
    property int gpuTemp: 0

    property color tempColor: {
        if (gpuTemp < 50) return Colors.green
        if (gpuTemp < 70) return Colors.yellow
        if (gpuTemp < 82) return Colors.orange
        return Colors.red
    }

    Process {
        id: utilPoller
        running: true
        command: ["bash", "-c", "nvidia-smi --query-gpu=utilization.gpu --format=csv,nounits,noheader"]
        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseInt(text.trim())
                if (!isNaN(val))
                    root.gpuUtil = val
            }
        }
    }

    Process {
        id: tempPoller
        running: true
        command: ["bash", "-c", "nvidia-smi --query-gpu=temperature.gpu --format=csv,nounits,noheader"]
        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseInt(text.trim())
                if (!isNaN(val))
                    root.gpuTemp = val
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            utilPoller.running = false
            utilPoller.running = true
            tempPoller.running = false
            tempPoller.running = true
        }
    }

    ColumnLayout {
        id: gpuLayout

        anchors.centerIn: parent
        spacing: 1

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: root.gpuUtil.toString().padStart(2, "0") + "%"
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
            color: Colors.palette.m3surface
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
            color: Colors.palette.m3surface
        }
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: root.gpuTemp.toString().padStart(2, "0") + "°"
            font.pointSize: Appearance.font.size.small
            font.family: Appearance.font.family.mono
            color: root.tempColor
        }
    }
}
