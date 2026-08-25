#!/usr/bin/env bash
# Push a theme's colours out to the apps that aren't the shell.
#
# Usage: theme-apply.sh <path-to-theme.json> [--dry-run]
#
# Called by services/Theme.qml on a theme switch, but only when
# Config.theme.applyDownstream is true. It is false by default, and every
# generator under scripts/theme/ is currently a STUB that prints what it would
# write and changes nothing.
#
# Each generator is sourced with the theme's colours already in the environment
# as THEME_<KEY> (uppercased JSON key), e.g. THEME_BACKGROUND, THEME_RED,
# THEME_FOREGROUND_LIGHT. Add a real implementation by replacing the body of the
# corresponding scripts/theme/<app>.sh — nothing else needs to change.
set -euo pipefail

THEME_FILE="${1:-}"
DRY_RUN="${2:-}"

if [ -z "$THEME_FILE" ] || [ ! -r "$THEME_FILE" ]; then
    echo "theme-apply: no readable theme file: '$THEME_FILE'" >&2
    exit 1
fi

command -v jq >/dev/null || { echo "theme-apply: jq is required" >&2; exit 1; }

# Export every scalar key as THEME_<UPPER_SNAKE>. camelCase -> CAMEL_CASE so
# "darkRed" becomes THEME_DARK_RED.
while IFS='=' read -r key value; do
    export "THEME_${key}=${value}"
done < <(jq -r '
    to_entries[]
    | select(.value | type == "string" or type == "boolean")
    | "\(.key | gsub("(?<c>[A-Z])"; "_\(.c)") | ascii_upcase)=\(.value)"
' "$THEME_FILE")

# Second pass for the nested "apps" block (§7.1). The loop above filters to
# scalars, so it drops this object entirely. Keys land as THEME_APP_<UPPER_SNAKE>,
# e.g. apps.konsoleProfile -> THEME_APP_KONSOLE_PROFILE. A JSON null means "no
# curated artifact for this theme" and is exported as the empty string, which is
# what the generators test for.
while IFS='=' read -r key value; do
    export "THEME_APP_${key}=${value}"
done < <(jq -r '
    (.apps // {})
    | to_entries[]
    | select(.value | type == "string" or type == "boolean" or type == "null")
    | "\(.key | gsub("(?<c>[A-Z])"; "_\(.c)") | ascii_upcase)=\(.value // "")"
' "$THEME_FILE")

export THEME_FILE DRY_RUN
export THEME_NAME="${THEME_NAME:-unknown}"

echo "theme-apply: ${THEME_NAME}${DRY_RUN:+ (dry run)}"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for generator in konsole vscode zathura qtgtk firefox; do
    script="$HERE/theme/${generator}.sh"
    [ -x "$script" ] || continue

    if ! "$script"; then
        # One broken generator must not stop the others, and must never take the
        # shell's own theme switch down with it.
        echo "theme-apply: ${generator} generator failed (continuing)" >&2
    fi
done
