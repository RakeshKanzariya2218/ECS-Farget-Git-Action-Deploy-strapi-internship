#!/bin/bash

# ===============================
# Log Management Script
# ===============================

LOG_DIR="/var/logs/checkins"
BACKUP_DIR="/backup/logs"
LOG_FILE="$HOME/backup_activity.log"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

# Create backup directory if not exist
mkdir -p "$BACKUP_DIR"

# Find logs older than 7 days
OLD_LOGS=$(find "$LOG_DIR" -type f -mtime +7)

if [ -n "$OLD_LOGS" ]; then
  ARCHIVE_NAME="logs_backup_$DATE.tar.gz"
  tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" $OLD_LOGS
  
  if [ $? -eq 0 ]; then
    # Delete old logs only after successful backup
    find "$LOG_DIR" -type f -mtime +7 -delete
    echo "[$(date)] Backed up and deleted old logs -> $ARCHIVE_NAME" >> "$LOG_FILE"
  else
    echo "[$(date)] Backup failed for logs older than 7 days" >> "$LOG_FILE"
  fi
else
  echo "[$(date)] No old logs found to backup" >> "$LOG_FILE"
fi
