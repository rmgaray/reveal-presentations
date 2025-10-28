#!/usr/bin/env bash
set -euo pipefail
FIFO=inotify.fifo

rm -f "${FIFO}"
mkfifo "${FIFO}"

trap 'echo "shutting down..."; jobs -p | xargs -r kill 2>/dev/null || true; rm -f "${FIFO}"' INT TERM EXIT

inotifywait -e modify -m src/ > "${FIFO}" &
websocketd -port 8097 --devconsole ./call_pandoc.sh &

miniserve site/ -p 8096


