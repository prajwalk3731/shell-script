```bash
#!/bin/bash

###############################################################################
# EC2 SYSTEM MONITORING SCRIPT
#
# Monitors:
#   - CPU usage
#   - Memory usage
#   - Disk usage
#   - System load
#   - Running processes
#   - System uptime
#
# Demonstrates:
#   - Variables
#   - Conditions
#   - Functions
#   - Loops
#   - Exit status
#   - Colors
#   - Logging
###############################################################################


############################
# VARIABLES
############################

LOG_DIR="/var/log/devops"
LOG_FILE="$LOG_DIR/system-monitor.log"

DISK_THRESHOLD=80
MEMORY_THRESHOLD=80
CPU_THRESHOLD=80


############################
# COLORS
############################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'


############################
# LOG FUNCTION
############################

log() {

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    echo "$TIMESTAMP - $1" | tee -a "$LOG_FILE"
}


############################
# SUCCESS FUNCTION
############################

success() {

    echo -e "${GREEN}[OK] $1${NC}"

    log "[OK] $1"
}


############################
# WARNING FUNCTION
############################

warning() {

    echo -e "${YELLOW}[WARNING] $1${NC}"

    log "[WARNING] $1"
}


############################
# ERROR FUNCTION
############################

error() {

    echo -e "${RED}[ERROR] $1${NC}"

    log "[ERROR] $1"
}


############################
# ROOT USER CHECK
############################

check_root() {

    USER_ID=$(id -u)

    if [ "$USER_ID" -ne 0 ]
    then

        echo -e "${RED}ERROR: Please run this script as root${NC}"

        exit 1

    else

        success "Running as root user"

    fi
}


############################
# CREATE LOG DIRECTORY
############################

create_log_directory() {

    if [ ! -d "$LOG_DIR" ]
    then

        mkdir -p "$LOG_DIR"

        if [ $? -eq 0 ]
        then
            success "Log directory created"
        else
            error "Failed to create log directory"
            exit 1
        fi

    else

        success "Log directory already exists"

    fi
}


############################
# CHECK CPU
############################

check_cpu() {

    echo
    echo "========== CPU MONITORING =========="

    CPU_USAGE=$(top -bn1 | awk '/Cpu\(s\)/ {print 100 - $8}')

    CPU_USAGE=${CPU_USAGE%.*}

    echo "CPU Usage: ${CPU_USAGE}%"

    if [ "$CPU_USAGE" -ge "$CPU_THRESHOLD" ]
    then

        warning "CPU usage is HIGH: ${CPU_USAGE}%"

    else

        success "CPU usage is normal: ${CPU_USAGE}%"

    fi

    echo "===================================="

    log "CPU Usage: ${CPU_USAGE}%"
}


############################
# CHECK MEMORY
############################

check_memory() {

    echo
    echo "========== MEMORY MONITORING =========="

    MEMORY_USAGE=$(free | awk '/Mem:/ {printf "%.0f", ($3/$2)*100}')

    echo "Memory Usage: ${MEMORY_USAGE}%"

    if [ "$MEMORY_USAGE" -ge "$MEMORY_THRESHOLD" ]
    then

        warning "Memory usage is HIGH: ${MEMORY_USAGE}%"

    else

        success "Memory usage is normal: ${MEMORY_USAGE}%"

    fi

    echo "======================================="

    log "Memory Usage: ${MEMORY_USAGE}%"
}


############################
# CHECK DISK
############################

check_disk() {

    echo
    echo "========== DISK MONITORING =========="

    df -h

    echo
    echo "Disk usage alert threshold: ${DISK_THRESHOLD}%"

    df -P | awk 'NR>1 {print $5,$6}' | while read USAGE MOUNT
    do

        USAGE=${USAGE%\%}

        if [ "$USAGE" -ge "$DISK_THRESHOLD" ]
        then

            warning "$MOUNT is ${USAGE}% full"

        else

            success "$MOUNT is ${USAGE}% full"

        fi

    done

    echo "====================================="

    log "Disk monitoring completed"
}


############################
# CHECK LOAD
############################

check_load() {

    echo
    echo "========== SYSTEM LOAD =========="

    LOAD=$(uptime | awk -F'load average:' '{print $2}')

    echo "Load Average:$LOAD"

    log "Load Average:$LOAD"

    echo "================================="
}


############################
# CHECK UPTIME
############################

check_uptime() {

    echo
    echo "========== SYSTEM UPTIME =========="

    UPTIME=$(uptime -p)

    echo "$UPTIME"

    log "System Uptime: $UPTIME"

    echo "==================================="

}


############################
# CHECK PROCESSES
############################

check_processes() {

    echo
    echo "========== TOP PROCESSES =========="

    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -11

    echo "==================================="

    log "Top processes checked"

}


############################
# MAIN FUNCTION
############################

main() {

    create_log_directory

    check_root

    log "=========================================="
    log "EC2 monitoring started"
    log "=========================================="

    check_cpu

    check_memory

    check_disk

    check_load

    check_uptime

    check_processes

    log "=========================================="
    log "EC2 monitoring completed"
    log "=========================================="

}


############################
# EXECUTE MAIN FUNCTION
############################

main

exit 0
```
