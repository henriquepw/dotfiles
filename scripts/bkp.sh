#!/bin/bash

/opt/homebrew/bin/rclone sync /Volumes/server /Volumes/bkp/backup \
  --filter "- **/node_modules/**" \
  --filter "- **/cache/**" \
  --filter "- /git/**/ios/**" \
  --filter "- /git/**/android/**" \
  --filter "+ /apps/immich/**" \
  --filter "+ /git/**" \
  --filter "+ /documents/**" \
  --filter "- **" \
  --order-by size,descending \
  --backup-dir "/Volumes/bkp/old/$(date +%Y-%m-%d)" \
  --delete-during \
  --log-file ~/backup.log \
  --log-level INFO \
  --fast-list \
  --progress
