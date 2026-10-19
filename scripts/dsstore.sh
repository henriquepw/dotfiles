#!/bin/bash

defaults write com.apple.desktopservices DSDontWriteNetworkStores true
killall Finder 2>/dev/null

VOLUMES=("/Volumes/bkp" "/Volumes/server")
for VOL in "${VOLUMES[@]}"; do
  if [ -d "$VOL" ]; then
    find "$VOL" -name ".DS_Store" -delete
  fi
done
