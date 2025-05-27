#!/bin/bash

usage() {
  echo "Use: $0 --config /dir/theme"
  exit 1
}

if [[ "$1" != "--config" || -z "$2" ]]; then
  usage
fi

THEME_DIR="$2"
TIMEOUT=10
RESOLUTION="1920x1080"
VNC_DISPLAY="localhost:0"

sudo grub2-theme-preview --timeout $TIMEOUT --resolution $RESOLUTION "$THEME_DIR" &
PREVIEW_PID=$!

sleep 3

vncviewer $VNC_DISPLAY

kill $PREVIEW_PID 2>/dev/null

rm -rf /tmp/grub2-theme-preview*

exit 0
