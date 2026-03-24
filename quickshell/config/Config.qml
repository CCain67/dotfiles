pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string terminal: "konsole"

    readonly property QtObject border: QtObject {
        readonly property int thickness: 10   // Appearance.padding.normal
        readonly property int rounding: 25    // Appearance.rounding.large
    }

    readonly property QtObject bar: QtObject {
        readonly property bool persistent: true
        readonly property bool showOnHover: true
        readonly property int dragThreshold: 20
        readonly property int innerWidth: 40

        readonly property QtObject scrollActions: QtObject {
            readonly property bool workspaces: true
            readonly property bool volume: true
            readonly property bool brightness: true
        }

        readonly property QtObject workspaces: QtObject {
            readonly property int shown: 8
            readonly property bool showWindows: true
            readonly property int maxWindowIcons: 0   // 0 = unlimited
        }

        readonly property QtObject activeWindow: QtObject {
            readonly property bool compact: false
            readonly property bool showOnHover: true
        }

        readonly property QtObject tray: QtObject {
            readonly property bool compact: false
            readonly property list<string> hiddenIcons: []
        }

        readonly property QtObject status: QtObject {
            readonly property bool showNetwork: true
            readonly property bool showBattery: false   // desktop — no battery
        }

        readonly property QtObject clock: QtObject {
            readonly property bool showDate: false
            readonly property bool showIcon: true
        }
    }

    readonly property QtObject notifs: QtObject {
        readonly property bool expire: true
        readonly property int defaultExpireTimeout: 5000
        readonly property bool actionOnClick: false
        readonly property int groupPreviewNum: 3
        readonly property int width: 400
    }

    readonly property QtObject osd: QtObject {
        readonly property bool enabled: true
        readonly property int hideDelay: 2000
        readonly property bool enableBrightness: true
        readonly property int sliderWidth: 30
        readonly property int sliderHeight: 150
    }

    readonly property QtObject session: QtObject {
        readonly property bool vimKeybinds: false

        readonly property QtObject icons: QtObject {
            readonly property string logout: "logout"
            readonly property string shutdown: "power_settings_new"
            readonly property string hibernate: "downloading"
            readonly property string reboot: "cached"
        }

        readonly property QtObject commands: QtObject {
            readonly property list<string> logout: ["loginctl", "terminate-user", ""]
            readonly property list<string> shutdown: ["systemctl", "poweroff"]
            readonly property list<string> hibernate: ["systemctl", "hibernate"]
            readonly property list<string> reboot: ["systemctl", "reboot"]
        }
    }

    readonly property QtObject launcher: QtObject {
        readonly property int maxShown: 7
        readonly property bool vimKeybinds: false
        readonly property list<string> favouriteApps: []
        readonly property list<string> hiddenApps: []
        readonly property bool useFuzzy: false
        readonly property int itemWidth: 600
        readonly property int itemHeight: 57
    }

    readonly property QtObject services: QtObject {
        readonly property real audioIncrement: 0.05
        readonly property real brightnessIncrement: 0.05
        readonly property real maxVolume: 1.0
    }
}
