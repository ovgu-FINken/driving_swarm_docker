#!/bin/sh

set -e

for DRM in /dev/dri/card*; do
  if /opt/VirtualGL/bin/eglinfo "$DRM" > /dev/null; then
    export VGL_DISPLAY="$DRM"
    break
  fi
done

if [ "$#" -gt 0 ]; then
  exec "$@"
fi
