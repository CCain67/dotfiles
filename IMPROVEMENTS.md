# Theme Swapper

**Status: built and working — all six phases done.** Corrections found during
implementation are marked ⚠ below.

Add a **Themes** page to the dashboard that swaps the shell's entire palette and the
wallpaper at runtime, with the current theme surviving a restart, and with
placeholder hooks for pushing the same colors downstream to Konsole, VS Code,
Zathura and Firefox.

The tab is already stubbed in
[Content.qml](quickshell/modules/dashboard/Content.qml) (`page: "themes"`); the
page itself does not exist yet.

---

## 1. The core problem

`services/Colors.qml` is currently **data**: 20 raw Gruvbox literals plus 53
hand-written `m3*` roles, all `readonly` hex strings. To swap themes, it has to
become a **projection** — a pure mapping from a small set of raw colors onto the
full M3 role set — with the raw colors coming from outside.

That split is what makes this cheap. A theme file then supplies ~22 colors and
gets all 53 M3 roles for free, and **none of the 129 `Colors.palette.m3*` call
sites or ~40 raw `Colors.red`-style call sites change at all.**

Important QML detail: `readonly` does **not** prevent live updates. A
`readonly property color red: Theme.raw.red` is still a binding and re-evaluates
whenever `Theme.raw` changes. The file keeps its current shape; only the
right-hand sides change.

---

## 2. Theme file format

**Decision: JSON files, one per theme, in a new repo dir `themes/`.**

Considered and rejected: themes as QML `QtObject`s under `services/themes/`.
Simpler inside the shell, but unreadable from a shell script — and the downstream
Konsole/VS Code/Zathura/Firefox generators are shell scripts. QML themes would
force a second, duplicate source of truth for the same colors. JSON is readable by
both. QML parses it with `JSON.parse` — the pattern
[Weather.qml](quickshell/services/Weather.qml) already uses, and still the right
call inside the shell, where spawning a `jq` subprocess per read buys nothing.
`jq` (1.8.2) *is* installed, which matters for the downstream generators in §7 —
they get a real JSON tool instead of `sed`.

```
dotfiles/themes/
  gruvbox-material-dark.json
  gruvbox-material-light.json
  <others>.json
```

Schema (`gruvbox-material-dark.json`, values lifted verbatim from today's
`Colors.qml`):

```json
{
  "name": "gruvbox-material-dark",
  "label": "Gruvbox Material Dark",
  "light": false,
  "wallpaper": "wallpapers/flower.jpg",

  "red": "#ea6962",      "darkRed": "#c14a4a",
  "orange": "#e78a4e",   "darkOrange": "#c35e0a",
  "yellow": "#d8a657",   "darkYellow": "#b47109",
  "green": "#a9b665",    "darkGreen": "#6c782e",
  "cyan": "#89b482",     "darkCyan": "#4c7a5d",
  "blue": "#7daea3",     "darkBlue": "#45707a",
  "purple": "#d3869b",   "darkPurple": "#945e80",

  "grey": "#928374", "greyDark": "#7c6f64", "greyLight": "#a89984",

  "background": "#32302f",
  "backgroundDark": "#252423",
  "backgroundLight": "#504945",
  "foreground": "#d4be98",
  "foregroundDark": "#ddc7a1",
  "foregroundLight": "#ebdbb2",

  "surfaceLowest": "#1d1c1a",
  "surfaceHigh":   "#3c3836"
}
```

Notes:

- `wallpaper` is **repo-relative** (resolved against the dotfiles root) so themes
  stay portable; an absolute path is also accepted.
- `surfaceLowest` / `surfaceHigh` exist because the current M3 surface ladder uses
  `#1d1c1a` and `#3c3836`, which are **not** in the raw color set. Gruvbox's ladder
  is not a uniform lightness ramp, so deriving them with `Qt.darker`/`Qt.lighter`
  would visibly drift. Make them optional fields with a derived fallback, so a
  minimal theme file still loads.
- JSON keys normalize to camelCase (`darkRed`), unlike today's mixed
  `dark_red` / `greyDark` in `Colors.qml`. `Colors.qml` keeps its existing
  property names for compatibility; the normalization happens in the mapping.

---

## 3. New service: `services/Theme.qml`

A singleton (add `singleton Theme 1.0 Theme.qml` to `services/qmldir`) owning:

| Member | Purpose |
|---|---|
| `list<var> themes` | every theme parsed from `themes/*.json`, sorted by label |
| `string currentName` | the active theme's `name` |
| `var raw` | the active theme's color object — **the one property everything rebinds on** |
| `bool light` | active theme's `light` flag |
| `string wallpaper` | resolved absolute wallpaper path |
| `apply(name)` | set current, persist, swap wallpaper, fire downstream hooks |

Side effects (persist, wallpaper, downstream) use `Quickshell.execDetached` —
the fire-and-forget pattern `Brightness.qml` and the session menu already use —
rather than `Process.exec`, for consistency with the rest of the repo.

Loading is one `Process`/`StdioCollector` running a small `bash -c` that `cat`s
every `themes/*.json` into a single JSON array (same shape as the Weather fetch),
parsed once with `JSON.parse`. This avoids a `FileView` per theme and keeps
`JsonAdapter` — banned by `CLAUDE.md` as a caelestia dependency — out of it.

### Persistence

The selected theme must survive a shell restart. Write the name to
**`~/.local/state/quickshell/theme`** — deliberately *not* under
`~/.config/quickshell`, which is a symlink into this repo and would dirty
`git status` on every theme click; and not `~/.cache`, which is fair game for
cleaners. On startup, `cat` it; fall back to `Config.theme.defaultTheme`.

⚠ **Gotcha found in testing.** `Config.theme.*` paths contain a literal `$HOME`.
That expands only when the path is interpolated into the **script text**, where
bash parses it. Passed as an **argv element** it stays literal, and the command
silently writes to a directory named `$HOME` in the process's cwd — which is
exactly what happened on the first run (`/home/chase/$HOME/.local/state/...`).
Rule: config paths go in the script body; runtime values (theme name, resolved
wallpaper path) stay in argv, where they can't be spliced into the command.

### Rescanning

The loader was a one-shot at startup, so a JSON file dropped into `themes/` did
not appear until the shell reloaded. `Theme.reload()` re-runs it, and the Themes
page calls it from `onVisibleChanged` — opening the page picks up new theme files.
It is one `bash` + `jq` over a handful of files, cheap enough to run on every
open. Note this covers *new* files; the active theme's colours are read once, so
editing the JSON of the theme you are currently using still needs a reload.

---

## 4. `services/Colors.qml` becomes the mapping

Same public API, same property names, same file — every literal replaced by a
binding onto `Theme.raw`, plus a guard so the shell still renders if theme
loading fails or races startup:

```qml
readonly property var t: Theme.raw ?? Theme.fallback   // baked gruvbox dark
readonly property bool light: Theme.light

readonly property color red: t.red
readonly property color dark_red: t.darkRed
// ... 20 raw colors

readonly property QtObject palette: QtObject {
    readonly property color m3primary: root.t.blue          // primary   = blue
    readonly property color m3secondary: root.t.purple      // secondary = purple
    readonly property color m3tertiary: root.t.yellow       // tertiary  = yellow
    readonly property color m3error: root.t.red             // error     = red
    readonly property color m3success: root.t.green         // success   = green
    // ... surface ladder, on* pairs, containers — all derived the same way
}
```

`Theme.fallback` is the current gruvbox-material-dark palette kept inline as a JS
object, so a missing/corrupt `themes/` dir degrades to exactly today's look rather
than a black shell.

**Verification requirement:** after this refactor and before anything else is
built, the shell must be pixel-identical to today. The gruvbox JSON is a
transcription of the current literals, so any visible difference is a mapping bug.
Capture a `grim` screenshot before the change and diff against one after (crop +
upscale — a 1x grim has previously faked a bug that wasn't there).

### Drive-by fixes this forces

- [Clock.qml](quickshell/modules/bar/components/Clock.qml) lines 67, 84, 92 hardcode
  `#d4be98`. These would **not** follow a theme swap and would look broken on the
  first non-gruvbox theme. Repoint them at `Colors.palette.m3onSurface`.
  `CLAUDE.md` already flags them as drift.
- [MaterialIcon.qml](quickshell/components/MaterialIcon.qml) hardcodes `grade: -25`
  with the comment "Colors.light is hardcoded false". Once `light` is per-theme,
  grade should key off `Colors.light` (`-25` dark / `0` light). Only matters if a
  light theme actually ships — see Open Question 2.
- `ScreenBorder.qml` also has literals, but it is dead code. Leave it, or delete it.

---

## 5. Wallpaper switching

Verified live on this machine: `hyprctl hyprpaper listactive` →
`DP-2: /home/chase/dotfiles/wallpapers/flower.jpg`, so hyprpaper's IPC is up
(hyprpaper v0.8.4).

⚠ **Correction.** The plan said `hyprctl hyprpaper reload`. That request does not
exist in this hyprpaper — it, `preload` and `unload` all return
`invalid hyprpaper request`. The only swap request this build accepts is:

```bash
hyprctl hyprpaper wallpaper "<monitor>,<abs path>"
```

which needs no separate preload step. `listactive` is the only other working
request, so there is no way to unload an old image; images stay resident. With a
handful of themes that is not worth working around. Take `<monitor>` from
`Screens.screen.name`
rather than hardcoding `DP-2` — the monitor name is already available as a
service, and hardcoding it would be a second copy of a fact `hyprland.lua` owns.

That only covers the running session. For the wallpaper to survive a Hyprland
restart, `hypr/hyprpaper.conf`'s `path =` line also has to be rewritten. That file
is **in this repo**, so a theme click will show up in `git status` — **decided:
accept it.** Theme choice is legitimately committed dotfile state. Rewrite only the
`path =` line in place (don't regenerate the file) so `monitor`, `fit_mode` and
`splash` survive untouched, and so the diff stays one line.

---

## 6. The Themes page

`quickshell/modules/dashboard/pages/Themes.qml`, mounted as a third cross-fading
child in `Content.qml`'s `pageArea` alongside `Info` and `Apps`, following the
existing `opacity` + `Behavior on opacity` pattern exactly.

Layout: a scrolling grid of theme cards (reuse `cards/Card.qml`; borrow the
scrolling setup from `pages/AppList.qml`). Each card carries:

- the wallpaper as a thumbnail (`Image` with `sourceSize` set, so 4K wallpapers
  aren't decoded at full size for a 200px tile),
- the theme label,
- a row of ~6 color chips (bg, fg, primary, secondary, tertiary, error) so the
  theme is legible at a glance,
- a selected state — outline in `m3primary`, plus a check glyph,
- `StateLayer` for hover/press, click → `Theme.apply(modelData.name)`.

`Content.qml` also needs its `syncFocus()` extended: the themes page has no text
input, so it takes the `else` branch (`root.forceActiveFocus()`) — which the
current code already does for anything that isn't `"apps"`. Confirm rather than
assume, since `Escape` handling depends on it.

One thing to watch: `StyledRect` and friends have `Behavior on color { CAnim {} }`,
so a swap animates ~130 color properties simultaneously. That will probably look
great, but it is worth an explicit check for jank on the first swap; if it drags,
gate the animation behind a "theme swap in progress" flag.

---

## 7. Downstream app theming — placeholders only

Out of scope to implement, but the seams go in now so adding one later is a
one-file change.

`Theme.applyDownstream(theme)` shells out to a single entry point:

```
dotfiles/scripts/theme-apply.sh <path-to-theme.json> [--dry-run]
```

which dispatches to per-app modules under `scripts/theme/`. Each ships as a stub
that prints what it *would* write and exits 0:

| App | Mechanism (for whoever implements it) | Catch |
|---|---|---|
| **Konsole** | write `~/.local/share/konsole/<Theme>.colorscheme` (INI, `Color0`–`Color7` + intensity variants), point the profile's `ColorScheme=` at it | running instances don't reload; needs a new tab/window, or per-window D-Bus |
| **VS Code** | merge `workbench.colorCustomizations` into `~/.config/Code/User/settings.json` with `jq` | `jq` rejects comments, and VS Code's settings.json permits them — strip-and-restore, or fail loudly rather than eating the user's comments |
| **Zathura** | regenerate a `set recolor-*` / `set default-bg` include, sourced from `~/.config/zathura/zathurarc` | read at launch only; no live reload |
| **Firefox** | `userChrome.css` in the active profile dir | requires `toolkit.legacyUserProfileCustomizations.stylesheets=true`; profile dir must be discovered, not hardcoded |

Gated by `Config.theme.applyDownstream`, defaulting to **false**, so the stubs
can't surprise anyone mid-build. Keep all of this in shell scripts — none of it
belongs in QML.

---

## 8. Config additions

New tree in [config/Config.qml](quickshell/config/Config.qml):

```qml
readonly property QtObject theme: QtObject {
    readonly property string dir: "$HOME/dotfiles/themes"
    readonly property string stateFile: "$HOME/.local/state/quickshell/theme"
    readonly property string default_: "gruvbox-material-dark"
    readonly property string wallpaperRoot: "$HOME/dotfiles"
    readonly property bool applyDownstream: false
    readonly property bool writeHyprpaperConf: true   // rewrites the in-repo conf; see §5
}
```

---

## 9. Phasing

Each phase leaves the shell working.

| # | Phase | Outcome |
|---|---|---|
| 1 | ✅ Extract `gruvbox-material-dark.json`; rewrite `Colors.qml` as a mapping over a hardcoded fallback | **Zero visible change** — verified: all 76 colour properties reproduce the pre-refactor values exactly, and static border strips are pixel-identical |
| 2 | ✅ `services/Theme.qml`: load `themes/*.json`, state file persistence, `apply()` | Verified end to end: state file written, wallpaper set, conf untouched when re-applying the same theme |
| 3 | ✅ `pages/Themes.qml` + wire the existing tab in `Content.qml` | Swatch grid renders, active theme outlined |
| 4 | ✅ Wallpaper swap via `hyprctl hyprpaper wallpaper` + one-line conf rewrite | Verified: swapped to two other wallpapers and back; conf diff was exactly one line each time |
| 5 | ✅ `scripts/theme-apply.sh` + four no-op app stubs | Dry run prints all four; `applyDownstream` is false |
| 6 | ✅ Add **Everforest Dark** | Added; switching to it from the grid repaints the shell and persists |

Phase 1 is the whole risk. Phases 2–6 are additive.

## 10. Verification

- `quickshell -p ~/.config/quickshell` in the foreground for QML errors; content is
  behind a lazy `Loader`, so **open the dashboard before trusting a clean log**.
- Screenshot diff across phase 1 (`grim`, cropped and upscaled).
- `hyprctl hyprpaper listactive` after a swap.
- After a theme click, `git status` shows **exactly one** modified file
  (`hypr/hyprpaper.conf`) with a **one-line** diff — nothing else.
- Restart the shell; confirm the theme persisted.
- Sanity list from `CLAUDE.md`: bar renders, desktop clicks pass through,
  `notify-send test`, `SUPER+D`, `SUPER+SPACE`.

---

## Decisions

1. **A theme click dirties the repo — accepted.** `hypr/hyprpaper.conf`'s `path =`
   line is rewritten on each swap and theme choice becomes committed state. Edit
   the single line in place rather than regenerating the file (see §5).
2. **Light themes: later.** The `light` flag is carried in the schema from day one
   and `Colors.light` is wired to it, but only dark themes ship. `MaterialIcon`'s
   hardcoded `grade: -25` stays as-is and becomes the first thing to fix when a
   light theme is actually wanted — noted in §4 so it isn't rediscovered.
3. **Second theme: Everforest Dark** (medium background), from
   `sainnhe/everforest`.

### Everforest note — the `dark*` fields

Gruvbox Material ships an explicit dim variant of each accent (`dark_red`,
`darkYellow`, …) and the M3 mapping uses them for the `*Container` roles.
**Everforest has no direct equivalent** — it has one accent per hue plus a
separate `dim` statusline set. Two options when writing the JSON:

- hand-pick container colors from Everforest's own `bg_*` tinted backgrounds
  (`bg_red`, `bg_green`, `bg_blue`…), which is what the palette intends them for;
- or derive them as `Qt.darker(accent, ~1.4)`.

I'd hand-pick — the tinted backgrounds exist precisely for "accent as a surface",
which is what an M3 `*Container` role is. Worth pulling the exact hexes from the
upstream repo at implementation time rather than trusting a from-memory palette.
