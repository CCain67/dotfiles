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
            flat: false,
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

    // A flat theme has no elevation: every shadow in the shell is switched off,
    // Hyprland's window shadow and blur go with it, and the outline takes over
    // the job of separating surfaces. Absent from a theme file → false, so the
    // existing themes are untouched.
    readonly property bool flat: raw.flat ?? false
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
        applyCompositor();

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

    // Pushes the theme at the compositor: window shadow, blur, border size and
    // border colours. Without this a flat theme only flattens the shell — every
    // terminal and PDF reader keeps Hyprland's own shadow and blur and reads as
    // floating on top of the desktop, which is the whole thing a flat theme is
    // trying to avoid.
    //
    // ⚠ `hyprctl keyword` DOES NOT WORK on this system. hyprland.lua means the
    // Lua parser is active, and keyword returns "keyword can't work with
    // non-legacy parsers. Use eval." The working form is `hyprctl eval` with the
    // same hl.config() call the config file uses. Verified live 2026-08-24.
    //
    // Deliberately NOT gated behind Config.theme.applyDownstream: that flag
    // guards the scripts/theme/* stubs, which write other applications' config
    // files. This is the compositor hosting the shell, it writes nothing, and
    // gating it would mean a flat theme does not work until the stubs are real.
    //
    // hyprland.lua keeps its own literals as the pre-shell default — they are
    // what paints the boot, and rewriting the file on every theme click would be
    // a second source of truth for one fact.
    function applyCompositor(): void {
        const t = root.raw;
        if (!t)
            return;

        // Read flat off the theme object directly, NOT off root.flat. This runs
        // from onRawChanged, and `flat` is itself a binding on `raw` — it has not
        // necessarily re-evaluated yet when the change handler fires, so
        // root.flat still holds the previous theme's value. Cost the first time:
        // paperwhite repainted the shell but left Hyprland's shadow and blur on.
        const flat = t.flat ?? false;
        const hex = c => `rgba(${String(c ?? "#000000").replace("#", "")}ff)`;

        // Active border: on a flat theme backgroundLight is nearly invisible
        // against the page, so focus falls back to the mid-ink grey. Everywhere
        // else backgroundLight/backgroundDark reproduce hyprland.lua's literals.
        const active = hex(flat ? t.grey : t.backgroundLight);
        const inactive = hex(t.backgroundDark);

        // border_size is deliberately NOT set here. It is a static preference that
        // hyprland.lua owns, not theme state — writing it from the shell silently
        // overrode a hand-edited `border_size = 0` on the next theme switch.
        Quickshell.execDetached(["bash", "-c", `exec hyprctl eval "$1" >/dev/null`, "bash", `hl.config({
            general = {
                col = { active_border = "${active}", inactive_border = "${inactive}" }
            },
            decoration = {
                blur = { enabled = ${flat ? "false" : "true"} },
                shadow = { enabled = ${flat ? "false" : "true"} }
            }
        })`]);
    }

    // Reassert at the compositor whenever the active theme changes. Bound to the
    // theme rather than to apply() on purpose: Quickshell is autostarted by
    // hyprland.lua, so a Hyprland restart resets these to the file's literals and
    // this puts them back without the user touching anything.
    onRawChanged: applyCompositor()

    // A Hyprland config reload (`hyprctl reload`, or saving hyprland.lua) resets
    // everything applyCompositor() set via `eval` back to the config file. Since
    // hyprland.lua's decoration block does not mention `shadow`, that means the
    // window shadow silently returns at Hyprland's *default* of enabled — a tight
    // ee1a1a1a halo at range 4 that reads as a 1px border around every window on
    // a flat theme. Blur comes back the same way. Reassert on the reload event.
    Connections {
        target: Hypr

        function onConfigReloaded(): void {
            root.applyCompositor();
        }
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
