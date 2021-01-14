#!/bin/sh

set -e

# TODO find /dev/dri/cardX instead of card0
if [ -f /dev/dri/card0 ]; then
  export VGL_DISPLAY="/dev/dri/card0"
fi

if [ "$#" -gt 0 ]; then
  exec "$@"
fi
