#!/usr/bin/env bash
# STUB — Firefox userChrome generator.
#
# To implement:
#   1. Find the active profile. VERIFIED 2026-08-25: on this machine profiles are
#      NOT in ~/.mozilla/firefox (that path does not exist) — they are at
#      ~/.config/mozilla/firefox/profiles.ini (XDG layout). Parse the [Install*]
#      section's Default= key; do NOT hardcode a *.default-release path, it
#      differs per machine and per reinstall. The Flatpak tree
#      ~/.var/app/org.mozilla.firefox exists but is an empty husk — /usr/bin/firefox
#      is the real one. Check both roots rather than assuming either.
#   2. Write <profile>/chrome/userChrome.css with :root vars driven by the
#      THEME_* colours (--toolbar-bgcolor, --lwt-accent-color, tab colours).
#   3. userContent.css likewise if about: pages should follow the theme.
#
# CATCHES:
#   - Requires toolkit.legacyUserProfileCustomizations.stylesheets = true in
#     prefs.js / user.js, else the file is ignored entirely and silently.
#   - Firefox must be restarted; there is no live reload.
#   - Editing prefs.js under a running Firefox is unsafe — it rewrites the file
#     on exit and will clobber the change. Use user.js instead.
set -euo pipefail
echo "  firefox:  would write <profile>/chrome/userChrome.css (accent ${THEME_BLUE})"
