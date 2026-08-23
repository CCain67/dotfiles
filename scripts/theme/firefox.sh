#!/usr/bin/env bash
# STUB — Firefox userChrome generator.
#
# To implement:
#   1. Find the active profile: parse ~/.mozilla/firefox/profiles.ini for the
#      [Install*] section's Default= key. Do NOT hardcode a *.default-release
#      path — it differs per machine and per reinstall.
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
