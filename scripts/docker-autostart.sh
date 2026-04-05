#!/bin/bash
#
# docker-autostart.sh — Configure Docker Desktop to launch at login
# and containers to start automatically via a LaunchAgent.
#
# Usage:
#   ./docker-autostart.sh apply    # Enable auto-start
#   ./docker-autostart.sh status   # Check current state
#   ./docker-autostart.sh undo     # Disable auto-start
#

set -euo pipefail

PLIST_LABEL="com.ahoyfatboy.docker-compose"
PLIST_PATH="$HOME/Library/LaunchAgents/${PLIST_LABEL}.plist"
COMPOSE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

case "${1:-}" in
  apply)
    # 1. Docker Desktop: open at login
    osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Docker.app", hidden:true}' 2>/dev/null && \
      echo "Docker Desktop added to login items." || \
      echo "Docker Desktop may already be in login items."

    # 2. LaunchAgent: run docker compose up after Docker is ready
    cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${PLIST_LABEL}</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>-c</string>
    <string>
      # Wait for Docker to be ready (up to 120s)
      for i in \$(seq 1 60); do
        /usr/local/bin/docker info &amp;&gt; /dev/null &amp;&amp; break
        sleep 2
      done
      cd "${COMPOSE_DIR}" &amp;&amp; /usr/local/bin/docker compose up -d
    </string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/${PLIST_LABEL}.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/${PLIST_LABEL}.err</string>
</dict>
</plist>
EOF
    launchctl load "$PLIST_PATH"
    echo "LaunchAgent installed: $PLIST_PATH"
    echo "Containers will auto-start from: $COMPOSE_DIR"
    ;;

  status)
    echo "=== Docker Desktop login item ==="
    osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null || echo "(could not query)"
    echo ""
    echo "=== LaunchAgent ==="
    if [[ -f "$PLIST_PATH" ]]; then
      echo "Installed: $PLIST_PATH"
      launchctl list | grep "$PLIST_LABEL" 2>/dev/null || echo "(not currently loaded)"
    else
      echo "Not installed."
    fi
    echo ""
    echo "=== Logs ==="
    tail -5 "/tmp/${PLIST_LABEL}.log" 2>/dev/null || echo "(no logs yet)"
    ;;

  undo)
    # 1. Remove LaunchAgent
    if [[ -f "$PLIST_PATH" ]]; then
      launchctl unload "$PLIST_PATH" 2>/dev/null || true
      rm "$PLIST_PATH"
      echo "LaunchAgent removed."
    else
      echo "LaunchAgent not found."
    fi

    # 2. Remove Docker Desktop from login items
    osascript -e 'tell application "System Events" to delete login item "Docker"' 2>/dev/null && \
      echo "Docker Desktop removed from login items." || \
      echo "Docker Desktop was not in login items."
    ;;

  *)
    echo "Usage: $0 {apply|status|undo}"
    exit 1
    ;;
esac
