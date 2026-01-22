#!/bin/bash
#
# Start Bagholdr with hot reload for both web and emulator
#
# Usage: ./start-with-hotreload.sh
#
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLUTTER_DIR="$SCRIPT_DIR/../bagholdr/bagholdr_flutter"
EMULATOR_LOG="/tmp/flutter-emulator.log"

echo "=== Starting Bagholdr with Hot Reload ==="
echo ""

# 1. Start base services (Docker, Serverpod, web, emulator)
echo "[1/4] Starting base services..."
"$SCRIPT_DIR/start.sh" --web --emulator

# 2. Start Flutter on emulator in background
echo ""
echo "[2/4] Starting Flutter on emulator..."
cd "$FLUTTER_DIR"
flutter run -d emulator-5554 > "$EMULATOR_LOG" 2>&1 &
FLUTTER_PID=$!

# Poll until Flutter is ready (max 60 seconds)
echo -n "     Waiting for Flutter build"
for i in {1..60}; do
  if grep -q "Flutter run key commands" "$EMULATOR_LOG" 2>/dev/null; then
    echo ""
    echo "     Flutter ready (PID: $FLUTTER_PID)"
    break
  fi
  if ! kill -0 $FLUTTER_PID 2>/dev/null; then
    echo ""
    echo "     ERROR: Flutter process died. Check $EMULATOR_LOG"
    tail -20 "$EMULATOR_LOG"
    exit 1
  fi
  echo -n "."
  sleep 1
done

# Check if we timed out
if ! grep -q "Flutter run key commands" "$EMULATOR_LOG" 2>/dev/null; then
  echo ""
  echo "     ERROR: Flutter build timed out. Check $EMULATOR_LOG"
  exit 1
fi

# 3. Start hot reload watchers
echo ""
echo "[3/4] Starting hot reload watchers..."
"$SCRIPT_DIR/watch-reload.sh" web > /tmp/watch-web.log 2>&1 &
echo "     Web watcher started (PID: $!)"
"$SCRIPT_DIR/watch-reload.sh" emulator > /tmp/watch-emulator.log 2>&1 &
echo "     Emulator watcher started (PID: $!)"

# 4. Done
echo ""
echo "[4/4] Ready!"
echo ""
echo "=== Hot Reload Active ==="
echo ""
echo "Services:"
echo "  - Flutter web:      http://localhost:3001"
echo "  - Flutter emulator: running"
echo "  - Hot reload:       watching lib/**/*.dart"
echo ""
echo "Logs:"
echo "  - Emulator: $EMULATOR_LOG"
echo "  - Web watcher: /tmp/watch-web.log"
echo "  - Emulator watcher: /tmp/watch-emulator.log"
echo ""
echo "Stop: ./native/scripts/stop.sh --all"
