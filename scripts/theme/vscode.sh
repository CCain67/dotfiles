#!/usr/bin/env bash
# VS Code theming — switch workbench.colorTheme to an installed theme extension.
#
# Deliberately NOT a jq deep-merge of workbench.colorCustomizations
# (IMPROVEMENTS.md §7.3): settings.json is JSONC. Comments and trailing commas are
# legal there and jq rejects both — this file has already had a trailing comma
# once. A targeted single-line rewrite touches nothing else and cannot eat the
# user's comments, so it stays correct whether or not the file is strict JSON.
#
# VS Code watches settings.json, so open windows recolour instantly. No restart.
set -euo pipefail

SETTINGS="$HOME/.config/Code/User/settings.json"
theme="${THEME_APP_VSCODE_THEME:-}"

[ -n "$theme" ] || { echo "  vscode:   no vscodeTheme for this theme, skipping"; exit 0; }

if [ ! -w "$SETTINGS" ]; then
    echo "  vscode:   $SETTINGS not writable, skipping" >&2
    exit 0
fi

if ! grep -q '"workbench.colorTheme"' "$SETTINGS"; then
    echo "  vscode:   no workbench.colorTheme key in settings.json, skipping" >&2
    exit 0
fi

if [ -n "${DRY_RUN:-}" ]; then
    echo "  vscode:   would set workbench.colorTheme = ${theme}"
    exit 0
fi

# Rewrite the value in place. Anchored to the key, so indentation, the trailing
# comma (or its absence) and every other line survive untouched. The theme name
# is passed via the environment rather than interpolated into the sed program, so
# a name containing / or & cannot corrupt the expression.
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
THEME_VALUE="$theme" perl -pe '
    s{("workbench\.colorTheme"\s*:\s*)"(?:[^"\\]|\\.)*"}{$1 . "\"" . ($ENV{THEME_VALUE} =~ s/(["\\])/\\$1/gr) . "\""}e
' "$SETTINGS" > "$tmp"

# Never leave a truncated settings.json behind.
if [ ! -s "$tmp" ]; then
    echo "  vscode:   rewrite produced an empty file, aborting" >&2
    exit 1
fi

cat "$tmp" > "$SETTINGS"
echo "  vscode:   workbench.colorTheme = ${theme}"
