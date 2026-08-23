pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../config"

// The active colour theme.
//
// Themes are JSON files in Config.theme.dir — each supplies ~22 raw colours plus
// a wallpaper. Colors.qml maps those onto the full M3 role set, so a theme file
// never spells out an m3* role and every theme gets all 53 for free.
//
// JSON rather than QML because the downstream generators (scripts/theme-apply.sh)
// have to read the same colours from a shell script; QML themes would mean two
// sources of truth for one palette.
Singleton {
    id: root

    // Baked Gruvbox Material Dark. Only ever used if themes/ is missing, empty or
    // unparseable, or during the moment before the loader returns — the shell
    // degrades to today's look instead of rendering black.
    readonly property var fallback: ({
            name: "gruvbox-material-dark",
            label: "Gruvbox Material Dark (built-in)",
            light: false,
            wallpaper: "",
            wallpaperPath: "",
            red: "#ea6962",
            darkRed: "#c14a4a",
            orange: "#e78a4e",
            darkOrange: "#c35e0a",
            yellow: "#d8a657",
            darkYellow: "#b47109",
            green: "#a9b665",
            darkGreen: "#6c782e",
            cyan: "#89b482",
            darkCyan: "#4c7a5d",
            blue: "#7daea3",
            darkBlue: "#45707a",
            purple: "#d3869b",
            darkPurple: "#945e80",
            grey: "#928374",
            greyDark: "#7c6f64",
            greyLight: "#a89984",
            background: "#32302f",
            backgroundDark: "#252423",
            backgroundLight: "#504945",
            foreground: "#d4be98",
            foregroundDark: "#ddc7a1",
            foregroundLight: "#ebdbb2",
            surfaceLowest: "#1d1c1a",
            surfaceHigh: "#3c3836",
            shadow: "#000000",
            scrim: "#000000"
        })

    // Every theme found on disk, sorted by label.
    property var themes: []

    // Name of the active theme. Written by apply(); seeded from the state file.
    property string currentName: Config.theme.defaultTheme

    // The active theme object — the single property everything else rebinds on.
    // Changing it repropagates through Colors.qml to all ~170 colour call sites.
    readonly property var raw: {
        const t = themes.find(x => x.name === currentName);
        return t ?? (themes.length > 0 ? themes[0] : fallback);
    }

    readonly property bool light: raw.light ?? false
    readonly property string wallpaper: raw.wallpaperPath ?? ""
    readonly property bool loaded: themes.length > 0

    // Switches theme: repaints the shell, swaps the wallpaper, and (when enabled)
    // fires the downstream app generators.
    //
    // Side effects go through Quickshell.execDetached — the fire-and-forget
    // pattern already used by Brightness and the session menu. Nothing here
    // needs to read output back.
    //
    // NOTE ON PATHS: Config.theme.* paths contain a literal "$HOME". That only
    // expands when it is interpolated into the *script text*, where bash parses
    // it — passing one as an argv element hands bash the literal string and it
    // silently writes to a directory called "$HOME". So config paths go in the
    // script body; runtime values (theme name, wallpaper path) stay in argv,
    // where they cannot be spliced into the command.
    function apply(name: string): void {
        if (!themes.some(t => t.name === name)) {
            console.warn(`Theme: no such theme '${name}'`);
            return;
        }

        root.currentName = name;

        Quickshell.execDetached(["bash", "-c", `
            state="${Config.theme.stateFile}"
            mkdir -p "$(dirname "$state")" && printf %s "$1" > "$state"
        `, "bash", name]);

        applyWallpaper();

        if (Config.theme.applyDownstream)
            Quickshell.execDetached(["bash", "-c", `exec "${Config.theme.applyScript}" "${Config.theme.dir}/$1.json"`, "bash", name]);
    }

    // Wallpaper has two halves: hyprpaper's IPC for the running session, and the
    // `path =` line in hypr/hyprpaper.conf so the choice survives a Hyprland
    // restart. The conf file is in the repo, so this does dirty `git status` —
    // that is intended: theme choice is committed dotfile state.
    function applyWallpaper(): void {
        const path = root.wallpaper;
        const monitor = Screens.screen?.name ?? "";
        if (!path || !monitor)
            return;

        Quickshell.execDetached(["bash", "-c", `
            # 'wallpaper' is the only swap request this hyprpaper (0.8.4) accepts:
            # 'reload', 'preload' and 'unload' are all rejected as invalid, and no
            # separate preload step is needed.
            hyprctl hyprpaper wallpaper "$1,$2" >/dev/null || exit 0

            # Rewrite only the path line, preserving its indentation and every
            # other key (monitor, fit_mode, splash).
            conf="${Config.theme.hyprpaperConf}"
            [ -w "$conf" ] || exit 0
            tmp=$(mktemp) || exit 0
            awk -v p="$2" '
                /^[[:space:]]*path[[:space:]]*=/ {
                    match($0, /^[[:space:]]*/)
                    print substr($0, 1, RLENGTH) "path = " p
                    next
                }
                { print }
            ' "$conf" > "$tmp" && mv "$tmp" "$conf"
        `, "bash", monitor, path]);
    }

    // Re-scans themes/ so a newly dropped JSON file shows up without restarting
    // the shell. Called when the Themes page becomes visible — cheap enough to
    // run on every open (one bash + jq over a handful of files).
    function reload(): void {
        loader.running = false;
        loader.running = true;
    }

    // Slurps every themes/*.json into an array, resolves each wallpaper to an
    // absolute path, and reads the persisted selection. Runs at startup and on
    // every reload().
    Process {
        id: loader

        running: true
        command: ["bash", "-c", `
            DIR="${Config.theme.dir}"
            ROOT="${Config.theme.wallpaperRoot}"
            STATE="${Config.theme.stateFile}"

            sel=$(head -1 "$STATE" 2>/dev/null | tr -d '[:space:]')

            themes=$(jq -s --arg root "$ROOT" '
                map(. + {
                    wallpaperPath: (
                        if (.wallpaper // "") == "" then ""
                        elif (.wallpaper | startswith("/")) then .wallpaper
                        else $root + "/" + .wallpaper
                        end
                    )
                }) | sort_by(.label // .name)
            ' "$DIR"/*.json 2>/dev/null) || themes='[]'

            jq -n --arg sel "$sel" --argjson themes "\${themes:-[]}" '{selected: $sel, themes: $themes}'
        `]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text.trim());
                    if (!Array.isArray(d.themes) || d.themes.length === 0) {
                        console.warn("Theme: no themes found, using built-in fallback");
                        return;
                    }

                    root.themes = d.themes;
                    if (d.selected && d.themes.some(t => t.name === d.selected))
                        root.currentName = d.selected;
                } catch (e) {
                    console.warn("Theme: could not parse theme list —", e);
                }
            }
        }
    }
}
