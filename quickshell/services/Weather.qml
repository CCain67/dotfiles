pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../config"

// OpenWeather current conditions.
//
// The API key is read from a file OUTSIDE this repo (Config.weather.keyFile) so
// it never lands in git. Responses are cached to disk and replayed on failure,
// so a network blip or a cold start doesn't blank the card.
//
// JSON is parsed here rather than piped through jq — one less dependency, and
// it avoids the field-splitting that breaks on multi-word city names.
Singleton {
    id: root

    property bool loaded: false
    property bool keyMissing: false

    property real temp: 0
    property real feelsLike: 0
    property int humidity: 0
    property real windSpeed: 0
    property string condition: ""
    property string description: ""
    property string iconCode: ""
    property string city: ""

    readonly property string unitSymbol: Config.weather.units === "imperial" ? "°F" : "°C"
    readonly property string tempStr: loaded ? `${Math.round(temp)}${unitSymbol}` : "—"

    // Title-cases the API's lowercase description ("broken clouds")
    readonly property string conditionStr: {
        if (keyMissing)
            return "No API key";
        if (!loaded)
            return "Unavailable";
        return description.replace(/\b\w/g, c => c.toUpperCase());
    }

    readonly property string icon: {
        if (!loaded)
            return "cloud_off";
        const night = iconCode.endsWith("n");
        switch (iconCode.slice(0, 2)) {
        case "01": return night ? "clear_night" : "clear_day";
        case "02": return night ? "partly_cloudy_night" : "partly_cloudy_day";
        case "03": return "cloud";
        case "04": return "filter_drama";
        case "09": return "rainy";
        case "10": return night ? "rainy" : "rainy";
        case "11": return "thunderstorm";
        case "13": return "weather_snowy";
        case "50": return "foggy";
        default: return "cloud";
        }
    }

    // Static phrase table — not from the API. Keyed on condition + time of day.
    readonly property string quip: {
        if (!loaded)
            return "";

        const h = Time.hours;
        const part = h < 5 ? "night" : h < 12 ? "morning" : h < 17 ? "afternoon" : h < 21 ? "evening" : "night";

        const table = {
            Clear: {
                morning: "Clear skies to start the day.",
                afternoon: "Bright and clear out there.",
                evening: "A peaceful evening, perfect for compiling.",
                night: "Clear night — good stargazing."
            },
            Clouds: {
                morning: "Grey start, but it'll do.",
                afternoon: "Overcast and steady.",
                evening: "Cloudy evening, cosy indoors.",
                night: "Thick cloud overhead."
            },
            Rain: {
                morning: "Rain on the window. Stay in.",
                afternoon: "Wet out — worth an umbrella.",
                evening: "Rainy evening, ideal for headphones.",
                night: "Rain all night by the sound of it."
            },
            Snow: {
                morning: "Snow's falling. Mind the roads.",
                afternoon: "Snowy out there.",
                evening: "Snowfall and quiet streets.",
                night: "Snowing through the night."
            },
            Thunderstorm: {
                morning: "Storms rolling in early.",
                afternoon: "Thunder about — maybe unplug.",
                evening: "Storms tonight.",
                night: "Thunder in the dark."
            }
        };

        const group = table[condition] ?? {
            morning: "Another morning underway.",
            afternoon: "The afternoon carries on.",
            evening: "Winding down for the evening.",
            night: "Late and quiet."
        };
        return group[part];
    }

    Process {
        id: fetcher

        running: true
        command: ["bash", "-c", `
            KEY_FILE="${Config.weather.keyFile}"
            CACHE="$HOME/.cache/quickshell-weather.json"

            if [ ! -r "$KEY_FILE" ]; then
                echo NOKEY
                exit 0
            fi

            KEY=$(head -1 "$KEY_FILE" | tr -d "[:space:]")
            if [ -z "$KEY" ]; then
                echo NOKEY
                exit 0
            fi

            resp=$(curl -sf --max-time 10 "https://api.openweathermap.org/data/2.5/weather?APPID=$KEY&id=${Config.weather.cityId}&units=${Config.weather.units}")

            if [ -n "$resp" ] && printf '%s' "$resp" | grep -q '"main"'; then
                mkdir -p "$(dirname "$CACHE")"
                printf '%s' "$resp" > "$CACHE"
            fi

            cat "$CACHE" 2>/dev/null
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const raw = text.trim();

                if (raw === "NOKEY") {
                    root.keyMissing = true;
                    root.loaded = false;
                    return;
                }

                root.keyMissing = false;
                if (!raw)
                    return;

                try {
                    const d = JSON.parse(raw);
                    if (!d.main)
                        return;

                    root.temp = d.main.temp ?? 0;
                    root.feelsLike = d.main.feels_like ?? 0;
                    root.humidity = d.main.humidity ?? 0;
                    root.windSpeed = d.wind?.speed ?? 0;
                    root.condition = d.weather?.[0]?.main ?? "";
                    root.description = d.weather?.[0]?.description ?? "";
                    root.iconCode = d.weather?.[0]?.icon ?? "";
                    root.city = d.name ?? "";
                    root.loaded = true;
                } catch (e) {
                    // Malformed cache or response — keep whatever we had
                }
            }
        }
    }

    Timer {
        interval: Config.weather.pollInterval
        running: true
        repeat: true
        onTriggered: {
            fetcher.running = false;
            fetcher.running = true;
        }
    }
}
