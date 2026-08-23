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
        readonly property bool openExpanded: false
        readonly property real clearThreshold: 0.3
        readonly property int expandThreshold: 50
        readonly property int width: 400
        readonly property QtObject sizes: QtObject {
            readonly property int image: 48
            readonly property int badge: 20
        }
    }

    readonly property QtObject osd: QtObject {
        readonly property bool enabled: true
        readonly property int hideDelay: 2000
        readonly property bool enableBrightness: true
        readonly property int sliderWidth: 30
        readonly property int sliderHeight: 150
        readonly property int contentRevealDelay: 75  // ms to wait before fading in content
    }

    readonly property QtObject session: QtObject {
        readonly property bool vimKeybinds: false

        readonly property QtObject icons: QtObject {
            readonly property string logout: "exit_to_app"
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

    readonly property QtObject dashboard: QtObject {
        readonly property int width: 1320
        readonly property int height: 620

        // Themed app icons currently paint blank shell-wide (the launcher is
        // affected too) because the quickshell package is built against Qt
        // 6.11.0 while the system runs 6.11.1. Flip this to true after
        // rebuilding quickshell-git to get real app icons back.
        readonly property bool useAppIcons: false

        // Profile avatar. Empty, or a missing file, falls back to a glyph.
        readonly property string avatar: ""

        // Quick-launch column. `entry` is matched against desktop entries;
        // `icon` is the Material Symbol drawn when no app icon is used.
        readonly property var shortcuts: [
            { label: "Firefox",  entry: "firefox",         icon: "public" },
            { label: "Terminal", entry: "org.kde.konsole", icon: "terminal" },
            { label: "Files",    entry: "org.kde.dolphin", icon: "folder" },
            { label: "Editor",   entry: "code",            icon: "code" },
            { label: "Kate",     entry: "org.kde.kate",    icon: "edit_note" },
            { label: "Steam",    entry: "steam",           icon: "sports_esports" }
        ]

        // Web shortcuts. `accent` names a raw Gruvbox colour on Colors.
        readonly property var links: [
            { label: "GitHub",  icon: "code",          url: "https://github.com",    accent: "purple" },
            { label: "Reddit",  icon: "forum",         url: "https://reddit.com",    accent: "orange" },
            { label: "YouTube", icon: "smart_display", url: "https://youtube.com",   accent: "red" },
            { label: "Mail",    icon: "mail",          url: "https://mail.google.com", accent: "blue" },
            { label: "Twitch",  icon: "videocam",      url: "https://twitch.tv",     accent: "purple" },
            { label: "Docs",    icon: "menu_book",     url: "https://wiki.archlinux.org", accent: "green" }
        ]
    }

    readonly property QtObject weather: QtObject {
        // OpenWeather city id (4513583). Change with the id from openweathermap.org.
        readonly property string cityId: "4513583"
        readonly property string units: "imperial"   // or "metric"

        // Read at runtime from a mode-600 file OUTSIDE this repo, so the key is
        // never committed and is not world-readable. Create it with:
        //   install -m600 /dev/null ~/.config/openweather.key
        //   printf '%s' 'YOUR_KEY' > ~/.config/openweather.key
        readonly property string keyFile: "$HOME/.config/openweather.key"

        readonly property int pollInterval: 30 * 60 * 1000
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
