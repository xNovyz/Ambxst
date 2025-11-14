#!/usr/bin/env bash
# Ambxst CLI - Main entry point for Ambxst desktop environment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Use environment variables if set by flake, otherwise fall back to PATH
QS_BIN="${AMBXST_QS:-qs}"
NIXGL_BIN="${AMBXST_NIXGL:-}"

show_help() {
    cat << EOF
Ambxst CLI - Desktop Environment Control

Usage: ambxst [COMMAND]

Commands:
    (none)      Launch Ambxst desktop shell
    update      Update Ambxst via nix profile
    lock        Activate lockscreen
    help        Show this help message

EOF
}

find_ambxst_pid() {
    # Find the QuickShell process running shell.qml from this directory
    pgrep -f "quickshell.*${SCRIPT_DIR}/shell.qml" | head -1
}

case "${1:-}" in
    update)
        echo "Updating Ambxst..."
        exec "${SCRIPT_DIR}/install.sh"
        ;;
    lock)
        # Trigger lockscreen via quickshell-ipc
        PID=$(find_ambxst_pid)
        if [ -z "$PID" ]; then
            echo "Error: Ambxst is not running"
            exit 1
        fi
        qs ipc --pid "$PID" call lockscreen lock 2>/dev/null || {
            echo "Error: Could not activate lockscreen"
            exit 1
        }
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        # Launch QuickShell with the main shell.qml
        if [ -n "$NIXGL_BIN" ]; then
            exec "$NIXGL_BIN" "$QS_BIN" -p "${SCRIPT_DIR}/shell.qml"
        else
            exec "$QS_BIN" -p "${SCRIPT_DIR}/shell.qml"
        fi
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo "Run 'ambxst help' for usage information"
        exit 1
        ;;
esac
