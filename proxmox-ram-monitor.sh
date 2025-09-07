#!/bin/bash

# Proxmox RAM Usage Monitor v3.4
# This script provides a summary of RAM and CPU usage for the host, LXC containers, and QEMU/KVM virtual machines.
# It displays a high-level composite bar and a detailed table for all running machines.

# --- Configuration ---
BAR_WIDTH=50 # Width of the progress bars in characters

# --- Colors for Output ---
COLOR_RESET='\033[0m'
COLOR_TITLE='\033[1;36m'
COLOR_HEADER='\033[1;33m'
COLOR_TABLE_HEADER='\033[1;34m'
COLOR_BAR_EMPTY='\033[47m' # White background

# --- Colors for Composite Bar ---
COLOR_HOST='\033[44m'    # Blue
COLOR_VM='\033[45m'      # Magenta
COLOR_LXC='\033[46m'     # Cyan

# --- Main Script ---

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root to access system information." >&2
   exit 1
fi

clear
printf "${COLOR_TITLE}Proxmox Resource Usage Report${COLOR_RESET}\n"
printf "=================================\n"

# --- Data Collection ---
TOTAL_RAM_MB=$(free -m | awk '/^Mem:/{print $2}')
HOST_USED_MB=$(free -m | awk '/^Mem:/{print $2 - $7}')
printf "Total System RAM: ${TOTAL_RAM_MB} MB\n\n"

declare -A lxc_data
declare -A vm_data
TOTAL_GUEST_MB=0

# Collect LXC Data
for lxc_id in $(pct list | awk 'NR>1 && $2=="running" {print $1}'); do
    # Get CPU from the more reliable 'pct status' command
    status_output=$(pct status "$lxc_id")
    lxc_data["$lxc_id", "cpu"]=$(echo "$status_output" | awk '/^cpu:/{printf "%.2f", $2}')

    CGROUP_V2_PATH="/sys/fs/cgroup/lxc/${lxc_id}/memory.current"
    CGROUP_V1_PATH="/sys/fs/cgroup/memory/lxc/${lxc_id}/memory.usage_in_bytes"
    
    LXC_USED_BYTES=0
    if [ -f "$CGROUP_V2_PATH" ]; then
        LXC_USED_BYTES=$(cat "$CGROUP_V2_PATH")
    elif [ -f "$CGROUP_V1_PATH" ]; then
        LXC_USED_BYTES=$(cat "$CGROUP_V1_PATH")
    fi

    LXC_USED_MB=$(( LXC_USED_BYTES / 1024 / 1024 ))
    TOTAL_GUEST_MB=$(( TOTAL_GUEST_MB + LXC_USED_MB ))
    lxc_data["$lxc_id", "ram_used"]=$LXC_USED_MB
done

# Collect VM Data
for vm_id in $(qm list | awk 'NR>1 && $3=="running" {print $1}'); do
    status_output=$(qm status "$vm_id" 2>/dev/null)
    vm_data["$vm_id", "cpu"]=$(echo "$status_output" | awk '/^cpu:/{printf "%.2f", $2}')

    VM_PID_FILE="/var/run/qemu-server/${vm_id}.pid"
    if [ -f "$VM_PID_FILE" ]; then
        VM_PID=$(cat "$VM_PID_FILE")
        VM_USED_KB=$(ps -o rss= -p "$VM_PID" 2>/dev/null || echo 0)
        VM_USED_MB=$(( VM_USED_KB / 1024 ))
        TOTAL_GUEST_MB=$(( TOTAL_GUEST_MB + VM_USED_MB ))
        vm_data["$vm_id", "ram_used"]=$VM_USED_MB
    else
        vm_data["$vm_id", "ram_used"]=0
    fi
done

# --- 1. Overall Usage Bar ---
HOST_ONLY_MB=$(( HOST_USED_MB - TOTAL_GUEST_MB ))
if [ $HOST_ONLY_MB -lt 0 ]; then HOST_ONLY_MB=0; fi
HOST_ONLY_PERCENT=$(( (HOST_ONLY_MB * 100) / TOTAL_RAM_MB ))
HOST_TOTAL_USED_PERCENT=$(( (HOST_USED_MB * 100) / TOTAL_RAM_MB ))

printf "${COLOR_HEADER}Overall RAM Usage Breakdown${COLOR_RESET}\n"
# Draw Composite Bar
printf "["
host_width=$(( (BAR_WIDTH * HOST_ONLY_PERCENT) / 100 )); [ $host_width -gt 0 ] && printf "${COLOR_HOST}%${host_width}s" " "
for vm_id in $(for key in "${!vm_data[@]}"; do echo "$key"; done | cut -d, -f1 | sort -un); do
    VM_USED_MB=${vm_data[$vm_id, "ram_used"]}
    vm_percent=$(( (VM_USED_MB * 100) / TOTAL_RAM_MB ))
    vm_width=$(( (BAR_WIDTH * vm_percent) / 100 )); [ $vm_width -gt 0 ] && printf "${COLOR_VM}%${vm_width}s" " "
done
for lxc_id in $(for key in "${!lxc_data[@]}"; do echo "$key"; done | cut -d, -f1 | sort -un); do
    LXC_USED_MB=${lxc_data[$lxc_id, "ram_used"]}
    lxc_percent=$(( (LXC_USED_MB * 100) / TOTAL_RAM_MB ))
    lxc_width=$(( (BAR_WIDTH * lxc_percent) / 100 )); [ $lxc_width -gt 0 ] && printf "${COLOR_LXC}%${lxc_width}s" " "
done
empty_width=$(( BAR_WIDTH - (BAR_WIDTH * HOST_TOTAL_USED_PERCENT) / 100 )); [ $empty_width -gt 0 ] && printf "${COLOR_BAR_EMPTY}%${empty_width}s" " "
printf "${COLOR_RESET}] ${HOST_TOTAL_USED_PERCENT}%% Used\n"
printf " ${COLOR_HOST} \033[0m Host   ${COLOR_VM} \033[0m VM     ${COLOR_LXC} \033[0m LXC    ${COLOR_BAR_EMPTY} \033[0m Free\n\n"

# --- 2. Detailed Usage Table ---
printf "${COLOR_TABLE_HEADER}%-6s %-5s %-20s %-8s %-12s %-12s %s${COLOR_RESET}\n" "TYPE" "ID" "NAME" "CPU %" "RAM USED" "RAM MAX" "TOP PROCESS"

# Host Info
HOST_TOP_PROC=$(ps aux --sort=-%mem | awk 'NR==2{split($11,a,"/"); printf "%.1f%% %s", $4, a[length(a)]}')
printf "%-6s %-5s %-20s %-8s %-12s %-12s %s\n" \
    "Host" "---" "Proxmox VE" "---" "${HOST_ONLY_MB} MB" "${TOTAL_RAM_MB} MB" "${HOST_TOP_PROC}"

# LXC Containers
for lxc_id in $(for key in "${!lxc_data[@]}"; do echo "$key"; done | cut -d, -f1 | sort -un); do
    LXC_NAME=$(pct config "$lxc_id" | awk '/^hostname:/{print $2}')
    LXC_USED_MB=${lxc_data[$lxc_id, "ram_used"]}
    LXC_MAX_MB=$(pct config "$lxc_id" | awk '/^memory:/{print $2}')
    LXC_CPU=${lxc_data[$lxc_id, "cpu"]}
    LXC_TOP_PROC=$(pct exec "$lxc_id" -- ps aux --sort=-%mem | awk 'NR==2{split($11,a,"/"); printf "%.1f%% %s", $4, a[length(a)]}' || echo "N/A")
    
    printf "%-6s %-5s %-20s %-8s %-12s %-12s %s\n" \
        "LXC" "$lxc_id" "$LXC_NAME" "$LXC_CPU" "${LXC_USED_MB} MB" "${LXC_MAX_MB:-No limit} MB" "$LXC_TOP_PROC"
done

# QEMU VMs
for vm_id in $(for key in "${!vm_data[@]}"; do echo "$key"; done | cut -d, -f1 | sort -un); do
    VM_NAME=$(qm config "$vm_id" | awk '/^name:/{print $2}')
    VM_USED_MB=${vm_data[$vm_id, "ram_used"]}
    VM_MAX_MB=$(qm config "$vm_id" | awk '/^memory:/{print $2; exit}')
    VM_CPU=${vm_data[$vm_id, "cpu"]}
    # FIX: Wrap the command for 'exec' in 'sh -c' to handle arguments correctly.
    VM_TOP_PROC=$(timeout 2 qm agent "$vm_id" exec -- sh -c 'ps aux --sort=-%mem' 2>/dev/null | awk 'NR==2{split($11,a,"/"); printf "%.1f%% %s", $4, a[length(a)]}' || echo "Agent N/A")
    
    printf "%-6s %-5s %-20s %-8s %-12s %-12s %s\n" \
        "VM" "$vm_id" "$VM_NAME" "$VM_CPU" "${VM_USED_MB} MB" "${VM_MAX_MB:-No limit} MB" "${VM_TOP_PROC:-Agent N/A}"
done

printf "=================================\n"
printf "Report finished.\n"