#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Treat unset variables as an error
set -u

# Cause a pipeline to return the exit status of the last command in the pipe that failed
set -o pipefail

# Trap errors and clean up if necessary
trap 'log "ERROR" "An unexpected error occurred. Exiting." && exit 1' ERR

# Define variables
LOG_FILE="/var/log/adr_setup.log"
ADR_DIR="/usr/local/bin/adr"
ADR_REPO="https://github.com/npryce/adr-tools.git"
echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"

# Logging function for structured log messages
log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message"
}

# Function to check if a required command exists
check_command() {
    if ! command -v "$1" &>/dev/null; then
        log "ERROR" "Required command '$1' not found. Please install it and try again."
        exit 1
    fi
}

# Check required commands
check_command "git"
check_command "sudo"

# Function to create the ADR tools directory if it doesn't exist
create_directory() {
    if [ ! -d "$ADR_DIR" ]; then
        log "INFO" "Creating directory $ADR_DIR"
        if sudo mkdir -p "$ADR_DIR"; then
            log "INFO" "Directory $ADR_DIR created successfully."
        else
            log "ERROR" "Failed to create directory $ADR_DIR"
            exit 1
        fi
    else
        log "INFO" "Directory $ADR_DIR already exists"
    fi
}

# Function to clone the ADR tools repository if not already cloned
clone_repository() {
    if [ ! -d "$ADR_DIR/.git" ]; then
        log "INFO" "Cloning ADR tools repository into $ADR_DIR"
        if sudo git clone "$ADR_REPO" "$ADR_DIR"; then
            log "INFO" "Repository cloned successfully from $ADR_REPO"
        else
            log "ERROR" "Failed to clone repository from $ADR_REPO"
            exit 1
        fi
    else
        log "INFO" "ADR tools repository already cloned"
    fi
}

# Function to make the ADR tools script executable if not already executable
make_script_executable() {
    if [ ! -x "$ADR_SCRIPT" ]; then
        log "INFO" "Making ADR script executable"
        if sudo chmod +x "$ADR_SCRIPT"; then
            log "INFO" "ADR script made executable successfully."
        else
            log "ERROR" "Failed to make $ADR_SCRIPT executable"
            exit 1
        fi
    else
        log "INFO" "ADR script is already executable"
    fi
}

# Main script execution
log "INFO" "Starting ADR tools setup..."
create_directory
clone_repository
make_script_executable

log "INFO" "ADR tools setup completed successfully."
