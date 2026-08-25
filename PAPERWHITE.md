# Paperwhite

**Status: built and working — all seven phases done.** Corrections found during
implementation are marked ⚠ below.

A two-colour, shadowless theme pair — `paperwhite-light` and `paperwhite-dark` —
plus the machinery a *flat* theme needs: a `flat` flag in the theme schema that
kills every shadow in the shell, turns off Hyprland's window shadow and blur, and
lets the outline carry the separation that elevation used to.

Deliberately ahead of [IMPROVEMENTS.md §7](IMPROVEMENTS.md) (downstream app
theming). §7 is what makes Konsole and Zathura actually adopt the palette; this
document is what makes the palette worth adopting.

---

## 1. The two colours

```
background  #EBDBB2      foreground  #252423
```

Everything else in the theme is a blend of those two. No hue anywhere.

The theme JSON schema wants ~22 raw colours, so the work is deciding where on
the ink ramp each one sits. Blends below are `t` along `#EBDBB2 → #252423`:

| t | light | dark (mirrored) | role |
|---|---|---|---|
| 0.00 | `#ebdbb2` | `#252423` | paper |
| 0.03 | `#e5d6ae` | `#2b2927` | one step off paper |
| 0.05 | `#e1d2ab` | `#2f2d2a` | card fill |
| 0.08 | `#dbcca7` | `#35332e` | raised fill |
| 0.28 | `#b4a88a` | `#5c574b` | hairline outline |
| 0.50 | `#88806a` | `#88806a` | outline |
| 0.62 | `#706a59` | `#a0957c` | secondary text |
| 0.84 | `#45413a` | `#cbbe9b` | (unused — accents are full ink) |
| 1.00 | `#252423` | `#ebdbb2` | ink |

The dark variant is the same ramp with the endpoints swapped — same file, two
sets of values, no separate mapping logic.

### Naming inversion (already a convention here, worth restating)

`gruvbox-material-light.json` already does this and it reads as a bug if you
don't know: in a light theme, `backgroundLight` holds a value **darker** than
`background`, and `foregroundDark` holds the **darkest** ink. The names describe
the role in the M3 ladder, not the luminance. Paperwhite follows the same
convention. `foregroundDark` is raw-only — no `m3*` role consumes it
([Colors.qml:48](quickshell/services/Colors.qml#L48)) — so its value only has to
be plausible.

### Near-monochrome: accents collapse, and that is accepted

Seven accents onto one ink means four call sites that use raw `Colors.<accent>`
to carry information lose their signal:

| Site | What it encoded |
|---|---|
| [SysUsage.qml:43-59](quickshell/services/SysUsage.qml#L43) `tempColor()` | green → yellow → orange → red temperature warning |
| [Power.qml:91](quickshell/modules/dashboard/cards/Power.qml#L91) | `armed` (click-to-confirm) state in red |
| [Wifi.qml:19](quickshell/modules/dashboard/cards/Wifi.qml#L19) | connected vs. not |
| [StatusIcons.qml:26](quickshell/modules/bar/components/StatusIcons.qml#L26), the bar meters | at-a-glance status |

**Decided: accept the loss.** Load and temperature get read deliberately, when
something heavy is already known to be coming — and the fans announce it before
the colour does. The colour was decoration. Every accent is therefore full ink,
and `tempColor()` keeps working as dead-but-harmless code returning one value.

One consequence to be aware of rather than surprised by: `Power.qml`'s armed
state loses its red accent, so the only remaining confirm signal is its
`Qt.alpha(..., 0.18)` background wash. That is still a visible state change on
paper — verify it reads clearly at phase 5, and if it does not, that single site
is the one place worth spending a second colour.

The `dark*` variants stay near-full ink for a different reason: they are the
`*Container` roles, painted **under** `foregroundLight`, so in the light theme
they carry paper-coloured text on top. A selected item is an ink block with
paper lettering — the correct e-ink idiom.

### `paperwhite-light.json`

```json
{
  "name": "paperwhite-light",
  "label": "Paperwhite Light",
  "light": true,
  "flat": true,
  "wallpaper": "wallpapers/paperwhite-light.png",

  "red": "#252423",     "darkRed": "#252423",
  "orange": "#252423",  "darkOrange": "#252423",
  "yellow": "#252423",  "darkYellow": "#252423",
  "green": "#252423",   "darkGreen": "#252423",
  "cyan": "#252423",    "darkCyan": "#252423",
  "blue": "#252423",    "darkBlue": "#252423",
  "purple": "#252423",  "darkPurple": "#252423",

  "grey": "#88806a", "greyDark": "#b4a88a", "greyLight": "#706a59",

  "background": "#EBDBB2",
  "backgroundDark": "#e5d6ae",
  "backgroundLight": "#dbcca7",
  "foreground": "#252423",
  "foregroundDark": "#35332e",
  "foregroundLight": "#EBDBB2",

  "surfaceLowest": "#EBDBB2",
  "surfaceHigh": "#e1d2ab",

  "shadow": "#252423",
  "scrim": "#252423"
}
```

`paperwhite-dark.json` is the same file with the ramp mirrored (`background`
`#252423`, `foreground` `#EBDBB2`, `light: false`, and each blend taken from the
dark column of the table).

Note the surface ladder spans `#EBDBB2` → `#dbcca7` — about 5% of the range,
where gruvbox spans roughly 25%. That collapse is deliberate and it is *why*
step 3 below (outlines) is not optional.

---

## 2. Shadows in the shell — eight sites

Every one is the same four-line `MultiEffect`, and they already form a clean
three-level ladder:

| File | blurMax | offset | alpha | level |
|---|---|---|---|---|
| [Tile.qml:29](quickshell/modules/dashboard/cards/Tile.qml#L29) | 8 | 1 | 0.7 | low |
| [Power.qml:101](quickshell/modules/dashboard/cards/Power.qml#L101) | 8 | 1 | 0.7 | low |
| [Links.qml:53](quickshell/modules/dashboard/cards/Links.qml#L53) | 10 | 2 | 0.8 | low |
| [Media.qml:30](quickshell/modules/dashboard/cards/Media.qml#L30) | 10 | 2 | 0.8 | low |
| [Card.qml:24](quickshell/modules/dashboard/cards/Card.qml#L24) | 14 | 2 | 0.8 | medium |
| [Notification.qml:37](quickshell/modules/notifications/Notification.qml#L37) | 14 | 2 | 0.8 | medium |
| [Drawers.qml:55](quickshell/modules/drawers/Drawers.qml#L55) | 14 | 0 | 0.8 | medium |
| [Content.qml:66](quickshell/modules/dashboard/Content.qml#L66) | 24 | 4 | 0.8 | high |

`ScreenBorder.qml` had a ninth, but it was dead code superseded by
`drawers/Border.qml` — ✅ deleted.

### New: `Appearance.shadows` + `components/Elevation.qml`

```qml
readonly property QtObject shadows: QtObject {
    readonly property bool enabled: !Theme.flat
    readonly property int low: 8
    readonly property int medium: 14
    readonly property int high: 24
    readonly property real alpha: 0.8
}
```

`Elevation.qml` is a `MultiEffect` subclass taking `level: "low"|"medium"|"high"`
and reading the tokens. Each of the eight sites collapses to:

```qml
layer.enabled: Appearance.shadows.enabled
layer.effect: Elevation { level: "medium" }
```

Binding `layer.enabled` too, not just `shadowEnabled`, matters: an enabled layer
with shadows off still allocates an offscreen FBO per card for nothing.

⚠ **Risk to check first.** `layer.effect` expects a `Component`. Inline
`MultiEffect { ... }` is implicitly wrapped; a file-based type should behave the
same way, but this is alpha software and it is the one thing in this plan that
could simply not work. If it balks, fall back to binding `shadowEnabled` and
`blurMax` inline at all eight sites — same behaviour, eight copies of the binding
instead of one. Verify this **before** converting all eight.

---

## 3. Flat needs the outline to take over

Shadows gone *and* a 5%-range surface ladder means cards dissolve into the page.
The separation has to move into the border. [Card.qml:21-22](quickshell/modules/dashboard/cards/Card.qml#L21)
is `border.width: 1` / `m3outlineVariant` today; flat wants a stronger,
higher-contrast hairline.

**Decided: 1px at `m3outline`.** New tokens rather than per-card branching:

```qml
readonly property QtObject outline: QtObject {
    readonly property int width: 1
    readonly property color color: Theme.flat ? Colors.palette.m3outline
                                              : Colors.palette.m3outlineVariant
}
```

`m3outlineVariant` is `greyDark` (t=0.28, `#b4a88a`) and `m3outline` is `grey`
(t=0.50, `#88806a`) — so flat gets roughly double the contrast at the same 1px
width. Applies to `Card.qml`, `Tile.qml`, `Power.qml` and the `Themes.qml`
tiles.

---

## 4. The compositor — the part that actually matters

Verified live:

```
hyprctl getoption decoration:shadow:enabled  →  bool: true,  set: false
hyprctl getoption decoration:blur:enabled    →  bool: true,  set: true
hyprctl getoption general:border_size        →  int: 2,      set: true
```

Hyprland is drawing a shadow under **every** window from its own default —
[hyprland.lua:104](hypr/hyprland.lua#L104)'s `decoration` block never mentions
shadows. Blur is on at size 6 / 2 passes. And `col.active_border` /
`inactive_border` are hardcoded gruvbox literals (`504945`, `252524`) that do not
follow the theme at all.

Those three are why Konsole and Zathura read as floating *on top of* the desktop.
(Minor: sourcing the borders from the palette also corrects `inactive_border`,
whose literal `252524` is one off from gruvbox's actual `#252423` — a typo the
theme mapping now fixes on its own.)
Flattening only Quickshell would leave the actual problem untouched.

### New: `Theme.applyCompositor()`

A sibling to `applyWallpaper()` in [Theme.qml](quickshell/services/Theme.qml),
same `Quickshell.execDetached` fire-and-forget shape.

⚠ **Correction — `hyprctl keyword` does not work on this system.** The plan said
to use it. Every form of it returns:

```
keyword can't work with non-legacy parsers. Use eval.
```

because `hyprland.lua` puts Hyprland on the Lua parser. The working form is
`hyprctl eval` with the same `hl.config()` call the config file uses, and all
four settings go in one call:

```lua
hl.config({
    general = {
        border_size = 1,
        col = { active_border = "rgba(88806aff)", inactive_border = "rgba(e5d6aeff)" }
    },
    decoration = {
        blur   = { enabled = false },
        shadow = { enabled = false }
    }
})
```

Verified live 2026-08-24: `hyprctl getoption` reports `set: true` for all four
afterwards. This is the same class of gotcha as `hyprctl dispatch` needing
`hl.dsp.global("quickshell:dashboard")` rather than `dispatch global ...`.

Two decisions baked in here:

- **Bind it to `Theme.raw` changing, not just to `apply()`.** Quickshell is
  autostarted by `hyprland.lua`, so a Hyprland restart resets these to the
  file's literals; reasserting on every raw change makes the shell
  self-healing without touching `hyprland.lua` on each swap.
- **Not gated behind `Config.theme.applyDownstream`.** That flag guards
  §7's *stubs*, which write other applications' config files. This is the
  compositor hosting the shell, it is runtime-only, and it writes nothing. If it
  were gated, paperwhite would not work out of the box with `applyDownstream`
  false — which is its permanent default until §7 is real.

⚠ **Gotcha found in testing — do not read `root.flat` inside `applyCompositor()`.**
It runs from `onRawChanged`, and `flat` is itself a binding on `raw`, which has
not necessarily re-evaluated when the change handler fires. `root.flat` therefore
still holds the *previous* theme's value: the first paperwhite switch repainted
the whole shell correctly but left Hyprland's shadow and blur on and the border
at 2px. Read `t.flat ?? false` off the theme object being applied instead. Same
rule as IMPROVEMENTS.md's `$HOME`-in-argv trap: take the value from the thing you
were handed, not from a binding that derives from it.

⚠ **A Hyprland config reload undoes everything set through `eval`.** `hyprctl
reload` (including saving `hyprland.lua`) resets the runtime state to the config
file. `hyprland.lua`'s `decoration` block does not mention `shadow`, so the window
shadow returns at Hyprland's **default of enabled** — an `ee1a1a1a` halo at
`range 4` that reads as a 1px border hugging every window, which is precisely
what a flat theme is trying to remove. Blur returns the same way. `Theme` now
reasserts on `Hypr.configReloaded`, which already existed as a signal.

⚠ **`border_size` is not theme state.** applyCompositor originally forced it to 1
under flat, which silently overrode a hand-edited `border_size = 0` on the next
theme switch or shell restart. It is a static preference; `hyprland.lua` owns it
and the shell no longer writes it.

`hyprland.lua` keeps its current literals as the pre-shell default. Not worth
rewriting the file on a theme click, and it keeps one source of truth for the
boot appearance.

`general:border_size` drops to **1** under flat, restored to 2 otherwise — same
batch, same flag. Blur off is per the flat flag. Note this is a visible regression for the gruvbox
themes if the flag ever leaks — `flat` must default false when the key is absent.

---

## 5. Wallpaper

hyprpaper has no solid-colour mode (and per
[IMPROVEMENTS.md §5](IMPROVEMENTS.md), this build only accepts the `wallpaper`
request — no `preload`/`unload`/`reload`). So each variant needs a flat PNG
committed to `wallpapers/`:

```bash
magick -size 64x64 xc:'#EBDBB2' wallpapers/paperwhite-light.png
magick -size 64x64 xc:'#252423' wallpapers/paperwhite-dark.png
```

✅ **Done** — both are in `wallpapers/`, 300 bytes each. Confirm `fit_mode` in
`hyprpaper.conf` does not letterbox a 64px tile (`stretch`/`fill` are both fine
for a solid).

---

## 6. Schema and config additions

`flat` joins the theme JSON as an optional boolean, absent everywhere else:

```qml
// services/Theme.qml
readonly property bool flat: raw.flat ?? false
```

`Theme.fallback` gains `flat: false` alongside its other baked keys. No
`Config.qml` additions — `flat` is theme state, per the decision below, and the
shadow tokens live in `Appearance.qml` where the other visual tokens are.

---

## 7. Drive-by this forces

[MaterialIcon.qml:6-7](quickshell/components/MaterialIcon.qml#L6) still reads:

```qml
// Colors.light is hardcoded false → grade is always -25
readonly property int grade: -25
```

That comment is stale — light themes shipped in `d2e9b8f` and `Colors.light` is
live. On a `#EBDBB2` background, grade `-25` visibly thins every glyph, which is
exactly the case the axis exists to correct. Should become
`Colors.light ? 0 : -25`. Flagged in
[IMPROVEMENTS.md §4](IMPROVEMENTS.md) as the first thing to fix when a light
theme is actually wanted; paperwhite is that moment.

(`CLAUDE.md` also still describes `Colors.light` as hardcoded and the theme as
dark-only, and claims no network service is ported while `cards/Wifi.qml` and a
`Network` service exist. Worth a pass once this lands.)

---

## 8. Phasing

Each phase leaves the shell working.

| # | Phase | Outcome |
|---|---|---|
| 1 | ✅ Prove `layer.effect: Elevation {}` works on one site | Works — a file-based `MultiEffect` subclass is accepted where an inline one was |
| 2 | ✅ `Appearance.shadows` + `Elevation.qml`, all 8 sites converted | Shell renders unchanged; `QtQuick.Effects` now imported only by `Elevation` and `Border` |
| 3 | ✅ `Appearance.outline` tokens wired into Card/Tile/Power/Themes | `config → services` import works; no singleton cycle |
| 4 | ✅ `applyCompositor()` via `hyprctl eval` | Verified: shadow/blur/borders report `set: true`, survive `hyprctl reload`, and flip back on a non-flat theme |
| 5 | ✅ `paperwhite-light.json` | Verified on screen — flat, monochrome, outlines carrying the separation |
| 6 | ✅ `paperwhite-dark.json` | Written; mirror of the light ramp |
| 7 | ✅ `MaterialIcon` grade follows `Colors.light` | Glyphs at full weight on paper |

Phase 2's shadow values were **normalised, not preserved**: `Links` and `Media`
were hand-tuned to `blurMax: 10 / offset 2 / alpha 0.8` and now sit on the `low`
tier (`8 / 1 / 0.7`) alongside `Tile` and `Power`, which are the same visual tier.
`Drawers` keeps `shadowVerticalOffset: 0` as a local override — the screen border
is symmetric and a downward offset sits wrong on it.

---

## 9. Verification

What was checked, and how:

- `quickshell log` clean through every phase, with the dashboard **opened** each
  time — its content is behind a lazy `Loader`, so errors only surface then.
- Dashboard screenshot on paperwhite: flat cards, monochrome glyphs, outline
  separation holding without shadows.
- `hyprctl getoption` on all four compositor settings, on paperwhite and back.
- `notify-send` popup renders through the converted `Notification.qml`.

⚠ **Not yet verified — needs a click.** `Theme.apply()`'s wallpaper half
(hyprpaper IPC + the one-line `hyprpaper.conf` rewrite) has not been exercised,
because there is no `ydotool`/`wtype` on this system and Hyprland's Lua dispatch
table exposes no `movecursor`, so the theme tile cannot be clicked from a shell.
The theme was switched by writing the state file and restarting instead, which
does not call `applyWallpaper()`. **Click a paperwhite tile on the Themes page
and confirm `git status` shows exactly one modified file (`hypr/hyprpaper.conf`)
with a one-line diff.**

⚠ **Editing `themes/` does not hot-reload.** Quickshell reuses singleton
instances whose own file did not change, so dropping a new JSON into `themes/`
leaves `Theme`'s loader untouched — the first paperwhite switch appeared to
silently fail for this reason. Either open the Themes page (`onVisibleChanged`
calls `Theme.reload()`) or restart the shell.

---

## Decisions

1. **Two colours only** — `#EBDBB2` / `#252423`. Every other value is a blend.
2. **Strict monochrome.** All seven accents collapse to full ink. The four
   information-bearing call sites lose their signal and that is accepted (§1) —
   the fans are the real temperature warning.
3. **`flat` is a theme property, not a global toggle.** Paperwhite is flat;
   gruvbox and everforest keep their shadows. Absent key → `false`.
4. **Blur dies with the shadows**, driven by the same flag. `border_size` is
   *not* touched by the shell — `hyprland.lua` owns it (currently `0`).
5. **`applyCompositor()` is not gated by `applyDownstream`** — it is the host
   compositor, not a downstream app, and it writes no files (§4).
6. **Flat outline is 1px at `m3outline`** (§3).

All open questions are resolved. Phase 1's go/no-go came back **go**.
