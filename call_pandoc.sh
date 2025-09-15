#!/usr/bin/env bash
# Call make whenever a line is read
while IFS= read -r line; do
  make --silent site/html/*
  echo "reload"
done <inotify.fifo
