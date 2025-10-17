#!/bin/bash

# Resource Monitoring Script


# Thresholds
CPU_THRESHOLD=80
MEM_THRESHOLD=75
DISK_THRESHOLD=85

# Email ID where alerts will be sent
EMAIL="rkanzariya1234@gmail.com"

# Get system stats
HOSTNAME=$(hostname)
DATE=$(date "+%Y-%m-%d %H:%M:%S")

# CPU usage (integer only)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d'.' -f1)

# Memory usage (integer only)
MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d'.' -f1)

# Disk usage (integer only)
DISK_USAGE=$(df -h / | grep / | awk '{print $5}' | sed 's/%//g')

# Load average
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1)





# Check Thresholds

ALERT=0
MESSAGE="System Alert on $HOSTNAME at $DATE\n"

if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
  MESSAGE+="CPU usage is ${CPU_USAGE}% (Threshold: ${CPU_THRESHOLD}%)\n"
  ALERT=1
fi

if [ "$MEM_USAGE" -gt "$MEM_THRESHOLD" ]; then
  MESSAGE+="Memory usage is ${MEM_USAGE}% (Threshold: ${MEM_THRESHOLD}%)\n"
  ALERT=1
fi

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
  MESSAGE+="Disk usage is ${DISK_USAGE}% (Threshold: ${DISK_THRESHOLD}%)\n"
  ALERT=1
fi

# If any alert is triggered, send mail
if [ "$ALERT" -eq 1 ]; then
  echo -e "$MESSAGE\nLoad Average: $LOAD_AVG" | mailx -s "ALERT: Resource Usage High on $HOSTNAME" "$EMAIL"
fi

