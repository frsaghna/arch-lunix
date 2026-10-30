#!/usr/bin/env bash
# ==============================================================================
# Arch Linux + Hyprland Dotfiles Installer
# Compatible with Fresh / Raw Arch Linux Installations
# Includes Automated Dependency Detection & Intelligent Error Diagnosis
# ==============================================================================

set -uo pipefail

# ANSI Styling
BOLD="\033[1m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
CYAN="\033[1;36m"
DIM="\033[2m"
NC="\033[0m"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/arch-lunix-install-$(date +%Y%m%d_%H%M%S).log"
TEMP_PACMAN_ERR="/tmp/arch-lunix-pacman-err.log"

AUTO_YES=false
DRY_RUN=false
CHECK_ONLY=false

# ------------------------------------------------------------------------------
# Argument Parsing
# ------------------------------------------------------------------------------
for arg in "$@"; do
    case "$arg" in
        -y|--yes|--noconfirm)
            AUTO_YES=true
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --check-only)
            CHECK_ONLY=true
            ;;
        -h|--help)
            echo -e "${BOLD}Usage:${NC} $0 [options]"
            echo ""
            echo "Options:"
            echo "  -y, --yes, --noconfirm  Automatically install dependencies without prompting"
            echo "  --check-only            Run diagnostic check on dependencies and exit"
            echo "  --dry-run               Simulate configuration linking without modifying files"
            echo "  -h, --help              Show this help message"
            exit 0
            ;;
    esac
done

# ------------------------------------------------------------------------------
# Logging Helpers
# ------------------------------------------------------------------------------
log_info() {
    echo -e "${BLUE}${BOLD}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}${BOLD}[OK]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}${BOLD}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}${BOLD}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_step() {
    echo -e "\n${CYAN}${BOLD}==>${NC} ${BOLD}$1${NC}" | tee -a "$LOG_FILE"
}

# ------------------------------------------------------------------------------
# Pre-Flight Checks
# ------------------------------------------------------------------------------
preflight_checks() {
    log_step "Running Pre-Flight System Checks"

    # 1. Check OS distribution
    if [[ ! -f /etc/arch-release ]] && ! grep -qi "arch" /etc/os-release 2>/dev/null; then
        log_error "This script is tailored specifically for Arch Linux (or Arch-based systems)."
        log_error "Aborting installation to prevent package manager collisions."
        exit 1
    fi
    log_success "Arch Linux environment confirmed."

    # 2. Prevent running directly as root
    if [[ $EUID -eq 0 ]]; then
        log_error "Do not run this installer directly as root."
        log_error "Run as normal user; sudo will be invoked when elevated privileges are required."
        exit 1
    fi
    log_success "Running as non-root user (${USER})."

    # 3. Check sudo access (only if not in check-only mode)
    if [[ "$CHECK_ONLY" == false ]]; then
        if ! command -v sudo >/dev/null 2>&1; then
            log_error "'sudo' is not installed. Please install sudo and grant permissions before proceeding."
            exit 1
        fi
        if ! sudo -n true 2>/dev/null; then
            log_info "Sudo privileges required for package management. Sudo will be prompted when installing."
        else
            log_success "Sudo credentials active."
        fi
    fi

    # 4. Check pacman database lock
    if [[ -f /var/lib/pacman/db.lck ]]; then
        log_error "Pacman database is currently locked (/var/lib/pacman/db.lck exists)."
        log_error "Another package management process might be running."
        echo -n "Would you like to remove the lockfile if no pacman process is active? [y/N]: "
        read -r remove_lock
        if [[ "$remove_lock" =~ ^[Yy]$ ]]; then
            if pgrep -x "pacman" >/dev/null; then
                log_error "An active pacman process was detected. Please wait for it to complete."
                exit 1
            else
                sudo rm -f /var/lib/pacman/db.lck
                log_success "Removed stale /var/lib/pacman/db.lck."
            fi
        else
            exit 1
        fi
    fi

    # 5. Check internet connectivity
    if ! ping -c 1 -W 3 1.1.1.1 >/dev/null 2>&1 && ! ping -c 1 -W 3 archlinux.org >/dev/null 2>&1; then
        log_warn "No active internet connection detected. Dependency installation might fail if packages are not cached."
    else
        log_success "Internet connectivity active."
    fi
}

# ------------------------------------------------------------------------------
# Dependency Database
# ------------------------------------------------------------------------------
declare -A DEPS_MAP=(
    # Compositor & Portal
    ["hyprland"]="Core Wayland dynamic tiling compositor"
    ["xdg-desktop-portal-hyprland"]="Wayland desktop portal backend for Hyprland"
    ["xdg-desktop-portal-gtk"]="Fallback desktop portal backend for GTK"
    ["qt5-wayland"]="Qt5 Wayland platform integration"
    ["qt6-wayland"]="Qt6 Wayland platform integration"
    ["polkit-kde-agent"]="Polkit graphical authentication agent"

    # Terminal & Core Apps
    ["kitty"]="GPU-accelerated terminal emulator"
    ["nemo"]="Modern, lightweight GUI file manager"
    ["firefox"]="Web browser"
    ["starship"]="Ultra-fast, cross-shell prompt"

    # Clipboard & Automation System
    ["wl-clipboard"]="Wayland clipboard CLI tools (wl-copy, wl-paste)"
    ["wtype"]="Wayland virtual keystroke injection utility"
    ["jq"]="Lightweight and flexible command-line JSON processor"
    ["perl"]="Perl interpreter (used for UTF-16/8 clipboard sanitization)"
    ["util-linux"]="System utilities providing flock and setpriv"
    ["coreutils"]="Standard GNU core utilities"

    # Launcher & Menus
    ["wofi"]="Wayland application launcher and dmenu alternative"

    # Audio & Hardware Controls
    ["pipewire"]="Low-latency multimedia server"
    ["wireplumber"]="Modular session manager for PipeWire (wpctl)"
    ["pipewire-audio"]="PipeWire audio client libraries"
    ["pipewire-pulse"]="PipeWire PulseAudio drop-in replacement"
    ["brightnessctl"]="Screen backlight & brightness controller"
    ["playerctl"]="MPRIS media player controller"

    # Theming, Icons, Fonts & Schemas
    ["ttf-jetbrains-mono-nerd"]="Primary patched monospace & icon nerd font"
    ["noto-fonts-emoji"]="Google Noto color emoji font"
    ["papirus-icon-theme"]="Papirus dark icon theme"
    ["adwaita-icon-theme"]="Adwaita cursor and base icon theme"
    ["gsettings-desktop-schemas"]="GSettings desktop configuration schemas"
    ["dconf"]="Backend configuration storage system"
    ["xdg-utils"]="Desktop integration tools (xdg-mime)"
)

# ------------------------------------------------------------------------------
# Dependency Diagnosis & Error Recognition Engine
# ------------------------------------------------------------------------------
check_and_install_dependencies() {
    log_step "Analyzing System Dependencies for Raw Arch"

    local installed=()
    local missing=()

    # Sort packages alphabetically for clean output
    IFS=$'\n' sorted_pkgs=($(sort <<<"${!DEPS_MAP[*]}"))
    unset IFS

    for pkg in "${sorted_pkgs[@]}"; do
        if pacman -Q "$pkg" >/dev/null 2>&1; then
            installed+=("$pkg")
        else
            missing+=("$pkg")
        fi
    done

    echo -e "\n${BOLD}Package Status Overview:${NC}"
    echo -e "  Total Required Dependencies : ${#DEPS_MAP[@]}"
    echo -e "  Already Installed           : ${GREEN}${#installed[@]}${NC}"
    echo -e "  Missing Dependencies        : ${RED}${#missing[@]}${NC}\n"

    if [[ ${#missing[@]} -eq 0 ]]; then
        log_success "All system dependencies are currently satisfied!"
        return 0
    fi

    echo -e "${YELLOW}${BOLD}Missing Packages Detected:${NC}"
    for pkg in "${missing[@]}"; do
        printf "  • %-28s ${DIM}%s${NC}\n" "$pkg" "${DEPS_MAP[$pkg]}"
    done
    echo ""

    if [[ "$CHECK_ONLY" == true ]]; then
        log_info "--check-only specified. Exiting after diagnostic."
        exit 0
    fi

    local do_install=false
    if [[ "$AUTO_YES" == true ]]; then
        do_install=true
    else
        echo -n -e "${BOLD}Would you like to install the ${#missing[@]} missing packages now? [Y/n]: ${NC}"
        read -r reply
        if [[ -z "$reply" || "$reply" =~ ^[Yy]$ ]]; then
            do_install=true
        fi
    fi

    if [[ "$do_install" != true ]]; then
        log_warn "Skipping dependency installation. Note that some dotfiles features may not work."
        return 0
    fi

    log_step "Installing Missing Dependencies via Pacman"

    # Attempt primary bulk transaction
    if sudo pacman -S --needed --noconfirm "${missing[@]}" 2>"$TEMP_PACMAN_ERR"; then
        log_success "All missing packages were installed successfully!"
        rm -f "$TEMP_PACMAN_ERR"
        return 0
    fi

    # --------------------------------------------------------------------------
    # Dependency Error Recognition & Diagnostic Pattern Analyzer
    # --------------------------------------------------------------------------
    log_error "Pacman bulk installation encountered an error!"
    echo -e "\n${RED}${BOLD}==================== DEPENDENCY ERROR DIAGNOSIS ====================${NC}"

    local err_content
    err_content=$(cat "$TEMP_PACMAN_ERR" 2>/dev/null || echo "")

    local recognized=false

    # Error Pattern 1: PGP / Keyring Corrupt or Out of date
    if grep -E -q "invalid or corrupted package|PGP signature|unknown trust|key .* could not be looked up" <<<"$err_content"; then
        recognized=true
        echo -e "${YELLOW}${BOLD}DIAGNOSIS: Arch Linux Keyring Out of Date / Signature Verification Failed${NC}"
        echo -e "Explanation : Pacman rejected packages because local GPG verification keys are stale."
        echo -e "Remediation : Update the archlinux keyring first, then retry:"
        echo -e "              ${CYAN}sudo pacman -Sy --noconfirm archlinux-keyring${NC}\n"

        echo -n -e "Attempt automatic keyring update and retry? [Y/n]: "
        read -r key_retry
        if [[ -z "$key_retry" || "$key_retry" =~ ^[Yy]$ ]]; then
            log_info "Updating archlinux-keyring..."
            if sudo pacman -Sy --noconfirm archlinux-keyring; then
                log_success "Keyring updated. Retrying dependency installation..."
                if sudo pacman -S --needed --noconfirm "${missing[@]}"; then
                    log_success "Installation succeeded after keyring refresh!"
                    rm -f "$TEMP_PACMAN_ERR"
                    return 0
                fi
            fi
        fi
    fi

    # Error Pattern 2: Mirror 404 / Outdated Package Database
    if grep -E -q "The requested URL returned error: 404|failed retrieving file" <<<"$err_content"; then
        recognized=true
        echo -e "${YELLOW}${BOLD}DIAGNOSIS: Outdated Mirror Database / 404 Package Not Found${NC}"
        echo -e "Explanation : The local package databases are out of sync with current Arch mirrors."
        echo -e "Remediation : Force-refresh the pacman sync databases:"
        echo -e "              ${CYAN}sudo pacman -Syy${NC}\n"

        echo -n -e "Attempt database synchronization and retry? [Y/n]: "
        read -r sync_retry
        if [[ -z "$sync_retry" || "$sync_retry" =~ ^[Yy]$ ]]; then
            log_info "Forcing database sync..."
            if sudo pacman -Syy; then
                log_success "Databases refreshed. Retrying installation..."
                if sudo pacman -S --needed --noconfirm "${missing[@]}"; then
                    log_success "Installation succeeded after database sync!"
                    rm -f "$TEMP_PACMAN_ERR"
                    return 0
                fi
            fi
        fi
    fi

    # Error Pattern 3: Conflicting Files
    if grep -q "failed to commit transaction (conflicting files)" <<<"$err_content"; then
        recognized=true
        echo -e "${YELLOW}${BOLD}DIAGNOSIS: Existing File Conflicts Detected${NC}"
        echo -e "Explanation : Untracked files exist on disk that clash with packages being installed."
        echo -e "Details from pacman log:"
        grep -E "exists in filesystem" <<<"$err_content" | head -n 10
        echo -e "\nRemediation : Back up or remove conflicting files, or inspect with ${CYAN}pacman -Qo <path>${NC}.\n"
    fi

    # Error Pattern 4: Target Not Found (Missing Repo / Typo)
    if grep -q "target not found" <<<"$err_content"; then
        recognized=true
        echo -e "${YELLOW}${BOLD}DIAGNOSIS: Package Target Not Found in Active Repositories${NC}"
        echo -e "Explanation : One or more requested packages do not exist in currently enabled repositories."
        echo -e "Details from pacman log:"
        grep "target not found" <<<"$err_content"
        echo -e "\nRemediation : Ensure the [extra] repository is enabled in ${CYAN}/etc/pacman.conf${NC}.\n"
    fi

    if [[ "$recognized" == false ]]; then
        echo -e "${YELLOW}${BOLD}Raw Pacman Error Output:${NC}"
        cat "$TEMP_PACMAN_ERR"
    fi

    echo -e "${RED}${BOLD}====================================================================${NC}\n"

    # Step-by-step per-package isolation to pinpoint exact failures
    log_info "Performing individual package isolation scan..."
    local failed_pkgs=()
    local passed_pkgs=()

    for pkg in "${missing[@]}"; do
        if sudo pacman -S --needed --noconfirm "$pkg" >/dev/null 2>&1; then
            passed_pkgs+=("$pkg")
        else
            failed_pkgs+=("$pkg")
        fi
    done

    echo -e "\n${BOLD}Package Isolation Results:${NC}"
    for p in "${passed_pkgs[@]}"; do
        echo -e "  [${GREEN}PASSED${NC}] $p"
    done
    for f in "${failed_pkgs[@]}"; do
        echo -e "  [${RED}FAILED${NC}] $f (${DEPS_MAP[$f]})"
    done
    echo ""

    if [[ ${#failed_pkgs[@]} -gt 0 ]]; then
        log_warn "Installation continued with partial dependencies (${#failed_pkgs[@]} failed)."
    fi

    rm -f "$TEMP_PACMAN_ERR"
}

# ------------------------------------------------------------------------------
# Dotfiles Deployment
# ------------------------------------------------------------------------------
deploy_dotfiles() {
    log_step "Deploying Dotfiles Configurations"

    local backup_dir="$HOME/.config/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    local target_dirs=("$HOME/.config" "$HOME/.local/bin" "$HOME/Pictures/Wallpapers")

    for dir in "${target_dirs[@]}"; do
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "$dir"
        fi
    done

    # 1. Config Directories
    local config_dirs=("hypr" "kitty" "gtk-3.0" "gtk-4.0" "fontconfig" "systemd")
    for cfg in "${config_dirs[@]}"; do
        local src="$DOTFILES_DIR/.config/$cfg"
        local dst="$HOME/.config/$cfg"

        if [[ -d "$src" ]]; then
            if [[ -d "$dst" ]]; then
                if [[ "$DRY_RUN" == false ]]; then
                    mkdir -p "$backup_dir"
                    cp -r "$dst" "$backup_dir/$cfg"
                fi
                log_info "Backed up existing ~/.config/$cfg to $(basename "$backup_dir")/"
            fi

            if [[ "$DRY_RUN" == false ]]; then
                rm -rf "$dst"
                cp -r "$src" "$HOME/.config/"
            fi
            log_success "Installed ~/.config/$cfg"
        fi
    done

    # 2. Config Files (starship.toml, mimeapps.list)
    local standalone_files=("starship.toml" "mimeapps.list")
    for file in "${standalone_files[@]}"; do
        if [[ -f "$DOTFILES_DIR/.config/$file" ]]; then
            if [[ -f "$HOME/.config/$file" ]]; then
                if [[ "$DRY_RUN" == false ]]; then
                    mkdir -p "$backup_dir"
                    cp "$HOME/.config/$file" "$backup_dir/$file"
                fi
                log_info "Backed up existing ~/.config/$file"
            fi

            if [[ "$DRY_RUN" == false ]]; then
                cp "$DOTFILES_DIR/.config/$file" "$HOME/.config/$file"
            fi
            log_success "Installed ~/.config/$file"
        fi
    done

    # 3. Helper Scripts in ~/.local/bin
    if [[ -d "$DOTFILES_DIR/.local/bin" ]]; then
        log_info "Installing helper scripts to ~/.local/bin"
        if [[ "$DRY_RUN" == false ]]; then
            cp -r "$DOTFILES_DIR/.local/bin/"* "$HOME/.local/bin/"
            chmod +x "$HOME/.local/bin/"*
        fi
        log_success "Installed and made executable: helper scripts in ~/.local/bin"
    fi

    # 4. Wallpapers
    if [[ -d "$DOTFILES_DIR/wallpapers" ]]; then
        log_info "Copying wallpapers to ~/Pictures/Wallpapers"
        if [[ "$DRY_RUN" == false ]]; then
            cp -rn "$DOTFILES_DIR/wallpapers/"* "$HOME/Pictures/Wallpapers/" 2>/dev/null || true
        fi
        log_success "Curated wallpapers deployed"
    fi

    # 5. Bash Profile & PATH Setup
    local bashrc="$HOME/.bashrc"
    if [[ -f "$bashrc" ]]; then
        local need_path=true
        local need_starship=true

        if grep -q '\$HOME/\.local/bin' "$bashrc" 2>/dev/null || grep -q '~/\.local/bin' "$bashrc" 2>/dev/null; then
            need_path=false
        fi

        if grep -q 'starship init bash' "$bashrc" 2>/dev/null; then
            need_starship=false
        fi

        if [[ "$need_path" == true || "$need_starship" == true ]]; then
            log_info "Updating ~/.bashrc with PATH and Starship prompt hooks..."
            if [[ "$DRY_RUN" == false ]]; then
                echo "" >> "$bashrc"
                echo "# Added by arch-lunix dotfiles installer" >> "$bashrc"
                if [[ "$need_path" == true ]]; then
                    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$bashrc"
                fi
                if [[ "$need_starship" == true ]]; then
                    echo 'if command -v starship &> /dev/null; then' >> "$bashrc"
                    echo '    eval "$(starship init bash)"' >> "$bashrc"
                    echo 'fi' >> "$bashrc"
                fi
            fi
            log_success "Configured ~/.bashrc integration"
        fi
    fi
}

# ------------------------------------------------------------------------------
# System Integration & Services
# ------------------------------------------------------------------------------
configure_system_services() {
    log_step "Configuring System Services & Desktop Integration"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would enable systemd user services and set GTK defaults."
        return 0
    fi

    # 1. User Systemd Units
    if command -v systemctl >/dev/null 2>&1; then
        log_info "Reloading user systemd daemon..."
        systemctl --user daemon-reload 2>/dev/null || true

        if [[ -f "$HOME/.config/systemd/user/omarchy-clipboard.service" ]]; then
            log_info "Enabling Omarchy Clipboard service..."
            systemctl --user enable omarchy-clipboard.service 2>/dev/null || true
            systemctl --user start omarchy-clipboard.service 2>/dev/null || true
            log_success "omarchy-clipboard.service configured"
        fi
    fi

    # 2. Initialize Standard XDG User Directories
    if command -v xdg-user-dirs-update >/dev/null 2>&1; then
        log_info "Initializing standard user directories (xdg-user-dirs)..."
        xdg-user-dirs-update 2>/dev/null || true
        log_success "Standard XDG directories initialized"
    fi

    # 3. Font Cache
    if command -v fc-cache >/dev/null 2>&1; then
        log_info "Updating font cache..."
        fc-cache -f >/dev/null 2>&1 || true
        log_success "Font cache refreshed"
    fi

    # 4. GTK & Desktop Defaults (Appearance, Fonts, Cursors)
    log_info "Setting system-wide dark theme, cursor, and font defaults..."
    if command -v gsettings >/dev/null 2>&1; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true
        gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 10' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface document-font-name 'JetBrainsMono Nerd Font 10' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 10' 2>/dev/null || true
        gsettings set org.nemo.desktop show-desktop-icons false 2>/dev/null || true
        gsettings set org.nemo.preferences thumbnail-limit 104857600 2>/dev/null || true
    fi

    # 5. Default Applications (File Manager, Browser, Terminal)
    log_info "Configuring default application associations..."
    if command -v xdg-mime >/dev/null 2>&1; then
        # Default File Manager
        xdg-mime default nemo.desktop inode/directory 2>/dev/null || true
        xdg-mime default nemo.desktop application/x-gnome-saved-search 2>/dev/null || true

        # Default Web Browser
        xdg-mime default firefox.desktop x-scheme-handler/http 2>/dev/null || true
        xdg-mime default firefox.desktop x-scheme-handler/https 2>/dev/null || true
        xdg-mime default firefox.desktop x-scheme-handler/chrome 2>/dev/null || true
        xdg-mime default firefox.desktop text/html 2>/dev/null || true
        xdg-mime default firefox.desktop application/xhtml+xml 2>/dev/null || true
    fi

    if command -v xdg-settings >/dev/null 2>&1; then
        xdg-settings set default-web-browser firefox.desktop 2>/dev/null || true
    fi

    log_success "Theme, cursor, font, and application defaults configured"
}

# ------------------------------------------------------------------------------
# Post-Installation Health Verification
# ------------------------------------------------------------------------------
verify_installation() {
    log_step "Running Post-Installation Health Verification"

    echo -e "\n${BOLD}Runtime Binary Verification:${NC}"
    local binaries=("Hyprland" "hyprctl" "kitty" "nemo" "firefox" "starship" "wofi" "wl-copy" "wl-paste" "wtype" "jq" "wpctl" "brightnessctl" "playerctl")
    local all_good=true

    for bin in "${binaries[@]}"; do
        if command -v "$bin" >/dev/null 2>&1; then
            printf "  [${GREEN}PASS${NC}] %-18s ${DIM}($(command -v "$bin"))${NC}\n" "$bin"
        else
            printf "  [${RED}FAIL${NC}] %-18s ${RED}Binary not found in PATH${NC}\n" "$bin"
            all_good=false
        fi
    done

    echo -e "\n${BOLD}Font Verification:${NC}"
    if fc-list : family 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
        echo -e "  [${GREEN}PASS${NC}] JetBrainsMono Nerd Font is indexed"
    else
        echo -e "  [${YELLOW}WARN${NC}] JetBrainsMono Nerd Font not found in fontconfig cache"
    fi

    echo -e "\n${BOLD}Systemd Clipboard Service Status:${NC}"
    if systemctl --user is-enabled omarchy-clipboard.service >/dev/null 2>&1; then
        echo -e "  [${GREEN}PASS${NC}] omarchy-clipboard.service is enabled"
    else
        echo -e "  [${YELLOW}WARN${NC}] omarchy-clipboard.service is not enabled"
    fi

    echo ""
    if [[ "$all_good" == true ]]; then
        echo -e "${GREEN}${BOLD}✔ All systems verified! Installation is healthy and ready to use.${NC}"
    else
        echo -e "${YELLOW}${BOLD}⚠ Installation completed with warnings. Review missing binaries above.${NC}"
    fi

    echo -e "\n${CYAN}${BOLD}Next Steps:${NC}"
    echo "  1. If you are in a TTY, start the graphical environment with: Hyprland"
    echo "  2. If already inside Hyprland, reload with: hyprctl reload"
    echo "  3. Launch application menu: Super + Space (wofi)"
    echo "  4. Clipboard history picker: Super + Ctrl + V"
    echo "  5. Installation log saved to: $LOG_FILE"
    echo ""
}

# ------------------------------------------------------------------------------
# Main Flow
# ------------------------------------------------------------------------------
main() {
    echo -e "${CYAN}${BOLD}"
    echo "  █████╗ ██████╗  ██████╗██╗  ██╗    ██╗     ██╗   ██╗███╗   ██╗██╗██╗  ██╗"
    echo " ██╔══██╗██╔══██╗██╔════╝██║  ██║    ██║     ██║   ██║████╗  ██║██║╚██╗██╔╝"
    echo " ███████║██████╔╝██║     ███████║    ██║     ██║   ██║██╔██╗ ██║██║ ╚███╔╝ "
    echo " ██╔══██║██╔══██╗██║     ██╔══██║    ██║     ██║   ██║██║╚██╗██║██║ ██╔██╗ "
    echo " ██║  ██║██║  ██║╚██████╗██║  ██║    ███████╗╚██████╔╝██║ ╚████║██║██╔╝ ██╗"
    echo " ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝    ╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${BOLD}Arch Linux + Hyprland Dotfiles Setup & Dependency Engine${NC}\n"

    preflight_checks
    check_and_install_dependencies
    deploy_dotfiles
    configure_system_services
    verify_installation
}

main "$@"
