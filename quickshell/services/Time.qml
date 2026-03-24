pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property alias enabled: clock.enabled
    readonly property date date: clock.date
    readonly property int hours: clock.hours
    readonly property int minutes: clock.minutes
    readonly property int seconds: clock.seconds

    // 24-hour format — hardcoded, no config toggle
    readonly property string timeStr: format("hh:mm")
    readonly property string hourStr: timeStr.split(":")[0] ?? ""
    readonly property string minuteStr: timeStr.split(":")[1] ?? ""

    function format(fmt: string): string {
        return Qt.formatDateTime(clock.date, fmt);
    }

    SystemClock {
        id: clock

        precision: SystemClock.Seconds
    }
}
