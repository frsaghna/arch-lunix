# Arch Linux + Hyprland Dotfiles

A minimalist, keyboard-driven Wayland desktop configuration for Arch Linux and Hyprland, featuring dynamic Material You (Matugen) theming, Kitty terminal, Nemo file manager, Starship shell prompt, and systemd clipboard integration.

---

## Features

- **Dynamic Material You Theming (Matugen)**
  - Palette extraction from the active wallpaper.
  - Consistent theming applied to Hyprland window borders, Kitty terminal, Nemo file manager, and GTK3 applications.

- **Acrylic Blur & Glassmorphism**
  - Multi-pass Kawase blur engine (`passes = 3`, `size = 6`, `vibrancy = 0.2`).
  - Subtle translucent window rules for Kitty (`0.85/0.75`) and Nemo (`0.85/0.75`).

- **Nemo File Manager Rice**
  - Configured as the primary system file manager (`xdg-mime` association).
  - Custom GTK3 theme styling (`gtk-3.0/gtk.css`) tailored for Nemo:
    - Pathbar breadcrumbs and pill buttons.
    - Frosted translucent status bar and places sidebar.
    - Selected item accent highlights matching wallpaper hues.
  - Hyprland opacity rules and desktop icon suppression.

- **Universal Wayland Clipboard Management**
  - Background systemd user service (`omarchy-clipboard.service`).
  - Persistent JSON history buffer supporting text and PNG image snapshots.
  - Interactive clipboard menu (`clipboard-menu.sh`) integrated with Wofi/Rofi/Fuzzel.
  - Global cut, copy, paste, and select-all wrappers for terminals and GUI apps.

- **Terminal & Shell**
  - Kitty terminal configured with cursor trail animations, powerline tab bar, and dynamic color injection.
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

## Dependencies

### Core Packages (Arch Official Repositories)

```bash
sudo pacman -S --noconfirm \
  hyprland \
  kitty \
  nemo \
  starship \
  wl-clipboard \
  wtype \
  jq \
  wofi \
  ttf-jetbrains-mono-nerd \
  papirus-icon-theme \
  brightnessctl \
  playerctl
```

### AUR Packages

```bash
yay -S --noconfirm matugen-bin
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

The installer will:
1. Link configuration directories into `~/.config/`.
2. Install clipboard and utility scripts into `~/.local/bin/`.
3. Set Nemo as the default file manager via `xdg-mime`.
4. Configure system-wide dark theme via `gsettings`.
5. Trigger initial Matugen color generation from wallpaper assets.

---

## Directory Structure

```
arch-lunix/
├── .config/
│   ├── fontconfig/            # Font configuration and aliases
│   ├── gtk-3.0/               # GTK3 styling and custom Nemo theme
│   ├── gtk-4.0/               # GTK4 settings
│   ├── hypr/                  # Hyprland configuration, scripts, dynamic colors
│   ├── kitty/                 # Kitty terminal configuration and dynamic palette
│   ├── matugen/               # Dynamic Material You CSS and config templates
│   ├── starship.toml          # Starship cross-shell prompt configuration
│   └── systemd/               # User systemd service units (clipboard daemon)
├── .local/
│   └── bin/                   # Utility and clipboard helper scripts
├── wallpapers/                # Curated wallpaper gallery
├── install.sh                 # Deployment and setup script
└── README.md
```
