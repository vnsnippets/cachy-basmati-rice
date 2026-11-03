#!/bin/bash

if [ -z "$1" ]; then
    echo '{"error":"Missing argument. Usage: ./script.sh <app-id>"}'
    exit 1
fi

APP_ID="$1"

# 1. Instantly gather all PIDs across standard and Flatpak sandboxed application slices
# PIDS=$(pgrep -d , -f "([./ ]|^)$APP_ID([./ ]|$)")
PIDS=$(pgrep -A -d , -f "([./ ]|^)$APP_ID([./ ]|$)")

# 2. If pgrep misses, pull directly from the active systemd cgroups slice mapping
if [ -z "$PIDS" ]; then
    PIDS=$(systemctl --user show-item=MainPID app-*-${APP_ID//./*-}.scope 2>/dev/null | cut -d= -f2)
fi

# 3. If no PIDs match, check if it's currently running as an active Flatpak
# if [ -z "$PIDS" ] || [ "$PIDS" = "0" ]; then
#     PIDS=$(flatpak ps --columns=pid,application | grep "$APP_ID" | awk '{print $1}' | tr '\n' ',' | sed 's/,$//')
# fi

# Final check: If all native system paths are empty, the app is inactive
if [ -z "$PIDS" ] || [ "$PIDS" = "0" ]; then
    echo "{\"active\":false,\"app_id\":\"$APP_ID\",\"total_cpu_percent\":0.0,\"total_ram_percent\":0.0,\"total_ram_mb\":0.0}"
    exit 0
fi

# Fetch resource metrics, sum them up, and output a single-line JSON string
ps -p "$PIDS" -o %cpu=,pmem=,rss= 2>/dev/null | awk -v app="$APP_ID" '
{
    cpu += $1
    mem += $2
    rss += $3
}
END {
    printf "{\"active\":true,\"app_id\":\"%s\",\"total_cpu_percent\":%.1f,\"total_ram_percent\":%.1f,\"total_ram_mb\":%.2f}\n", app, cpu, mem, rss/1024
}'
