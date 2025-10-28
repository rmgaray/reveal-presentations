#!/usr/bin/env bash
# Call make whenever a line is read
set -euo pipefail

FIFO=inotify.fifo

while IFS= read -r _; do
  make --silent presentations/*.html
  echo "reload"
done < "${FIFO}"
