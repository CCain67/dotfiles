#!/usr/bin/env bash
# STUB — VS Code colour customisation generator.
#
# To implement:
#   Merge a workbench.colorCustomizations block into
#   ~/.config/Code/User/settings.json, e.g.
#     "editor.background": THEME_BACKGROUND
#     "editor.foreground": THEME_FOREGROUND
#     "activityBar.background", "sideBar.background": THEME_BACKGROUND_DARK
#     "statusBar.background": THEME_SURFACE_HIGH
#   with jq -s '.[0] * .[1]' to deep-merge rather than overwrite.
#
# CATCH: VS Code's settings.json is JSONC — comments and trailing commas are
# legal there and jq rejects both. Either strip comments, merge, and restore
# them, or detect a comment and refuse loudly. Do NOT let jq silently rewrite
# the file and eat the user's comments.
#
# A cleaner alternative worth considering: generate a small extension-free colour
# theme file and reference it, leaving settings.json alone entirely.
set -euo pipefail
echo "  vscode:   would merge workbench.colorCustomizations into ~/.config/Code/User/settings.json"
