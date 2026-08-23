#!/usr/bin/env bash
# STUB — Zathura colour generator.
#
# To implement:
#   Write ~/.config/zathura/zathurarc.theme with:
#     set default-bg      "${THEME_BACKGROUND}"
#     set default-fg      "${THEME_FOREGROUND}"
#     set statusbar-bg    "${THEME_SURFACE_HIGH}"
#     set inputbar-bg     "${THEME_BACKGROUND_DARK}"
#     set highlight-color "${THEME_YELLOW}"
#     set recolor-lightcolor "${THEME_BACKGROUND}"
#     set recolor-darkcolor  "${THEME_FOREGROUND}"
#     set recolor true
#   and add `include zathurarc.theme` to ~/.config/zathura/zathurarc once, so
#   the generated file stays separate from hand-written settings.
#
# CATCH: zathurarc is read at launch only — running instances keep the old
# colours until restarted.
set -euo pipefail
echo "  zathura:  would write ~/.config/zathura/zathurarc.theme (recolor ${THEME_BACKGROUND}/${THEME_FOREGROUND})"
