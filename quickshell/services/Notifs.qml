pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property list<NotifData> list: []
    readonly property var popups: list.filter(n => n.popup && !n.closed)
    property bool dnd: false

    function clear(): void {
        for (const n of root.list.slice())
            n.close();
    }

    NotificationServer {
        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notif => {
            notif.tracked = true;
            const obj = notifComp.createObject(root, {
                popup: !root.dnd,
                notification: notif
            });
            root.list = [obj, ...root.list];
        }
    }

    Component {
        id: notifComp
        NotifData {}
    }
}
