pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // 0.0 – 1.0
    property real brightness: 0
    readonly property int busNum: 6
    readonly property real increment: 0.05

    function setBrightness(value: real): void {
        value = Math.max(0, Math.min(1, value));
        const rounded = Math.round(value * 100);
        if (Math.round(brightness * 100) === rounded)
            return;

        brightness = value;

        if (debounce.running) {
            pending = rounded;
            return;
        }

        _send(rounded);
        debounce.restart();
    }

    function increase(): void { setBrightness(brightness + increment); }
    function decrease(): void { setBrightness(brightness - increment); }

    property int pending: -1

    function _send(value: int): void {
        Quickshell.execDetached(["ddcutil", "-b", busNum, "setvcp", "10", value]);
    }

    Timer {
        id: debounce
        interval: 500
        onTriggered: {
            if (root.pending >= 0) {
                root._send(root.pending);
                root.pending = -1;
                restart();
            }
        }
    }

    Process {
        running: true
        command: ["ddcutil", "-b", root.busNum, "getvcp", "10", "--brief"]
        stdout: StdioCollector {
            onStreamFinished: {
                // Format: "VCP 10 C <current> <max>"
                const parts = text.trim().split(" ");
                if (parts.length >= 5)
                    root.brightness = parseInt(parts[3]) / parseInt(parts[4]);
            }
        }
    }
}
