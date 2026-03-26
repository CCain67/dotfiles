import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../../components"
import "../../../services"
import "../../../config"

// Vertical CPU meter: utilization %, CPU label, temperature with color coding.
// Polls /proc/stat for usage and hwmon for temp every 3 seconds.
Rectangle {
    id: root

    implicitWidth: Config.bar.innerWidth + Appearance.padding.smaller
    implicitHeight: cpuLayout.implicitHeight + Appearance.padding.normal
    color: Colors.palette.m3surfaceDim
    radius: 6

    property int cpuUtil: 0
    property int cpuTemp: 0

    property int _totalPrev: 0
    property int _idlePrev: 0

    property color tempColor: {
        if (cpuTemp < 55) return Colors.green
        if (cpuTemp < 75) return Colors.yellow
        if (cpuTemp < 88) return Colors.orange
        return Colors.red
    }

    Process {
        id: utilPoller
        running: true
        command: ["bash", "-c", "grep '^cpu ' /proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/)
                // cpu user nice system idle iowait irq softirq steal ...
                const user     = parseInt(parts[1])
                const nice     = parseInt(parts[2])
                const system   = parseInt(parts[3])
                const idle     = parseInt(parts[4])
                const iowait   = parseInt(parts[5])
                const irq      = parseInt(parts[6])
                const softirq  = parseInt(parts[7])
                const steal    = parseInt(parts[8])
                const total    = user + nice + system + idle + iowait + irq + softirq + steal

                if (root._totalPrev > 0) {
                    const diffIdle  = idle  - root._idlePrev
                    const diffTotal = total - root._totalPrev
                    if (diffTotal > 0)
                        root.cpuUtil = Math.round((diffTotal - diffIdle) / diffTotal * 100)
                }

                root._totalPrev = total
                root._idlePrev  = idle
            }
        }
    }

    Process {
        id: tempPoller
        running: true
        command: ["bash", "-c", `
            best=""
            for hw in /sys/class/hwmon/hwmon*; do
                [ -e "$hw/name" ] || continue
                name=$(cat "$hw/name" 2>/dev/null)
                case "$name" in
                    coretemp|k10temp)
                        for f in "$hw"/temp*_input; do
                            [ -e "$f" ] || continue
                            v=$(cat "$f" 2>/dev/null)
                            [ -n "$v" ] || continue
                            if [ -z "$best" ] || [ "$v" -gt "$best" ]; then
                                best="$v"
                            fi
                        done
                        ;;
                esac
            done
            [ -n "$best" ] && printf "%d\n" $((best/1000))
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseInt(text.trim())
                if (!isNaN(val))
                    root.cpuTemp = val
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
        id: cpuLayout

        anchors.centerIn: parent
        spacing: 1

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: root.cpuUtil.toString().padStart(2, "0") + "%"
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
            color: Colors.palette.m3surface
        }
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: root.cpuTemp.toString().padStart(2, "0") + "°"
            font.pointSize: Appearance.font.size.small
            font.family: Appearance.font.family.mono
            color: root.tempColor
        }
    }
}
