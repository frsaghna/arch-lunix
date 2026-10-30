# Arch Linux + Hyprland Dotfiles

A minimalist, keyboard-driven Wayland desktop configuration for Arch Linux and Hyprland, featuring Kitty terminal, Nemo file manager, Starship shell prompt, and systemd clipboard integration.

---

## Features

- **Cohesive Dark Palette**
  - Minimalist color scheme applied across Hyprland window borders, Kitty terminal, Nemo file manager, and GTK3 applications.

- **Acrylic Blur & Glassmorphism**
  - Multi-pass Kawase blur engine (`passes = 3`, `size = 6`, `vibrancy = 0.2`).
  - Subtle translucent window rules for Kitty (`0.85/0.75`) and Nemo (`0.85/0.75`).

- **Nemo File Manager Rice**
  - Configured as the primary system file manager (`xdg-mime` association).
  - Custom GTK3 theme styling (`gtk-3.0/gtk.css`) tailored for Nemo:
    - Pathbar breadcrumbs and pill buttons.
    - Frosted translucent status bar and places sidebar.
    - Clean selection highlights and surface styling.
  - Hyprland opacity rules and desktop icon suppression.

- **Universal Wayland Clipboard Management**
  - Background systemd user service (`omarchy-clipboard.service`).
  - Persistent JSON history buffer supporting text and PNG image snapshots.
  - Interactive clipboard menu (`clipboard-menu.sh`) integrated with Wofi/Rofi/Fuzzel.
  - Global cut, copy, paste, and select-all wrappers for terminals and GUI apps.

- **Terminal & Shell**
  - Kitty terminal configured with cursor trail animations, powerline tab bar, and custom padding.
  - Starship cross-shell prompt with minimalist segment formatting.

---

## Keybindings

### Applications & System

| Action | Keybinding |
| :--- | :--- |
| Terminal (Kitty) | `Super` + `Return` |
| File Manager (Nemo) | `Super` + `Shift` + `F` |
| Web Browser | `Super` + `Shift` + `B` |
| App Launcher | `Super` + `Space` / `Super` + `R` |
| Menu Drawer | `Super` + `Alt` + `Space` |
| Close Active Window | `Super` + `W` |
| Toggle Floating | `Super` + `T` |
| Toggle Fullscreen | `Super` + `F` |
| Pseudo Tiling | `Super` + `P` |
| Toggle Split Orientation | `Super` + `J` |

### Clipboard & Selection

| Action | Keybinding |
| :--- | :--- |
| Universal Select All | `Super` + `A` |
| Universal Copy | `Super` + `C` |
| Universal Paste | `Super` + `V` |
| Universal Cut | `Super` + `X` |
| Clipboard History Picker | `Super` + `Ctrl` + `V` |

### Navigation & Workspaces

| Action | Keybinding |
| :--- | :--- |
| Focus Window | `Super` + `Left` / `Right` / `Up` / `Down` |
| Switch Workspace (1–10) | `Super` + `1` – `0` |
| Move Window to Workspace | `Super` + `Shift` + `1` – `0` |
| Toggle Scratchpad | `Super` + `S` |
| Move Window to Scratchpad | `Super` + `Shift` + `S` |
| Move Window (Interactive) | `Super` + `Left Mouse Button` |
| Resize Window (Interactive) | `Super` + `Right Mouse Button` |

---

## Dependencies & Error Handling

The automated installer includes a **Dependency Diagnosis & Error Recognition Engine** that automatically detects missing packages, diagnoses common pacman failure modes (stale keyring, mirror 404s, conflicting files), and isolates problematic packages.

### Required Packages (Official Repositories)

```bash
sudo pacman -S --needed --noconfirm \
  hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  qt5-wayland qt6-wayland polkit-kde-agent \
  kitty nemo firefox starship \
  wl-clipboard wtype jq perl util-linux coreutils \
  wofi \
  pipewire wireplumber pipewire-audio pipewire-pulse \
  brightnessctl playerctl \
  ttf-jetbrains-mono-nerd noto-fonts-emoji \
  papirus-icon-theme adwaita-icon-theme \
  gsettings-desktop-schemas dconf xdg-utils
```

---

## Installation

Clone the repository and run the automated installation script:

```bash
git clone https://github.com/frsaghna/arch-lunix.git ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

### Installer Options

| Flag | Description |
| :--- | :--- |
| `./install.sh` | Interactive installer with dependency checking, installation, and deployment |
| `./install.sh -y` / `--yes` | Non-interactive auto-install of all missing dependencies |
| `./install.sh --check-only` | Runs diagnostic health & dependency check without altering system |
| `./install.sh --dry-run` | Simulates configuration deployment and backs up safely |

The installer will:
1. Run pre-flight checks (Arch Linux verification, non-root user, lockfile, internet).
2. Scan and report missing dependencies with intelligent pacman error handling.
3. Deploy configurations into `~/.config/` (with automatic timestamped backups).
4. Deploy `starship.toml` and configure `~/.bashrc` integration.
5. Install clipboard and utility scripts into `~/.local/bin/`.
6. Enable and start `omarchy-clipboard.service` user daemon.
7. Update font cache and set dark theme/Nemo defaults via `gsettings` and `xdg-mime`.
8. Run a post-installation health verification pass.

---

## Directory Structure

```
arch-lunix/
├── .config/
│   ├── fontconfig/            # Font configuration and aliases
│   ├── gtk-3.0/               # GTK3 styling and custom Nemo theme
│   ├── gtk-4.0/               # GTK4 settings
│   ├── hypr/                  # Hyprland configuration, scripts, color variables
│   ├── kitty/                 # Kitty terminal configuration and color theme
│   ├── starship.toml          # Starship cross-shell prompt configuration
│   └── systemd/               # User systemd service units (clipboard daemon)
├── .local/
│   └── bin/                   # Utility and clipboard helper scripts
├── wallpapers/                # Curated wallpaper gallery
├── install.sh                 # Deployment and setup script
└── README.md
```
