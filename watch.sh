#!/usr/bin/env bash
set -euo pipefail
FIFO=inotify.fifo

rm -f "$FIFO"
mkfifo "$FIFO"

trap 'echo "shutting down..."; jobs -p | xargs -r kill 2>/dev/null || true; rm -f "$FIFO"' INT TERM EXIT

inotifywait -e modify -m src/ > "${FIFO}" &
./call_pandoc.sh
