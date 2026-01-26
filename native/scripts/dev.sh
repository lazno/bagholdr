#!/bin/bash
#
# Start backend and optionally run Flutter on emulator, phone, or both
#
# Usage:
#   ./dev.sh                         # Backend only
#   ./dev.sh -e                      # Backend + emulator
#   ./dev.sh -p <ip:port>            # Backend + phone
#   ./dev.sh -b <ip:port>            # Backend + both
#
# Phone setup (first time):
#   1. Enable Developer Options > Wireless debugging on phone
#   2. Tap "Pair device with pairing code" and run: adb pair <ip>:<port>
#
set -e

export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$HOME/.pub-cache/bin"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$SCRIPT_DIR/../bagholdr/bagholdr_server"
FLUTTER_DIR="$SCRIPT_DIR/../bagholdr/bagholdr_flutter"
PID_DIR="$SCRIPT_DIR/.pids"
EMULATOR_ID="${EMULATOR:-Medium_Phone_API_36.1}"

# Phone IP:port for wireless ADB
PHONE_IP=""

# Parse args
USE_EMULATOR=false
USE_PHONE=false

show_help() {
    cat << EOF
Start Bagholdr backend and optionally run Flutter

Usage: ./dev.sh [OPTIONS]

Options:
  (none)               Backend only (Docker + Serverpod)
  -e, --emulator       Backend + emulator
  -p <ip:port>         Backend + phone via wireless ADB
  -b <ip:port>         Backend + both emulator and phone
  -h, --help           Show this help

Environment:
  EMULATOR    Emulator ID (default: $EMULATOR_ID)

Examples:
  ./dev.sh                              # Backend only
  ./dev.sh -e                           # Backend + emulator
  ./dev.sh -p 192.168.10.103:42963      # Backend + phone
  ./dev.sh -b 192.168.10.103:42963      # Backend + both
EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--emulator)
            USE_EMULATOR=true
            shift
            ;;
        -p|--phone)
            USE_PHONE=true
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                PHONE_IP="$2"
                shift
            else
                echo "Error: -p requires an IP:port argument"
                exit 1
            fi
            shift
            ;;
        -b|--both)
            USE_EMULATOR=true
            USE_PHONE=true
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                PHONE_IP="$2"
                shift
            else
                echo "Error: -b requires an IP:port argument"
                exit 1
            fi
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

mkdir -p "$PID_DIR"

echo "=== Bagholdr Dev ==="
echo ""

# 1. Docker
echo "[1/2] Starting Docker..."
cd "$SERVER_DIR"
docker compose up -d 2>/dev/null
until docker compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; do
    sleep 1
done
echo "     PostgreSQL ready."

# 2. Serverpod
echo "[2/2] Starting Serverpod..."
if [ -f "$PID_DIR/server.pid" ] && kill -0 "$(cat "$PID_DIR/server.pid")" 2>/dev/null; then
    echo "     Already running (PID: $(cat "$PID_DIR/server.pid"))."
else
    dart bin/main.dart --apply-migrations > "$PID_DIR/server.log" 2>&1 &
    SERVER_PID=$!
    echo $SERVER_PID > "$PID_DIR/server.pid"
    until curl -s http://localhost:8080/ > /dev/null 2>&1; do
        sleep 1
    done
    echo "     Server ready (PID: $SERVER_PID)."
fi

# If no device flags, we're done (backend only)
if [ "$USE_EMULATOR" = false ] && [ "$USE_PHONE" = false ]; then
    echo ""
    echo "=== Backend Ready ==="
    echo ""
    echo "  PostgreSQL: localhost:8090"
    echo "  Redis:      localhost:8091"
    echo "  Serverpod:  localhost:8080"
    echo ""
    echo "Run Flutter manually:"
    echo "  Emulator: cd native/bagholdr/bagholdr_flutter && flutter run -d emulator-5554"
    echo "  Phone:    cd native/bagholdr/bagholdr_flutter && flutter run -d <ip:port> --dart-define=SERVER_URL=http://\$(ipconfig getifaddr en0):8080/"
    echo ""
    echo "Stop: ./native/scripts/stop.sh"
    exit 0
fi

# 3. Setup devices
echo ""
echo "[3/4] Setting up devices..."
DEVICES=""

if [ "$USE_EMULATOR" = true ]; then
    if adb devices | grep -q "emulator"; then
        echo "     Emulator already running."
        EMULATOR_DEVICE=$(adb devices | grep emulator | head -1 | cut -f1)
    else
        flutter emulators --launch "$EMULATOR_ID" > /dev/null 2>&1 &
        # Wait for emulator to appear in device list
        echo -n "     Waiting for emulator"
        while ! adb devices | grep -q "emulator"; do
            echo -n "."
            sleep 2
        done
        EMULATOR_DEVICE=$(adb devices | grep emulator | head -1 | cut -f1)
        # Wait for boot to complete (use -s to target specific device)
        while [ "$(adb -s "$EMULATOR_DEVICE" shell getprop sys.boot_completed 2>/dev/null)" != "1" ]; do
            echo -n "."
            sleep 2
        done
        echo ""
        echo "     Emulator ready."
    fi
    DEVICES="$EMULATOR_DEVICE"
fi

if [ "$USE_PHONE" = true ]; then
    echo "     Connecting to phone at $PHONE_IP..."
    adb connect "$PHONE_IP" > /dev/null 2>&1 || true
    sleep 1
    # Check if phone is in device list
    if adb devices | grep -q "$PHONE_IP"; then
        echo "     Phone connected."
        PHONE_DEVICE="$PHONE_IP"
    else
        echo "     ERROR: Could not connect to phone at $PHONE_IP"
        echo "     Make sure wireless debugging is enabled and you've paired the device."
        exit 1
    fi
    if [ -n "$DEVICES" ]; then
        DEVICES="$DEVICES,$PHONE_DEVICE"
    else
        DEVICES="$PHONE_DEVICE"
    fi
fi

# 4. Flutter
echo "[4/4] Running Flutter..."
echo ""
echo "     Devices: $DEVICES"
echo "     Press r for hot reload, R for hot restart, q to quit"

cd "$FLUTTER_DIR"

# Build dart-define args for physical device (needs Mac's local IP, not 10.0.2.2)
DART_DEFINES=""
if [ "$USE_PHONE" = true ]; then
    # Get Mac's local IP on the network
    MAC_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)
    if [ -n "$MAC_IP" ]; then
        DART_DEFINES="--dart-define=SERVER_URL=http://$MAC_IP:8080/"
        echo "     Server URL: http://$MAC_IP:8080/"
    else
        echo "     WARNING: Could not detect Mac IP. Phone may not connect to server."
    fi
fi
echo ""

if [ "$USE_EMULATOR" = true ] && [ "$USE_PHONE" = true ]; then
    # Run on all connected devices
    flutter run -d all $DART_DEFINES
else
    # Run on single device
    flutter run -d "$DEVICES" $DART_DEFINES
fi
