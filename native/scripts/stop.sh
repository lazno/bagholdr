#!/bin/bash
#
# Stop Bagholdr native app development environment
#
set -e

# Add Android SDK tools to PATH
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$SCRIPT_DIR/../bagholdr/bagholdr_server"
PID_DIR="$SCRIPT_DIR/.pids"

show_help() {
    cat << EOF
Stop Bagholdr native app development environment

Usage: ./stop.sh [OPTIONS]

Options:
  --emulator    Also stop the Android emulator
  --all         Stop everything including emulator (same as --emulator)
  --help        Show this help message

Examples:
  ./stop.sh                # Stop Flutter, Serverpod, Docker (keeps emulator running)
  ./stop.sh --all          # Stop everything including emulator

What gets stopped:
  - Flutter processes (web and emulator)
  - Serverpod server
  - Docker containers (PostgreSQL, Redis)
  - Android emulator (only with --emulator or --all)
EOF
}

# Parse arguments
STOP_EMULATOR=false

for arg in "$@"; do
    case $arg in
        --emulator|--all)
            STOP_EMULATOR=true
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Run './stop.sh --help' for usage"
            exit 1
            ;;
    esac
done

echo "=== Bagholdr Native App Shutdown ==="
echo ""

# 1. Stop Flutter processes
echo "[1/4] Stopping Flutter processes..."
if [ -f "$PID_DIR/flutter-web.pid" ]; then
    PID=$(cat "$PID_DIR/flutter-web.pid")
    kill $PID 2>/dev/null || true
    rm "$PID_DIR/flutter-web.pid"
    echo "     Flutter web stopped."
fi

if [ -f "$PID_DIR/flutter-emulator.pid" ]; then
    PID=$(cat "$PID_DIR/flutter-emulator.pid")
    kill $PID 2>/dev/null || true
    rm "$PID_DIR/flutter-emulator.pid"
    echo "     Flutter emulator app stopped."
fi

# Also kill any stray flutter processes
pkill -f "flutter run" 2>/dev/null || true

# 2. Stop Serverpod server
echo "[2/4] Stopping Serverpod server..."
if [ -f "$PID_DIR/server.pid" ]; then
    PID=$(cat "$PID_DIR/server.pid")
    kill $PID 2>/dev/null || true
    rm "$PID_DIR/server.pid"
    echo "     Server stopped."
fi

# Also kill any stray dart processes for this project
pkill -f "dart bin/main.dart" 2>/dev/null || true

# 3. Stop emulator (if requested)
if [ "$STOP_EMULATOR" = true ]; then
    echo "[3/4] Stopping Android emulator..."
    adb devices | grep emulator | cut -f1 | while read device; do
        adb -s "$device" emu kill 2>/dev/null || true
    done
    echo "     Emulator stopped."
else
    echo "[3/4] Skipping emulator (use --emulator to stop)"
fi

# 4. Stop Docker containers
echo "[4/4] Stopping Docker containers..."
cd "$SERVER_DIR"
docker compose down
echo "     Docker containers stopped."

# Clean up logs
rm -f "$PID_DIR"/*.log 2>/dev/null || true

echo ""
echo "=== Shutdown Complete ==="
