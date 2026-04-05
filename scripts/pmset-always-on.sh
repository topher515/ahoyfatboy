#!/bin/bash
#
# pmset-always-on.sh — Configure a Mac to stay "always on"
#
# Usage:
#   sudo ./pmset-always-on.sh apply    # Apply always-on settings
#   ./pmset-always-on.sh status        # Show current pmset settings
#   sudo ./pmset-always-on.sh undo     # Restore macOS defaults
#

set -euo pipefail

case "${1:-}" in
  apply)
    if [[ $EUID -ne 0 ]]; then echo "Error: run with sudo"; exit 1; fi
    echo "Applying always-on settings..."
    pmset -a sleep 0
    pmset -a displaysleep 0
    pmset -a disksleep 0
    pmset -a autorestart 1
    pmset -a womp 1
    pmset repeat poweron MTWRFSU 00:00:00
    echo "Done. Verify with: $0 status"
    ;;

  status)
    echo "=== Current pmset settings ==="
    pmset -g
    echo ""
    echo "=== Scheduled events ==="
    pmset -g sched 2>/dev/null || echo "(none)"
    ;;

  undo)
    if [[ $EUID -ne 0 ]]; then echo "Error: run with sudo"; exit 1; fi
    echo "Restoring previous settings..."
    pmset -a sleep 0
    pmset -a displaysleep 180
    pmset -a disksleep 10
    pmset -a autorestart 1
    pmset -a womp 1
    pmset -a powernap 1
    pmset -a standby 0
    pmset repeat cancel
    echo "Done. Verify with: $0 status"
    ;;

  *)
    echo "Usage: $0 {apply|status|undo}"
    exit 1
    ;;
esac
