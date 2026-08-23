pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property alias enabled: clock.enabled
    readonly property date date: clock.date
    readonly property int hours: clock.hours
    readonly property int minutes: clock.minutes
    readonly property int seconds: clock.seconds

    // 12-hour clock, with the meridiem kept separate so it can be styled
    // independently (see dashboard/cards/Clock.qml).
    readonly property string clockStr: format("hh:mm ap").split(" ")[0] ?? ""
    readonly property string ampmStr: format("ap")
    readonly property string timeStr: clockStr + ampmStr
    readonly property string hourStr: clockStr.split(":")[0] ?? ""
    readonly property string minuteStr: clockStr.split(":")[1] ?? ""

    function format(fmt: string): string {
        return Qt.formatDateTime(clock.date, fmt);
    }

    SystemClock {
        id: clock

        precision: SystemClock.Seconds
    }
}
