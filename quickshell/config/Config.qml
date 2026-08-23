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

    // Shared panel behaviour. Was `osd` until the right-edge OSD was retired;
    // the slider sizes outlived it (dashboard sliders card).
    readonly property QtObject panels: QtObject {
        readonly property int sliderWidth: 30
        readonly property int sliderHeight: 150
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
        readonly property int width: 1250

        // Height of the page-switcher strip above the page area.
        readonly property int pageHeader: 32

        // 590 of page area (the tuned height of the Info card grid) plus the
        // chrome above it: padding.large * 2 + pageHeader + spacing.normal.
        readonly property int height: 664

        // Read by nothing at the moment (its only consumer was the quick-launch
        // card). Themed app icons currently paint blank shell-wide (the Apps page
        // is affected too) because the quickshell package is built against Qt
        // 6.11.0 while the system runs 6.11.1. Flip this to true after
        // rebuilding quickshell-git to get real app icons back.
        readonly property bool useAppIcons: false

        // Profile avatar. Empty, or a missing file, falls back to a glyph.
        readonly property string avatar: ""

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

    // The app launcher — now the dashboard's "apps" page, not a panel of its own.
    // The list is uncapped and scrolls to fill the page, so there is no maxShown
    // or itemWidth any more; the page's anchors set the size.
    readonly property QtObject launcher: QtObject {
        readonly property bool vimKeybinds: false
        readonly property list<string> favouriteApps: []
        readonly property list<string> hiddenApps: []
        readonly property bool useFuzzy: false
        readonly property int itemHeight: 57
    }

    readonly property QtObject services: QtObject {
        readonly property real audioIncrement: 0.05
        readonly property real brightnessIncrement: 0.05
        readonly property real maxVolume: 1.0
    }
}
