#!/usr/bin/env bash
# Top-level router: detect OS and dispatch to the right installer.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

case "$(uname -s)" in
    Darwin)
        exec bash "$SCRIPT_DIR/mac/install.sh" "$@"
        ;;
    Linux)
        exec bash "$SCRIPT_DIR/linux/install.sh" "$@"
        ;;
    *)
        echo "Unsupported OS: $(uname -s)" >&2
        exit 1
        ;;
esac
