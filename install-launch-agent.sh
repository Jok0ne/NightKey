#!/bin/bash
# install-launch-agent.sh — registriert NightKey als LaunchAgent (Auto-Start beim Login).
set -euo pipefail

LABEL="io.zerone.nightkey"
PLIST_PATH="${HOME}/Library/LaunchAgents/${LABEL}.plist"
APP_PATH="/Applications/NightKey.app/Contents/MacOS/NightKey"

if [[ ! -x "${APP_PATH}" ]]; then
    echo "FEHLER: ${APP_PATH} nicht gefunden. Erst ./build.sh laufen lassen."
    exit 1
fi

mkdir -p "${HOME}/Library/LaunchAgents"

cat > "${PLIST_PATH}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${APP_PATH}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${HOME}/Library/Logs/NightKey.log</string>
    <key>StandardErrorPath</key>
    <string>${HOME}/Library/Logs/NightKey.log</string>
</dict>
</plist>
EOF

echo "==> Plist geschrieben: ${PLIST_PATH}"

# Vorherige Instanz stoppen falls läuft
launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true

# Neu laden
launchctl bootstrap "gui/$(id -u)" "${PLIST_PATH}"
launchctl enable "gui/$(id -u)/${LABEL}"

echo "==> LaunchAgent aktiv. Status:"
launchctl print "gui/$(id -u)/${LABEL}" 2>&1 | head -10 || true
