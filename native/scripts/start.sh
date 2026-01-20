#!/bin/bash
#
# Start Bagholdr native app development environment
#
set -e

# Add Android SDK tools to PATH
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$HOME/.pub-cache/bin"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$SCRIPT_DIR/../bagholdr/bagholdr_server"
FLUTTER_DIR="$SCRIPT_DIR/../bagholdr/bagholdr_flutter"
PID_DIR="$SCRIPT_DIR/.pids"

# Default emulator (can override with EMULATOR env var)
EMULATOR_ID="${EMULATOR:-Medium_Phone_API_36.1}"

show_help() {
    cat << EOF
Start Bagholdr native app development environment

Usage: ./start.sh [OPTIONS]

Options:
  --web         Start Flutter web on port 3001 (background)
  --emulator    Start Android emulator
  --run         Run Flutter app on emulator (foreground, shows build output)
                Requires --emulator
  --all         Start everything: Docker + server + web + emulator + Flutter app
                Equivalent to: --web --emulator --run
  --help        Show this help message

Examples:
  ./start.sh                    # Docker + Serverpod server only
  ./start.sh --web              # + Flutter web (background)
  ./start.sh --emulator         # + Emulator (ready for manual flutter run)
  ./start.sh --emulator --run   # + Run Flutter on emulator (foreground)
  ./start.sh --all              # Everything

Environment:
  EMULATOR    Emulator ID to use (default: Medium_Phone_API_36.1)

Stop services:
  ./stop.sh                     # Stop services (keeps emulator)
  ./stop.sh --all               # Stop everything including emulator
EOF
}

# Parse arguments
START_WEB=false
START_EMULATOR=false
RUN_FLUTTER=false

for arg in "$@"; do
    case $arg in
        --web)
            START_WEB=true
            ;;
        --emulator)
            START_EMULATOR=true
            ;;
        --run)
            RUN_FLUTTER=true
            ;;
        --all)
            START_WEB=true
            START_EMULATOR=true
            RUN_FLUTTER=true
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Run './start.sh --help' for usage"
            exit 1
            ;;
    esac
done

# Create PID directory
mkdir -p "$PID_DIR"

echo "=== Bagholdr Native App Startup ==="
echo ""

# 1. Start Docker containers
echo "[1/5] Starting Docker containers..."
cd "$SERVER_DIR"
docker compose up -d

# Wait for PostgreSQL to be ready
echo "     Waiting for PostgreSQL..."
until docker compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; do
    sleep 1
done
echo "     PostgreSQL ready."

# 2. Start Serverpod server
echo "[2/5] Starting Serverpod server..."
dart bin/main.dart --apply-migrations > "$PID_DIR/server.log" 2>&1 &
SERVER_PID=$!
echo $SERVER_PID > "$PID_DIR/server.pid"

# Wait for server to be ready
echo "     Waiting for server..."
until curl -s http://localhost:8080/ > /dev/null 2>&1; do
    sleep 1
done
echo "     Server ready (PID: $SERVER_PID)."

# 3. Start emulator (if requested)
if [ "$START_EMULATOR" = true ]; then
    echo "[3/5] Starting Android emulator ($EMULATOR_ID)..."

    # Check if emulator is already running
    if adb devices | grep -q "emulator"; then
        echo "     Emulator already running."
    else
        flutter emulators --launch "$EMULATOR_ID" > /dev/null 2>&1 &

        # Wait for emulator to boot
        echo "     Waiting for emulator to boot..."
        adb wait-for-device

        # Wait for boot completion
        while [ "$(adb shell getprop sys.boot_completed 2>/dev/null)" != "1" ]; do
            sleep 2
        done
        echo "     Emulator ready."
    fi
else
    echo "[3/5] Skipping emulator (use --emulator to start)"
fi

# 4. Start Flutter web (if requested)
if [ "$START_WEB" = true ]; then
    echo "[4/5] Starting Flutter web on port 3001..."
    cd "$FLUTTER_DIR"
    flutter run -d chrome --web-port=3001 > "$PID_DIR/flutter-web.log" 2>&1 &
    FLUTTER_WEB_PID=$!
    echo $FLUTTER_WEB_PID > "$PID_DIR/flutter-web.pid"

    # Wait for web server
    echo "     Waiting for Flutter web..."
    until curl -s http://localhost:3001/ > /dev/null 2>&1; do
        sleep 2
    done
    echo "     Flutter web ready (PID: $FLUTTER_WEB_PID)."
else
    echo "[4/5] Skipping Flutter web (use --web to start)"
fi

# 5. Start Flutter on emulator (if requested)
if [ "$START_EMULATOR" = true ] && [ "$RUN_FLUTTER" = true ]; then
    cd "$FLUTTER_DIR"

    # Get the emulator device ID (e.g., emulator-5554)
    EMULATOR_DEVICE=$(adb devices | grep emulator | head -1 | cut -f1)
    if [ -z "$EMULATOR_DEVICE" ]; then
        echo "[5/5] ERROR: No emulator device found"
        exit 1
    fi

    echo "[5/5] Running Flutter app on emulator (foreground)..."
    echo ""
    echo "=== Flutter Build Output ==="
    echo ""
    # Run in foreground so user sees build progress
    flutter run -d "$EMULATOR_DEVICE"
elif [ "$START_EMULATOR" = true ]; then
    echo "[5/5] Emulator ready. To run Flutter app:"
    echo "     cd native/bagholdr/bagholdr_flutter && flutter run"
else
    echo "[5/5] Skipping emulator"
fi

# Only show summary if not running Flutter in foreground (it takes over the terminal)
if [ "$RUN_FLUTTER" = false ] || [ "$START_EMULATOR" = false ]; then
    echo ""
    echo "=== Startup Complete ==="
    echo ""
    echo "Services running:"
    echo "  - PostgreSQL:    localhost:8090"
    echo "  - Redis:         localhost:8091"
    echo "  - Serverpod:     localhost:8080"
    [ "$START_WEB" = true ] && echo "  - Flutter web:   localhost:3001"
    [ "$START_EMULATOR" = true ] && echo "  - Emulator:      running"
    echo ""
    echo "Logs: $PID_DIR/*.log"
    echo "Stop: ./native/scripts/stop.sh"
fi
