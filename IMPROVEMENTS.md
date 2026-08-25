# Theme Swapper

**Status: phases 1–11 built and working.** Firefox remains a deliberate stub
(§7.4). `Config.theme.applyDownstream` is **true** — a theme click now repaints
Konsole (new tabs), VS Code (live), Zathura (next launch) and Qt/GTK (live). Corrections found during implementation are
marked ⚠ below.

Six themes ship today: gruvbox-material dark/light, everforest dark/light,
paperwhite dark/light. The schema has grown past §2 — `shadow`, `scrim` and
`flat` are live keys, and `Theme.applyCompositor()` pushes border/shadow/blur
into Hyprland via `hyprctl eval`.

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

## 7. Downstream app theming — Phases 7–11

Scoped 2026-08-25 against the live machine. **Guiding decision: prefer a named
scheme, generate when none exists.** Konsole schemes and VS Code themes on this
box are hand-curated per palette, so a theme swap *selects* the existing one
rather than overwriting it with colors derived from the JSON. Where no curated
artifact exists — paperwhite's terminal scheme, every KDE `.colors` file — the
scripts derive it from the theme JSON instead. Both paths are permanent (§7.6),
not one-time bootstrapping.

### 7.1 Schema addition — the `apps` block

Each theme JSON gains one nested object. Nested rather than more top-level keys,
so `Colors.qml`'s raw-color contract stays exactly the ~22 flat hexes it is now:

```json
"apps": {
  "konsoleScheme":  "Gruvbox Material Soft Dark",
  "vscodeTheme":    "Gruvbox Material Dark",
  "kdeColorScheme": "GruvboxMaterialDark",
  "gtkIconTheme":   "Gruvbox-Plus-Dark"
}
```

Every field is optional; a missing field means "leave that app alone". Note
`theme-apply.sh`'s current `THEME_<KEY>` export loop filters to
`type == "string" or "boolean"`, so it silently drops this object — it needs a
second `jq` pass exporting `THEME_APP_KONSOLE_PROFILE` &c.

### 7.2 What each target actually needs

| App | Mechanism | Live reload? |
|---|---|---|
| **Konsole** | `kwriteconfig6` the `[Appearance] ColorScheme` key of the single `chase.profile` | No — new tab/window only |
| **VS Code** | rewrite the `workbench.colorTheme` line in `~/.config/Code/User/settings.json` | **Yes**, instantly |
| **Zathura** | generate `zathurarc.theme`, `include`d from `zathurarc` | No — read at launch |
| **Qt/KDE** | generate `~/.local/share/color-schemes/<X>.colors`, then `plasma-apply-colorscheme <X>` | **Yes** — KColorScheme repaints running apps |
| **GTK** | cascades from the KDE scheme via `kde-gtk-config`; plus flip `gtk-application-prefer-dark-theme` and `gtk-icon-theme-name` in `~/.config/gtk-3.0/settings.ini` | Partially |
| **Firefox** | **deferred** — see 7.4 | No |

### 7.3 Verified facts and live gotchas

- ⚠ **The Firefox stub's path does not exist.** There is no `~/.mozilla/firefox`
  on this machine. Profiles are at **`~/.config/mozilla/firefox/profiles.ini`**
  (XDG layout), with `[Install…] Default=3dz4c2bx.default-release`. The Flatpak
  tree `~/.var/app/org.mozilla.firefox` exists but is an empty 20K husk — the
  native `/usr/bin/firefox` is the real one. Fix the comment even while deferred.
- **The `jq` catch — ✅ resolved 2026-08-25.** `~/.config/Code/User/settings.json`
  had a trailing comma and `jq .` rejected it outright; the comma is gone and it
  parses now. The catch stands as a *rule*, not a current defect: settings.json is
  JSONC and may legally regrow comments or trailing commas at any time. 7.2
  therefore still specifies a targeted single-line rewrite of
  `workbench.colorTheme` rather than a `jq` deep-merge — no strip-and-restore
  dance, no risk of eating comments, and no dependency on the file staying
  strict-JSON by luck.
- **Konsole `Parent=` chain — ✅ resolved 2026-08-25.** Seven profiles declared
  `Parent=chase.profile` against a file that did not exist, silently dropping
  `Command=/bin/zsh`, `TerminalMargin=31` and the GeistMono font. `chase.profile`
  has been restored (it had been renamed to match a colour scheme) and
  `konsolerc` now has `DefaultProfile=chase.profile`.
- **Consequence: `chase.profile` is now doing two jobs.** It is both the shared
  parent (font, `Command`, margin, scrollbar) *and* the gruvbox-dark theme profile
  — there is no longer a separate `Gruvbox Material Dark.profile`. Children
  override `ColorScheme=`, so inheritance still works, and
  `gruvbox-material-dark`'s `apps.konsoleProfile` is simply **`chase`**. Two
  things follow for phase 8: (a) the generator must never rewrite `chase.profile`'s
  `[General]` block, or it clobbers the shared keys every other profile inherits;
  (b) generated profiles (§7.6) declare `Parent=chase.profile` and set nothing but
  `Name` and `ColorScheme`.
- Profile `Parent=` values are inconsistent — some relative (`chase.profile`),
  some absolute (`/home/chase/.local/share/konsole/chase.profile`). Both resolve;
  worth normalising to relative when `konsole/` is adopted into the repo in §7.5,
  since an absolute `/home/chase` path in a tracked dotfile is a portability trap.
- `chase.profile` points at the colorscheme `Gruvbox Material Soft Dark`, which
  lives in **`/usr/share/konsole/`**, not `~/.local/share/konsole/`. The generator
  must not assume a named scheme is local — check both before deciding a theme
  has no scheme and needs one generated.
- **Coverage gaps.** `paperwhite-{dark,light}` has neither a Konsole colorscheme
  nor an installed VS Code theme. Installed VS Code themes are `sainnhe.gruvbox-material`,
  `sainnhe.everforest`, `arcticicestudio.nord…`, `mvllow.rose-pine`. Konsole is
  handled by the generator in §7.6; VS Code falls back to
  `Default Light+`/`Default Dark+`.
- Per-theme contrast keys (`gruvboxMaterial.darkContrast: soft`,
  `everforest.darkContrast: hard`) are global in settings.json today. If they
  should follow the theme they belong in the `apps` block too.
- `qdbus` is **not installed**, so live Konsole reload would need `busctl`/
  `dbus-send`. Not worth it — accept "new tabs only".
- `kde-gtk-config 6.7.4` is installed and is what generated the existing
  `~/.config/gtk-{3,4}.0/colors.css` from `kdeglobals`. GTK recoloring is
  therefore mostly free once the KDE scheme applies — but it only recolors
  **Breeze-GTK** (`gtk-theme-name=Breeze`), so don't change the GTK theme name.
- Present and usable: `plasma-apply-colorscheme`, `kwriteconfig6`, `kreadconfig6`,
  `konsoleprofile`, `jq 1.8.2`.

### 7.4 Firefox — deferred, not dropped

`userChrome.css` requires `toolkit.legacyUserProfileCustomizations.stylesheets=true`
(set via `user.js`, never `prefs.js` under a running Firefox) **and** a full
browser restart, so it can't be verified in the same loop as everything else.
`firefox.sh` stays a stub; only its path comment gets the 7.3 correction.

### 7.5 Repo adoption

Decided: `~/.config/zathura` and `~/.local/share/konsole` move **into this repo**
and become symlinks, matching `hypr/` and `quickshell/`, so generated theme state
and the `chase.profile` fix are version-controlled.

```
dotfiles/konsole/   → ~/.local/share/konsole/
dotfiles/zathura/   → ~/.config/zathura/
```

`kdeglobals`, `gtk-3.0/settings.ini` and VS Code's `settings.json` are **not**
adopted — they are edited in place. They carry far more non-theme state than
theme state, and `kdeglobals` in particular is rewritten by Plasma itself.

Consequence, same as `hyprpaper.conf` in §5: a theme click now dirties
`konsole/` and `zathura/` as well. Accepted for the same reason.

### 7.6 Konsole — one profile, N schemes

**Revised after QA.** The first build wrote a `.profile` per theme and repointed
`konsolerc`'s `DefaultProfile` at it. That is not necessary: `DefaultProfile` can
only name a `.profile` (Konsole cannot select a `.colorscheme` directly), but
nothing says there has to be more than one. `chase.profile` is now the **only**
profile, and a theme switch rewrites its `[Appearance] ColorScheme` key — so all
per-theme state lives in `.colorscheme` files, and the ten `.profile` files Gogh
and the first build left behind were deleted.

Consequences:

- The schema field is `apps.konsoleScheme` (a **colour scheme** name), not
  `konsoleProfile`.
- Only the `ColorScheme` key is touched. `chase.profile`'s `[General]` block
  carries the font, `Command=/bin/zsh`, `TerminalMargin` and scrollbar position —
  verified byte-identical after cycling all six themes.
- A named scheme may live in `~/.local/share/konsole` **or** `/usr/share/konsole`
  (gruvbox dark's `Gruvbox Material Soft Dark` is the latter). Check both.
- Cost, accepted: Konsole's *Settings → Switch Profile* menu now lists one entry,
  so a single terminal window can no longer be themed independently of the shell.
- The six unreferenced `.colorscheme` files (Nord, Nord Light, Nordic, Rosé Pine,
  Everforest Dark Medium/Soft) are kept as a **library** — a future Nord or Rosé
  Pine theme just names one in `apps.konsoleScheme`.

### 7.6.1 The generated fallback path

`apps.konsoleProfile` is optional. When a theme omits it — paperwhite today —
`konsole.sh` **derives** the scheme from the theme's raw colors rather than
skipping the app:

```
~/.local/share/konsole/<label>.colorscheme    # generated, [Background]/[Foreground]/[Color0..7] + Intense
```

Rules the generator has to hold to:

- Konsole wants **decimal `R,G,B`**, not hex, so every `THEME_*` value needs
  converting. `Color0`=background, 1=red, 2=green, 3=yellow, 4=blue, 5=purple,
  6=cyan, 7=foreground; the `ColorNIntense` row takes the bright variant and
  `ColorNFaint` the `dark*` variant.
- **Only ever write `chase.profile`'s `ColorScheme` key**, via `kwriteconfig6`.
  Rewriting the file would lose the `[General]` block (§7.3).
- Regenerate on **every** apply, not once. This is the point of keeping it a
  script: editing `paperwhite-dark.json` and re-selecting the theme must reproduce
  the terminal colors with no manual step. Overwrite unconditionally — a generated
  file is derived state, and the theme JSON is its only source of truth.
- Write a **generated-file header comment** into the `.colorscheme` naming the
  theme JSON it came from, so a future session doesn't mistake it for a
  hand-curated one and start editing it by hand.
- A hand-curated scheme always wins: if `apps.konsoleProfile` is set, the
  generator does not run for that theme and writes nothing.

The same "named, else generated" shape is what phase 11 uses for KDE `.colors`,
except there the generated path is the only path — no curated `.colors` exists
per theme beyond the one `GruvboxMaterial` file.

### 7.8 Defects the build surfaced

Three real problems, none of which were visible from reading the config:

1. **Flat themes break a derived terminal palette.** `paperwhite-*` is monochrome:
   every accent is `#ebdbb2`, and `foregroundLight` is `#32302f` — the *background*
   colour, because in the shell that role means "text ON an accent". Feeding it
   straight into Konsole's `ForegroundIntense` and `Color7Intense` produced
   **invisible bright-white text**. Fixed with a `pick()` contrast guard in
   `konsole.sh`: a derived slot keeps its candidate only if the candidate's
   relative luminance differs from the background by ≥ 0.12, else it falls back.
   Verified against gruvbox dark, gruvbox light and paperwhite. **The general
   lesson: the shell's colour roles are not a terminal palette**, and any future
   generator that derives one must not assume a role name means what it sounds
   like.
2. **`set font "GeistMono Nerd Font Bold" 10` in `zathurarc` was never applied.**
   zathura wants the size *inside* the quotes; as written it parsed as three
   arguments and the whole line was discarded with
   `warning: Too many arguments for :set`. Pre-existing, unrelated to theming,
   found only because the generated include was checked for parse errors. Fixed
   to `"GeistMono Nerd Font Bold 10"`.
3. The Konsole `Parent=chase.profile` chain and the VS Code trailing comma, both
   fixed by hand before the build — recorded in §7.3.
4. **`recolor false` on light themes left PDFs bare white.** The first build
   disabled zathura's `recolor` for any theme with `light: true`, reasoning that
   a light theme should leave the page as authored. Wrong call: with `recolor`
   off, `recolor-lightcolor` is ignored entirely and zathura renders the PDF's
   own `#ffffff` paper, so paperwhite-light showed white pages rather than the
   theme's `#f2e5bc`. `recolor` is now **always on**; a light theme maps white →
   its off-white background and black → its dark foreground.
5. **A profile per theme was unnecessary** — see the §7.6 revision.

### 7.7 Enabling it

`Config.theme.applyDownstream` stays **false** until every generator in 7.2 is
real and verified, then flips to `true` in its own commit. `theme-apply.sh`'s
existing per-generator `|| continue` guard already ensures one broken script
can't take the shell's own theme switch down with it — keep that.

## 8. Config additions

Live today in [config/Config.qml](quickshell/config/Config.qml):

```qml
readonly property QtObject theme: QtObject {
    readonly property string dir: "$HOME/dotfiles/themes"
    readonly property string wallpaperRoot: "$HOME/dotfiles"
    readonly property string stateFile: "$HOME/.local/state/quickshell/theme"
    readonly property string hyprpaperConf: "$HOME/dotfiles/hypr/hyprpaper.conf"
    readonly property string applyScript: "$HOME/dotfiles/scripts/theme-apply.sh"
    readonly property string defaultTheme: "gruvbox-material-dark"
    readonly property bool applyDownstream: false
}
```

Phase 7 needs **no new QML config keys** — the `apps` block lives in the theme
JSON (§7.1) and every path the generators touch is a fixed `~/.config` or
`~/.local/share` location the scripts can hardcode. Keep honouring the §3 ⚠ rule:
`$HOME`-bearing config paths go in the *script body*, runtime values stay in argv.

If per-app opt-out is wanted later, it belongs as booleans beside
`applyDownstream` (`applyKonsole`, `applyQt`, …) rather than as more theme-JSON
fields — it is a machine preference, not a property of the palette.

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
| 7 | ✅ `apps` block in every theme JSON + `theme-apply.sh` exports it as `THEME_APP_*`; `konsole/` and `zathura/` adopted as symlinks; absolute `Parent=` paths normalised to relative | Verified: all 6 themes valid JSON, `THEME_APP_*` reaches the generators (incl. `null` → empty string for paperwhite), `konsole --list-profiles` returns all 9 through the symlink |
| 8 | ✅ **Konsole** — `kwriteconfig6` on `DefaultProfile` for named profiles, plus a permanent `.colorscheme`/`.profile` generator for themes without one (§7.6) | Both paths verified. The generated path exposed a real defect — see §7.8 |
| 9 | ✅ **VS Code** — single-line `perl` rewrite of `workbench.colorTheme`; paperwhite falls back to `Default Light+`/`Default Dark+` | Round-tripped 3 themes; only that line differs, and a JSONC file with comments + trailing comma survives intact |
| 10 | ✅ **Zathura** — generates `zathurarc.theme`, `include`d once from a now colour-free `zathurarc`; `recolor` follows the `light` flag | Idempotent (include added once over repeated runs); parses clean. Fixed a pre-existing `set font` syntax bug, see §7.8 |
| 11 | ✅ **Qt/KDE + GTK** — `scripts/theme/qtgtk.sh` generates `<name>.colors`, runs `plasma-apply-colorscheme`, flips GTK `prefer-dark` + icon theme | **GTK cascade confirmed empirically**: `kde-gtk-config` regenerated both `gtk-{3,4}.0/colors.css` in the same minute. `applyDownstream` is now **true** |

Phase 1 was the whole risk. Phases 2–6 were additive and are done. Phases 7–11
write files outside this repo — each one is reversible by hand, and
`applyDownstream` stays false until 11 lands.

**Deferred, not scheduled:** Firefox `userChrome.css` (§7.4).

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
2. ~~**Light themes: later.**~~ **Superseded — light themes shipped.** Three of
   them (`gruvbox-material-light`, `everforest-light`, `paperwhite-light`), and
   [MaterialIcon.qml](quickshell/components/MaterialIcon.qml) now reads
   `grade: Colors.light ? 0 : -25` as §4 anticipated. Consequence for phase 7:
   every downstream target needs a light *and* dark answer, and GTK's
   `gtk-application-prefer-dark-theme` (hardcoded `true` today) has to follow the
   theme's `light` flag.
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

4. **Prefer a named scheme; generate when none exists** (phase 7). Konsole
   schemes and VS Code themes are hand-curated per palette, so a swap selects one
   rather than deriving colors. Where nothing curated exists — paperwhite's
   terminal scheme, the KDE `.colors` files — `konsole.sh` derives it from the
   theme JSON. **The generator is permanent and runs on every apply** (§7.6), so
   editing a theme's JSON re-derives its terminal colors with no manual step; it
   is not one-time bootstrapping to be deleted afterwards.
5. **Qt/KDE and GTK are in scope**, though the original §7 omitted them. They are
   the only targets that repaint running applications.
6. **`konsole/` and `zathura/` move into this repo**; `kdeglobals`,
   `gtk-3.0/settings.ini` and VS Code `settings.json` are edited in place (§7.5).
