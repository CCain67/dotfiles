pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Single owner of all resource polling. The bar meters and the dashboard
// resources card both read from here so the same numbers are only gathered once.
//
// Hardware assumptions (see CLAUDE.md): nvidia-smi for GPU, coretemp/k10temp
// hwmon for CPU temperature.
Singleton {
    id: root

    // CPU
    property int cpuUtil: 0
    property int cpuTemp: 0

    // GPU (NVIDIA only)
    property int gpuUtil: 0
    property int gpuTemp: 0

    // Memory, in GiB
    property real ramUsedGb: 0
    property real ramTotalGb: 0
    readonly property real ramPerc: ramTotalGb > 0 ? ramUsedGb / ramTotalGb : 0

    // Root filesystem, in GiB
    property real diskUsedGb: 0
    property real diskTotalGb: 0
    readonly property real diskPerc: diskTotalGb > 0 ? diskUsedGb / diskTotalGb : 0

    // Preserves the bar meters' original formatting
    readonly property string ramUsedStr: ramUsedGb.toFixed(1) + "G"
    readonly property string ramTotalStr: Math.round(ramTotalGb) + "G"

    property int _totalPrev: 0
    property int _idlePrev: 0

    // Threshold colouring shared by the meters. Defaults match the old CPU values.
    function tempColor(temp: int, warm: int, hot: int, crit: int): color {
        if (temp < warm)
            return Colors.green;
        if (temp < hot)
            return Colors.yellow;
        if (temp < crit)
            return Colors.orange;
        return Colors.red;
    }

    // Green → red ramp for a 0-1 utilisation fraction.
    function loadColor(perc: real): color {
        if (perc < 0.6)
            return Colors.green;
        if (perc < 0.8)
            return Colors.yellow;
        if (perc < 0.92)
            return Colors.orange;
        return Colors.red;
    }

    Process {
        id: cpuUtilPoller

        running: true
        command: ["bash", "-c", "grep '^cpu ' /proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/);
                // cpu user nice system idle iowait irq softirq steal ...
                const idle = parseInt(parts[4]);
                let total = 0;
                for (let i = 1; i <= 8; i++)
                    total += parseInt(parts[i]);

                if (root._totalPrev > 0) {
                    const diffIdle = idle - root._idlePrev;
                    const diffTotal = total - root._totalPrev;
                    if (diffTotal > 0)
                        root.cpuUtil = Math.round((diffTotal - diffIdle) / diffTotal * 100);
                }

                root._totalPrev = total;
                root._idlePrev = idle;
            }
        }
    }

    Process {
        id: cpuTempPoller

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
                const val = parseInt(text.trim());
                if (!isNaN(val))
                    root.cpuTemp = val;
            }
        }
    }

    // One nvidia-smi call for both values, instead of the two the meters used
    Process {
        id: gpuPoller

        running: true
        command: ["bash", "-c", "nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,nounits,noheader"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",");
                if (parts.length >= 2) {
                    const util = parseInt(parts[0]);
                    const temp = parseInt(parts[1]);
                    if (!isNaN(util))
                        root.gpuUtil = util;
                    if (!isNaN(temp))
                        root.gpuTemp = temp;
                }
            }
        }
    }

    Process {
        id: ramPoller

        running: true
        command: ["bash", "-c", "free -b | awk '/Mem:/ { print $2, $3 }'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/);
                if (parts.length >= 2) {
                    const gib = 1024 * 1024 * 1024;
                    root.ramTotalGb = parseInt(parts[0]) / gib;
                    root.ramUsedGb = parseInt(parts[1]) / gib;
                }
            }
        }
    }

    Process {
        id: diskPoller

        running: true
        command: ["bash", "-c", "df -B1 --output=size,used / | tail -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/);
                if (parts.length >= 2) {
                    const gib = 1024 * 1024 * 1024;
                    root.diskTotalGb = parseInt(parts[0]) / gib;
                    root.diskUsedGb = parseInt(parts[1]) / gib;
                }
            }
        }
    }

    function _restart(proc: var): void {
        proc.running = false;
        proc.running = true;
    }

    // Fast tick: CPU and GPU, as before
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            root._restart(cpuUtilPoller);
            root._restart(cpuTempPoller);
            root._restart(gpuPoller);
        }
    }

    // Slow tick: memory, as before
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root._restart(ramPoller)
    }

    // Disk moves far more slowly than anything else here
    Timer {
        interval: 300000
        running: true
        repeat: true
        onTriggered: root._restart(diskPoller)
    }
}
