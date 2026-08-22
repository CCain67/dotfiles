pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Static-ish system identity for the dashboard specs card. Everything except
// uptime is gathered once at startup; uptime re-polls every minute.
Singleton {
    id: root

    property string os: "—"
    property string kernel: "—"
    property string wm: "—"
    property string shell: "—"
    property string host: "—"
    property string packages: "—"
    property string uptime: "—"
    property string user: "—"

    // One shot, one subprocess: seven newline-separated fields.
    Process {
        running: true
        command: ["bash", "-c", `
            . /etc/os-release 2>/dev/null
            echo "\${PRETTY_NAME:-\${NAME:-Linux}}"
            uname -r
            hyprctl version 2>/dev/null | head -1 | grep -oE 'v[0-9.]+' | head -1 | sed 's/^/Hyprland /' || echo Hyprland
            basename "\${SHELL:-sh}"
            uname -n
            pacman -Qq 2>/dev/null | wc -l
            id -un
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length >= 7) {
                    root.os = lines[0];
                    root.kernel = lines[1];
                    root.wm = lines[2] || "Hyprland";
                    root.shell = lines[3];
                    root.host = lines[4];
                    root.packages = lines[5];
                    root.user = lines[6];
                }
            }
        }
    }

    Process {
        id: uptimePoller

        running: true
        command: ["bash", "-c", "uptime -p | sed 's/^up //'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const val = text.trim();
                if (val)
                    root.uptime = val;
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            uptimePoller.running = false;
            uptimePoller.running = true;
        }
    }
}
