#!/bin/bash
#
# Watch Dart files and auto-trigger hot reload on changes
#
# Usage: ./watch-reload.sh [web|emulator]
#
# Prerequisites:
# - Flutter must be running in debug mode
# - fswatch must be installed: brew install fswatch
#
# How it works:
# 1. Watches all .dart files in bagholdr_flutter/lib/
# 2. When a file changes, sends SIGUSR1 to Flutter process
# 3. Hot reload happens in ~1 second
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLUTTER_DIR="$SCRIPT_DIR/../bagholdr/bagholdr_flutter"

TARGET="${1:-web}"

# Check for fswatch
if ! command -v fswatch &> /dev/null; then
  echo "Error: fswatch not installed"
  echo "Install with: brew install fswatch"
  exit 1
fi

get_flutter_pid() {
  case "$TARGET" in
    web)
      pgrep -f "flutter_tools.snapshot.*run.*chrome" | head -1
      ;;
    emulator)
      pgrep -f "flutter_tools.snapshot.*run.*emulator" | head -1
      ;;
  esac
}

trigger_reload() {
  local pid=$(get_flutter_pid)
  if [ -z "$pid" ]; then
    echo "✗ (Flutter not running)"
    return 1
  fi

  if kill -SIGUSR1 "$pid" 2>/dev/null; then
    echo "✓"
    return 0
  else
    echo "✗ (signal failed)"
    return 1
  fi
}

echo "=== Flutter Hot Reload Watcher ==="
echo ""
echo "Watching: $FLUTTER_DIR/lib/**/*.dart"
echo "Target:   $TARGET"
echo ""

# Verify Flutter is running
PID=$(get_flutter_pid)
if [ -z "$PID" ]; then
  echo "Error: Flutter not running for $TARGET"
  echo ""
  echo "Start Flutter first:"
  echo "  Web:      ./start.sh --web"
  echo "  Emulator: ./start.sh --emulator --run"
  exit 1
fi
echo "Flutter PID: $PID"
echo ""
echo "Make changes to Dart files - they will hot reload automatically!"
echo "Press Ctrl+C to stop"
echo ""

# Watch for changes and trigger reload
fswatch -o -r --include='\.dart$' --exclude='.*' "$FLUTTER_DIR/lib" | while read -r count; do
  echo -n "[$(date +%H:%M:%S)] File changed, reloading... "
  trigger_reload
done
