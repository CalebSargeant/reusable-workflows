#!/bin/bash

# Auto-Update One-Liner Installer
# Inspired by Pi-hole, k3s, and other popular one-liner installers
# 
# Usage examples:
#   curl -sSL https://raw.githubusercontent.com/calebsargeant/reusable-workflows/main/install-auto-update.sh | bash -s -- --slack-token xoxb-your-token --slack-channel C1234567890
#   curl -sSL https://raw.githubusercontent.com/calebsargeant/reusable-workflows/main/install-auto-update.sh | bash -s -- --slack-token xoxb-your-token --slack-channel C1234567890 --github-repo myorg/myrepo --server-name my-server --enable-reboot-button
#
# Author: Caleb Sargeant
# Repository: https://github.com/calebsargeant/reusable-workflows
# Created: 2025-10-01

set -euo pipefail

# ASCII Art Banner (like Pi-hole!)
show_banner() {
    cat << 'EOF'
     ___         _           _   _           _       _       
    / _ \       | |         | | | |         | |     | |      
   / /_\ \_   _ | |_  ___   | | | | _ __   __| | __ _| |_  ___ 
   |  _  | | | || __|/ _ \  | | | || '_ \ / _` |/ _` | __|/ _ \
   | | | | |_| || |_| (_) | | |_| || |_) | (_| | (_| | |_|  __/
   \_| |_/\__,_| \__|\___/   \___/ | .__/ \__,_|\__,_|\__|\___|
                                  | |                        
                                  |_|                        
                                  
   Slack-Enabled Server Auto-Update System
   https://github.com/calebsargeant/reusable-workflows
   
EOF
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

step() {
    echo -e "${PURPLE}[STEP]${NC} $*"
}

# Default configuration
SLACK_TOKEN=""
SLACK_CHANNEL=""
GITHUB_REPO="calebsargeant/infra"
SERVER_NAME="$(hostname)"
ENABLE_REBOOT_BUTTON="false"
SCHEDULE_TIME="03:00:00"
RANDOMIZED_DELAY="3600"
FORCE_INSTALL="false"
DRY_RUN="false"

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --slack-token)
                SLACK_TOKEN="$2"
                shift 2
                ;;
            --slack-channel)
                SLACK_CHANNEL="$2"
                shift 2
                ;;
            --github-repo)
                GITHUB_REPO="$2"
                shift 2
                ;;
            --server-name)
                SERVER_NAME="$2"
                shift 2
                ;;
            --enable-reboot-button)
                ENABLE_REBOOT_BUTTON="true"
                shift
                ;;
            --schedule-time)
                SCHEDULE_TIME="$2"
                shift 2
                ;;
            --randomized-delay)
                RANDOMIZED_DELAY="$2"
                shift 2
                ;;
            --force)
                FORCE_INSTALL="true"
                shift
                ;;
            --dry-run)
                DRY_RUN="true"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Show help
show_help() {
    cat << 'EOF'
Usage: curl -sSL https://raw.githubusercontent.com/calebsargeant/reusable-workflows/main/install-auto-update.sh | bash -s -- [OPTIONS]

Required Options:
  --slack-token TOKEN       Slack bot token (starts with xoxb-)
  --slack-channel ID        Slack channel ID (starts with C)

Optional Options:
  --github-repo REPO        GitHub repository for notifications (default: calebsargeant/infra)
  --server-name NAME        Server name for notifications (default: hostname)
  --enable-reboot-button    Enable interactive reboot buttons in Slack
  --schedule-time TIME      Update schedule time in HH:MM:SS format (default: 03:00:00)
  --randomized-delay SEC    Random delay in seconds (default: 3600 = 1 hour)
  --force                   Force installation even if already installed
  --dry-run                 Show what would be done without making changes
  --help, -h                Show this help message

Examples:
  # Basic installation
  curl -sSL https://raw.githubusercontent.com/calebsargeant/reusable-workflows/main/install-auto-update.sh | bash -s -- --slack-token xoxb-your-token --slack-channel C1234567890

  # Full customization
  curl -sSL https://raw.githubusercontent.com/calebsargeant/reusable-workflows/main/install-auto-update.sh | bash -s -- \
    --slack-token xoxb-your-token \
    --slack-channel C1234567890 \
    --github-repo myorg/myrepo \
    --server-name my-production-server \
    --enable-reboot-button \
    --schedule-time "02:30:00" \
    --randomized-delay 1800

  # Dry run to see what would happen
  curl -sSL https://raw.githubusercontent.com/calebsargeant/reusable-workflows/main/install-auto-update.sh | bash -s -- --slack-token xoxb-test --slack-channel C-test --dry-run

EOF
}

# Validate required parameters
validate_args() {
    if [[ -z "$SLACK_TOKEN" ]]; then
        error "Slack token is required. Use --slack-token parameter."
        error "Example: --slack-token xoxb-1234567890-abcdefghijk"
        exit 1
    fi

    if [[ -z "$SLACK_CHANNEL" ]]; then
        error "Slack channel ID is required. Use --slack-channel parameter."
        error "Example: --slack-channel C1234567890"
        exit 1
    fi

    # Validate token format
    if [[ ! "$SLACK_TOKEN" =~ ^xoxb- ]]; then
        error "Invalid Slack token format. Token should start with 'xoxb-'"
        exit 1
    fi

    # Validate channel format
    if [[ ! "$SLACK_CHANNEL" =~ ^C[0-9A-Z]+ ]]; then
        error "Invalid Slack channel ID format. Channel ID should start with 'C'"
        exit 1
    fi
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 && "$DRY_RUN" != "true" ]]; then
        error "This script must be run as root (use sudo)"
        error "Try: curl -sSL https://raw.githubusercontent.com/calebsargeant/reusable-workflows/main/install-auto-update.sh | sudo bash -s -- --slack-token $SLACK_TOKEN --slack-channel $SLACK_CHANNEL"
        exit 1
    fi
}

# Detect OS and package manager
detect_os() {
    if [[ -f /etc/debian_version ]]; then
        OS="debian"
        PKG_MANAGER="apt"
    elif [[ -f /etc/redhat-release ]]; then
        OS="rhel"
        PKG_MANAGER="yum"
    elif [[ -f /etc/arch-release ]]; then
        OS="arch"
        PKG_MANAGER="pacman"
    else
        error "Unsupported operating system. This installer supports Debian/Ubuntu, RHEL/CentOS/Fedora, and Arch Linux."
        exit 1
    fi
    
    info "Detected OS: $OS"
}

# Check if already installed
check_existing_installation() {
    if [[ -f /usr/local/bin/auto-update-slack.sh && "$FORCE_INSTALL" != "true" ]]; then
        warning "Auto-update system appears to already be installed."
        warning "Use --force to reinstall, or remove existing installation first."
        exit 1
    fi
}

# Install dependencies
install_dependencies() {
    step "Installing dependencies..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would install: curl, jq, systemd"
        return
    fi

    case $PKG_MANAGER in
        apt)
            apt-get update -qq
            apt-get install -y curl jq systemd
            ;;
        yum)
            yum install -y curl jq systemd
            ;;
        pacman)
            pacman -Sy --noconfirm curl jq systemd
            ;;
    esac
    
    success "Dependencies installed"
}

# Create the auto-update script
create_update_script() {
    step "Creating auto-update script..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would create: /usr/local/bin/auto-update-slack.sh"
        return
    fi

    cat > /usr/local/bin/auto-update-slack.sh << 'SCRIPT_EOF'
#!/bin/bash

# Auto-Update Script with Slack Notifications
# Generated by: https://raw.githubusercontent.com/calebsargeant/reusable-workflows/main/install-auto-update.sh

set -euo pipefail

# Configuration from environment file
if [[ -f /etc/default/auto-update ]]; then
    source /etc/default/auto-update
fi

# Default values
LOG_FILE="/var/log/auto-update.log"
LOCK_FILE="/var/run/auto-update.lock"
GITHUB_REPO="${GITHUB_REPO:-calebsargeant/infra}"
SERVER_NAME="${SERVER_NAME:-$(hostname)}"
ENABLE_REBOOT_BUTTON="${ENABLE_REBOOT_BUTTON:-false}"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Cleanup function
cleanup() {
    if [[ -f "$LOCK_FILE" ]]; then
        rm -f "$LOCK_FILE"
    fi
}

# Set trap for cleanup
trap cleanup EXIT

# Check if already running
if [[ -f "$LOCK_FILE" ]]; then
    log "ERROR: Auto-update already running (lock file exists)"
    exit 1
fi

# Create lock file
echo $$ > "$LOCK_FILE"

# Function to send notification via GitHub API
send_notification() {
    local status="$1"
    local message="$2"
    local uptime="${3:-}"
    local packages_updated="${4:-}"
    local error_details="${5:-}"
    
    local github_api_url="https://api.github.com/repos/${GITHUB_REPO}/dispatches"
    
    local payload
    payload=$(cat <<EOF
{
  "event_type": "server-update",
  "client_payload": {
    "server_name": "$SERVER_NAME",
    "status": "$status",
    "message": "$message",
    "uptime": "$uptime",
    "packages_updated": "$packages_updated",
    "error_details": "$error_details",
    "enable_reboot_button": $ENABLE_REBOOT_BUTTON
  }
}
EOF
    )
    
    log "Sending notification: status=$status, server=$SERVER_NAME"
    
    if response=$(curl -s -w "\n%{http_code}" -X POST "$github_api_url" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$payload" 2>&1); then
        
        http_code=$(echo "$response" | tail -n1)
        response_body=$(echo "$response" | sed '$d')
        
        if [[ "$http_code" == "204" ]]; then
            log "Notification sent successfully"
            return 0
        else
            log "ERROR: GitHub API returned status $http_code"
            log "ERROR: Response: $response_body"
            return 1
        fi
    else
        log "ERROR: Failed to send notification to GitHub Actions: $response"
        return 1
    fi
}

# Function to check if reboot is required
check_reboot_required() {
    if [[ -f /var/run/reboot-required ]]; then
        return 0  # Reboot required
    fi
    
    # Additional checks for kernel updates
    if command -v dpkg &> /dev/null; then
        if dpkg -l | grep -q "^ii.*linux-image-$(uname -r)"; then
            local current_kernel newest_kernel
            current_kernel=$(uname -r)
            newest_kernel=$(dpkg -l | grep "^ii.*linux-image-" | sort -V | tail -1 | awk '{print $2}' | sed 's/linux-image-//')
            
            if [[ "$current_kernel" != "$newest_kernel" ]]; then
                return 0  # Kernel update requires reboot
            fi
        fi
    fi
    
    return 1  # No reboot required
}

# Check system load
check_system_load() {
    local load_avg cpu_count load_threshold
    load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    cpu_count=$(nproc)
    load_threshold=$(echo "$cpu_count * 1.5" | bc 2>/dev/null || echo "4")
    
    if (( $(echo "$load_avg > $load_threshold" | bc -l 2>/dev/null || echo "0") )); then
        log "System load too high ($load_avg > $load_threshold). Skipping updates."
        return 1
    fi
    return 0
}

# Determine package manager and update commands
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        UPDATE_CMD="apt-get update"
        UPGRADE_CMD="apt-get -y upgrade --auto-remove --purge"
        PKG_COUNT_CMD="grep -c '^Setting up\|^Unpacking'"
    elif command -v yum &> /dev/null; then
        UPDATE_CMD="yum check-update || true"
        UPGRADE_CMD="yum -y update"
        PKG_COUNT_CMD="grep -c 'Updated:\|Installed:'"
    elif command -v pacman &> /dev/null; then
        UPDATE_CMD="pacman -Sy"
        UPGRADE_CMD="pacman -Su --noconfirm"
        PKG_COUNT_CMD="grep -c 'upgrading\|installing'"
    else
        log "ERROR: No supported package manager found (apt-get, yum, or pacman)"
        exit 1
    fi
}

# Main update process
main() {
    log "=== Starting auto-update process ==="
    log "Server: $SERVER_NAME"
    log "Repository: $GITHUB_REPO"
    log "Enable Reboot Button: $ENABLE_REBOOT_BUTTON"
    
    # Check system load
    if ! check_system_load; then
        send_notification "skipped" "Updates skipped due to high system load" "$(uptime -p 2>/dev/null || uptime)"
        exit 0
    fi
    
    # Detect package manager
    detect_package_manager
    
    # Set environment variables for non-interactive installation
    export DEBIAN_FRONTEND=noninteractive
    export NEEDRESTART_MODE=a
    
    log "Updating package lists..."
    if ! eval "$UPDATE_CMD" &>> "$LOG_FILE"; then
        send_notification "failed" "Failed to update package lists" "$(uptime -p 2>/dev/null || uptime)" "" "Package list update failed"
        exit 1
    fi
    
    log "Upgrading packages..."
    local upgrade_output
    upgrade_output=$(mktemp)
    
    if eval "$UPGRADE_CMD" 2>&1 | tee "$upgrade_output" >> "$LOG_FILE"; then
        # Count upgraded packages
        local packages_count
        packages_count=$(eval "$PKG_COUNT_CMD" "$upgrade_output" 2>/dev/null || echo "0")
        
        log "Updates completed successfully. $packages_count packages processed."
        
        # Check if reboot is required
        if check_reboot_required; then
            log "Reboot required detected"
            local reboot_packages="System updates applied"
            if [[ -f /var/run/reboot-required.pkgs ]]; then
                reboot_packages=$(cat /var/run/reboot-required.pkgs | tr '\n' ' ')
            fi
            
            send_notification "reboot_required" \
                "Updates completed successfully. Packages requiring reboot: $reboot_packages" \
                "$(uptime -p 2>/dev/null || uptime)" \
                "$packages_count"
        else
            log "No reboot required"
            send_notification "success" \
                "All updates applied successfully. System is ready for use." \
                "$(uptime -p 2>/dev/null || uptime)" \
                "$packages_count"
        fi
    else
        log "ERROR: Package upgrade failed"
        local error_msg
        error_msg=$(tail -20 "$upgrade_output" | tr '\n' ' ')
        send_notification "failed" \
            "Package upgrade process failed" \
            "$(uptime -p 2>/dev/null || uptime)" \
            "" \
            "$error_msg"
        exit 1
    fi
    
    # Cleanup
    rm -f "$upgrade_output"
    
    log "Auto-update process completed successfully"
    log "=== End of auto-update process ==="
}

# Run main function
main "$@"
SCRIPT_EOF

    chmod +x /usr/local/bin/auto-update-slack.sh
    success "Auto-update script created at /usr/local/bin/auto-update-slack.sh"
}

# Create configuration file
create_config_file() {
    step "Creating configuration file..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would create: /etc/default/auto-update"
        info "[DRY RUN] Would contain: GITHUB_TOKEN, GITHUB_REPO, SERVER_NAME, ENABLE_REBOOT_BUTTON"
        return
    fi

    # Create GitHub token (this would need to be provided separately for security)
    cat > /etc/default/auto-update << EOF
# Auto-update configuration
# Created by: https://raw.githubusercontent.com/calebsargeant/reusable-workflows/main/install-auto-update.sh

# GitHub repository for notifications
GITHUB_REPO="$GITHUB_REPO"

# Server identification
SERVER_NAME="$SERVER_NAME"

# Slack integration (via GitHub Actions)
# Note: GITHUB_TOKEN must be set manually after installation
# GITHUB_TOKEN="ghp_your_personal_access_token_here"

# Interactive features
ENABLE_REBOOT_BUTTON="$ENABLE_REBOOT_BUTTON"

# Slack credentials for reference (stored in GitHub repo secrets)
# SLACK_TOKEN="$SLACK_TOKEN"
# SLACK_CHANNEL="$SLACK_CHANNEL"
EOF

    chmod 600 /etc/default/auto-update
    success "Configuration file created at /etc/default/auto-update"
    warning "You'll need to manually add your GitHub Personal Access Token to /etc/default/auto-update"
}

# Create systemd service
create_systemd_service() {
    step "Creating systemd service..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would create: /etc/systemd/system/auto-update-slack.service"
        return
    fi

    # Determine appropriate ReadWritePaths based on OS
    local readwrite_paths="/var/log /var/run /tmp"
    case $PKG_MANAGER in
        apt)
            readwrite_paths+=" /var/lib/apt /var/cache/apt /etc/apt"
            ;;
        yum)
            readwrite_paths+=" /var/lib/rpm /var/cache/yum"
            ;;
        pacman)
            readwrite_paths+=" /var/cache/pacman /var/lib/pacman"
            ;;
    esac

    cat > /etc/systemd/system/auto-update-slack.service << EOF
[Unit]
Description=Auto-update system with Slack notifications
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
EnvironmentFile=/etc/default/auto-update
ExecStart=/usr/local/bin/auto-update-slack.sh
User=root
Group=root

# Security settings
NoNewPrivileges=true
ProtectSystem=strict
ReadWritePaths=$readwrite_paths
ProtectHome=true
PrivateTmp=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true

# Timeout settings
TimeoutStartSec=3600
TimeoutStopSec=60

[Install]
WantedBy=multi-user.target
EOF

    success "Systemd service created"
}

# Create systemd timer
create_systemd_timer() {
    step "Creating systemd timer..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would create: /etc/systemd/system/auto-update-slack.timer"
        info "[DRY RUN] Schedule: $SCHEDULE_TIME with ${RANDOMIZED_DELAY}s randomization"
        return
    fi

    cat > /etc/systemd/system/auto-update-slack.timer << EOF
[Unit]
Description=Auto-update timer with Slack notifications
Requires=auto-update-slack.service

[Timer]
OnCalendar=*-*-* $SCHEDULE_TIME
RandomizedDelaySec=$RANDOMIZED_DELAY
Persistent=true

[Install]
WantedBy=timers.target
EOF

    success "Systemd timer created (runs at $SCHEDULE_TIME ± ${RANDOMIZED_DELAY}s)"
}

# Test the installation
test_installation() {
    step "Testing installation..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would test script execution and GitHub API connectivity"
        return
    fi

    # Test GitHub API connectivity (if token is provided)
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        if curl -s -f \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/$GITHUB_REPO" > /dev/null 2>&1; then
            success "GitHub API connectivity test passed"
        else
            warning "GitHub API connectivity test failed. Make sure to add GITHUB_TOKEN to /etc/default/auto-update"
        fi
    else
        warning "Skipping GitHub API test (no token provided). Add GITHUB_TOKEN to /etc/default/auto-update"
    fi

    # Test script syntax
    if bash -n /usr/local/bin/auto-update-slack.sh; then
        success "Script syntax test passed"
    else
        error "Script syntax test failed"
        exit 1
    fi
}

# Enable and start services
enable_services() {
    step "Enabling systemd services..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would enable and start auto-update-slack.timer"
        return
    fi

    systemctl daemon-reload
    systemctl enable auto-update-slack.timer
    systemctl start auto-update-slack.timer
    
    success "Services enabled and started"
}

# Show final status and instructions
show_completion() {
    echo
    success "🎉 Auto-Update System Installation Complete!"
    echo
    echo -e "${CYAN}┌─ Configuration Summary ─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} Server Name: $SERVER_NAME"
    echo -e "${CYAN}│${NC} GitHub Repo: $GITHUB_REPO"
    echo -e "${CYAN}│${NC} Schedule: $SCHEDULE_TIME (±${RANDOMIZED_DELAY}s randomization)"
    echo -e "${CYAN}│${NC} Reboot Button: $ENABLE_REBOOT_BUTTON"
    echo -e "${CYAN}│${NC} Slack Channel: $SLACK_CHANNEL"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────┘${NC}"
    echo
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "This was a dry run. No changes were made to your system."
        return
    fi

    echo -e "${YELLOW}⚠️  Required Manual Steps:${NC}"
    echo "1. Create a GitHub Personal Access Token with 'repo' scope:"
    echo "   https://github.com/settings/tokens"
    echo
    echo "2. Add the token to the configuration file:"
    echo "   sudo nano /etc/default/auto-update"
    echo "   # Uncomment and set: GITHUB_TOKEN=\"ghp_your_token_here\""
    echo
    echo "3. Add these secrets to your GitHub repository ($GITHUB_REPO):"
    echo "   SLACK_BOT_TOKEN: $SLACK_TOKEN"
    echo "   SLACK_CHANNEL_ID: $SLACK_CHANNEL"
    echo
    echo -e "${GREEN}✅ Useful Commands:${NC}"
    echo "  Check timer status:    systemctl status auto-update-slack.timer"
    echo "  View next run time:    systemctl list-timers auto-update-slack.timer"
    echo "  Manual update:         sudo systemctl start auto-update-slack.service"
    echo "  View logs:            sudo journalctl -u auto-update-slack.service -f"
    echo "  Check update log:     sudo tail -f /var/log/auto-update.log"
    echo
    echo -e "${PURPLE}🔗 Repository:${NC} https://github.com/calebsargeant/reusable-workflows"
    echo
}

# Main installation flow
main() {
    show_banner
    parse_args "$@"
    validate_args
    check_root
    detect_os
    check_existing_installation
    
    info "Starting installation with the following configuration:"
    info "  Server: $SERVER_NAME"
    info "  GitHub Repo: $GITHUB_REPO"
    info "  Slack Channel: $SLACK_CHANNEL"
    info "  Schedule: $SCHEDULE_TIME (±${RANDOMIZED_DELAY}s)"
    info "  Reboot Button: $ENABLE_REBOOT_BUTTON"
    info "  Dry Run: $DRY_RUN"
    echo
    
    install_dependencies
    create_update_script
    create_config_file
    create_systemd_service
    create_systemd_timer
    test_installation
    enable_services
    show_completion
}

# Run the installer
main "$@"