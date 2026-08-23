pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Active network link: which interface carries the default route, what it's
// connected to, and how fast bytes are moving over it.
//
// Two pollers on different cadences — the counters are just file reads and can
// tick fast, while the connection name costs an nmcli fork and barely changes.
Singleton {
    id: root

    property bool connected: false
    property string iface: ""
    property bool isWifi: false

    // SSID for wifi, NetworkManager connection name for ethernet
    property string name: ""
    // 0-100, wifi only
    property int signalStrength: 0

    // Bytes per second over the last sample window
    property real rxRate: 0
    property real txRate: 0
    // False until two samples exist — one sample can't produce a rate
    property bool hasRate: false

    readonly property string nameStr: connected ? (name || iface) : "Disconnected"

    readonly property string icon: {
        if (!connected)
            return "wifi_off";
        if (!isWifi)
            return "lan";
        if (signalStrength >= 75)
            return "network_wifi";
        if (signalStrength >= 50)
            return "network_wifi_3_bar";
        if (signalStrength >= 25)
            return "network_wifi_2_bar";
        if (signalStrength > 0)
            return "network_wifi_1_bar";
        return "signal_wifi_0_bar";
    }

    // Compact by necessity — the card lives in the 250px left column.
    function fmtRate(bps: real): string {
        if (!root.connected || !root.hasRate)
            return "—";

        const units = ["B", "K", "M", "G"];
        let v = bps;
        let i = 0;
        while (v >= 1024 && i < units.length - 1) {
            v /= 1024;
            i++;
        }
        return (v < 10 && i > 0 ? v.toFixed(1) : Math.round(v)) + units[i];
    }

    // Counter baseline. Kept per-interface: diffing eno1's totals against
    // wlan0's would render a spike of several GB/s on the tick after a switch.
    property string _baseIface: ""
    property real _rxPrev: 0
    property real _txPrev: 0
    property real _tPrev: 0

    function _dropBaseline(): void {
        root._baseIface = "";
        root._tPrev = 0;
        root.rxRate = 0;
        root.txRate = 0;
        root.hasRate = false;
    }

    Process {
        id: counterPoller

        running: true
        command: ["bash", "-c", `
            dev=$(ip -o route get 1.1.1.1 2>/dev/null | awk '{for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit }}')
            [ -n "$dev" ] || exit 0
            rx=$(cat "/sys/class/net/$dev/statistics/rx_bytes" 2>/dev/null)
            tx=$(cat "/sys/class/net/$dev/statistics/tx_bytes" 2>/dev/null)
            [ -n "$rx" ] && [ -n "$tx" ] || exit 0
            wl=0
            [ -d "/sys/class/net/$dev/wireless" ] && wl=1
            printf '%s %s %s %s\n' "$dev" "$rx" "$tx" "$wl"
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/);
                if (parts.length < 4) {
                    // No default route — the link is down
                    root.connected = false;
                    root.signalStrength = 0;
                    root._dropBaseline();
                    return;
                }

                const dev = parts[0];
                const rx = parseFloat(parts[1]);
                const tx = parseFloat(parts[2]);
                if (isNaN(rx) || isNaN(tx))
                    return;

                root.connected = true;
                root.iface = dev;
                root.isWifi = parts[3] === "1";

                // Elapsed time is measured, not assumed: Process restarts drift
                // off the nominal interval and would skew the rate.
                const now = Date.now();
                if (root._baseIface === dev && root._tPrev > 0) {
                    const dt = (now - root._tPrev) / 1000;
                    const drx = rx - root._rxPrev;
                    const dtx = tx - root._txPrev;
                    if (dt > 0 && drx >= 0 && dtx >= 0) {
                        root.rxRate = drx / dt;
                        root.txRate = dtx / dt;
                        root.hasRate = true;
                    }
                } else {
                    root.rxRate = 0;
                    root.txRate = 0;
                    root.hasRate = false;
                }

                root._baseIface = dev;
                root._rxPrev = rx;
                root._txPrev = tx;
                root._tPrev = now;
            }
        }
    }

    // Tab-separated so SSIDs with spaces survive the split
    Process {
        id: infoPoller

        running: true
        command: ["bash", "-c", `
            dev=$(ip -o route get 1.1.1.1 2>/dev/null | awk '{for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit }}')
            [ -n "$dev" ] || exit 0
            name=$(nmcli -t -f DEVICE,NAME connection show --active 2>/dev/null | awk -F: -v d="$dev" '$1 == d { print $2; exit }')
            sig=$(awk -v d="$dev:" 'NR > 2 && $1 == d { gsub(/\\./, "", $3); print int($3 * 100 / 70); exit }' /proc/net/wireless 2>/dev/null)
            printf '%s\t%s\n' "$name" "$sig"
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.replace(/\n$/, "").split("\t");
                if (parts.length < 2)
                    return;

                root.name = parts[0];
                const sig = parseInt(parts[1]);
                root.signalStrength = isNaN(sig) ? 0 : Math.max(0, Math.min(100, sig));
            }
        }
    }

    function _restart(proc: var): void {
        proc.running = false;
        proc.running = true;
    }

    // Fast tick: throughput should feel live
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root._restart(counterPoller)
    }

    // Slow tick: the SSID and signal bar move far more slowly, and this one forks nmcli
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: root._restart(infoPoller)
    }
}
