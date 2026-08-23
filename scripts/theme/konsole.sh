#!/usr/bin/env bash
# STUB — Konsole colour scheme generator.
#
# To implement:
#   1. Write ~/.local/share/konsole/${THEME_NAME}.colorscheme — an INI file with
#      [Background], [Foreground] and [Color0]..[Color7] sections, each plus a
#      matching [ColorNIntense] (and optionally [ColorNFaint]). Values are
#      decimal "R,G,B", NOT hex, so the THEME_* hexes need converting.
#      Mapping: Color0=background/black, 1=red, 2=green, 3=yellow, 4=blue,
#      5=purple, 6=cyan, 7=foreground/white; the Intense row is the same hue,
#      lighter. Gruvbox-style palettes give the dark* variants as the faint row.
#   2. Point the profile at it: set ColorScheme=${THEME_NAME} in the [Appearance]
#      section of ~/.local/share/konsole/<Profile>.profile.
#
# CATCH: already-running Konsole windows do not reload the scheme. A new tab or
# window picks it up; changing live windows means walking Konsole's D-Bus
# interface (org.kde.konsole /Sessions/N setProfile), which is per-session.
set -euo pipefail
echo "  konsole:  would write ~/.local/share/konsole/${THEME_NAME}.colorscheme (bg ${THEME_BACKGROUND}, fg ${THEME_FOREGROUND})"
