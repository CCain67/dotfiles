pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../config"

QtObject {
    id: notif

    property bool popup
    property bool closed
    property var locks: new Set()

    property date time: new Date()
    property string timeStr: qsTr("now")

    readonly property Timer timeStrTimer: Timer {
        running: !notif.closed
        repeat: true
        interval: 5000
        onTriggered: notif.updateTimeStr()
    }

    property Notification notification
    property string id
    property string summary
    property string body
    property string appIcon
    property string appName
    property string image
    property var hints
    property real expireTimeout: Config.notifs.defaultExpireTimeout
    property int urgency: NotificationUrgency.Normal
    property bool resident
    property bool hasActionIcons
    property list<var> actions

    readonly property Timer timer: Timer {
        running: notif.popup
        interval: notif.expireTimeout > 0 ? notif.expireTimeout : Config.notifs.defaultExpireTimeout
        onTriggered: {
            if (Config.notifs.expire)
                notif.popup = false;
        }
    }

    readonly property Connections conn: Connections {
        function onClosed(): void { if (!notif.closed) notif.close(); }
        function onSummaryChanged(): void { notif.summary = notif.notification.summary; }
        function onBodyChanged(): void { notif.body = notif.notification.body; }
        function onAppIconChanged(): void { notif.appIcon = notif.notification.appIcon; }
        function onAppNameChanged(): void { notif.appName = notif.notification.appName; }
        function onImageChanged(): void { notif.image = notif.notification.image; }
        function onExpireTimeoutChanged(): void { notif.expireTimeout = notif.notification.expireTimeout; }
        function onUrgencyChanged(): void { notif.urgency = notif.notification.urgency; }
        function onResidentChanged(): void { notif.resident = notif.notification.resident; }
        function onHasActionIconsChanged(): void { notif.hasActionIcons = notif.notification.hasActionIcons; }
        function onActionsChanged(): void {
            notif.actions = notif.notification.actions.map(a => ({
                identifier: a.identifier,
                text: a.text,
                invoke: () => a.invoke()
            }));
        }
        function onHintsChanged(): void { notif.hints = notif.notification.hints; }
        target: notif.notification
    }

    function updateTimeStr(): void {
        const diff = Date.now() - time.getTime();
        const m = Math.floor(diff / 60000);

        if (m < 1) {
            timeStr = qsTr("now");
            timeStrTimer.interval = 5000;
        } else {
            const h = Math.floor(m / 60);
            const d = Math.floor(h / 24);
            if (d > 0) {
                timeStr = `${d}d`;
                timeStrTimer.interval = 3600000;
            } else if (h > 0) {
                timeStr = `${h}h`;
                timeStrTimer.interval = 300000;
            } else {
                timeStr = `${m}m`;
                timeStrTimer.interval = m < 10 ? 30000 : 60000;
            }
        }
    }

    function lock(item: Item): void {
        locks.add(item);
    }

    function unlock(item: Item): void {
        locks.delete(item);
        if (closed) close();
    }

    function close(): void {
        closed = true;
        if (locks.size === 0) Qt.callLater(() => {
            if (!Notifs.list.includes(this)) return;
            Notifs.list = Notifs.list.filter(n => n !== this);
            notification?.dismiss();
            destroy();
        });
    }

    Component.onCompleted: {
        if (!notification) return;
        id = notification.id;
        summary = notification.summary;
        body = notification.body;
        appIcon = notification.appIcon;
        appName = notification.appName;
        image = notification.image;
        expireTimeout = notification.expireTimeout;
        hints = notification.hints;
        urgency = notification.urgency;
        resident = notification.resident;
        hasActionIcons = notification.hasActionIcons;
        actions = notification.actions.map(a => ({
            identifier: a.identifier,
            text: a.text,
            invoke: () => a.invoke()
        }));
    }
}
