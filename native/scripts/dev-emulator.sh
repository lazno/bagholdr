#!/bin/bash
#
# Start backend + emulator and run Flutter in foreground (for manual hot reload)
#
# Usage: ./dev-emulator.sh
#
set -e

export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$HOME/.pub-cache/bin"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$SCRIPT_DIR/../bagholdr/bagholdr_server"
FLUTTER_DIR="$SCRIPT_DIR/../bagholdr/bagholdr_flutter"
PID_DIR="$SCRIPT_DIR/.pids"
EMULATOR_ID="${EMULATOR:-Medium_Phone_API_36.1}"

mkdir -p "$PID_DIR"

echo "=== Bagholdr Dev (Emulator) ==="
echo ""

# 1. Docker
echo "[1/4] Starting Docker..."
cd "$SERVER_DIR"
docker compose up -d 2>/dev/null
until docker compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; do
    sleep 1
done
echo "     PostgreSQL ready."

# 2. Serverpod
echo "[2/4] Starting Serverpod..."
dart bin/main.dart --apply-migrations > "$PID_DIR/server.log" 2>&1 &
SERVER_PID=$!
echo $SERVER_PID > "$PID_DIR/server.pid"
until curl -s http://localhost:8080/ > /dev/null 2>&1; do
    sleep 1
done
echo "     Server ready (PID: $SERVER_PID)."

# 3. Emulator
echo "[3/4] Starting emulator..."
if adb devices | grep -q "emulator"; then
    echo "     Already running."
else
    flutter emulators --launch "$EMULATOR_ID" > /dev/null 2>&1 &
    adb wait-for-device
    while [ "$(adb shell getprop sys.boot_completed 2>/dev/null)" != "1" ]; do
        sleep 2
    done
    echo "     Emulator ready."
fi

# 4. Flutter (foreground - press R to hot reload)
EMULATOR_DEVICE=$(adb devices | grep emulator | head -1 | cut -f1)
if [ -z "$EMULATOR_DEVICE" ]; then
    echo "ERROR: No emulator device found"
    exit 1
fi

echo "[4/4] Running Flutter on $EMULATOR_DEVICE..."
echo ""
echo "     Press R for hot reload, r for hot restart, q to quit"
echo ""

cd "$FLUTTER_DIR"
flutter run -d "$EMULATOR_DEVICE"
