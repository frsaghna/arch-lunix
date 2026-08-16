# ❄️ Arch Linux + Hyprland + Quickshell Minimalist Desktop

A modern, minimalist, keyboard-driven Wayland desktop environment powered by **Hyprland**, **Quickshell**, and **Matugen (Material You 3)** dynamic theming with authentic frosted glass aesthetics.

---

## ✨ Features

- **🎨 Dynamic Material You Theming (Matugen):**
  - Instant live palette extraction from any selected wallpaper.
  - Recolor the Top Bar, App Launcher, Window Borders, Kitty Terminal, and Nemo File Manager simultaneously with zero latency.
- **❄️ Frosted Glass (Acrylic Glassmorphism):**
  - Multi-pass Kawase blur engine (`passes = 3`, `size = 6`, `vibrancy = 0.2`).
  - Translucent obsidian surfaces (`65%` alpha) with razor-sharp 1px dynamic accent outlines.
- **💊 Compact Capsule Top Bar:**
  - 30px stadium pill bar with center-anchored clock/date, minimalist active pill workspaces, and hardware-aware battery widget.
- **🚀 Spotlight App Launcher:**
  - Minimalist, hint-free, keyboard-driven application search (<kbd>Super</kbd> + <kbd>Space</kbd>).
- **🖼️ Horizontal Carousel Wallpaper Picker & Installer:**
  - Fullscreen side-scrolling wallpaper picker with live type-to-filter (<kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>Space</kbd> → *Background*).
  - Built-in wallpaper installer for curated collections or custom image URLs.
- **📂 Themed Nemo File Manager & Kitty Terminal:**
  - Synced frosted glass transparency and dynamic accent highlights.
  - Dynamic Papirus folder icon recoloring to match the wallpaper hue.
- **🔤 JetBrainsMono Nerd Font Typography:**
  - Crisp vector iconography and monospace alignment.

---

## ⌨️ Keybindings Cheat Sheet

| Action | Shortcut |
| :--- | :--- |
| **App Drawer / Launcher** | <kbd>Super</kbd> + <kbd>Space</kbd> / <kbd>Super</kbd> + <kbd>R</kbd> |
| **Settings & Menu Drawer** | <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>Space</kbd> |
| **Terminal (Kitty)** | <kbd>Super</kbd> + <kbd>Return</kbd> |
| **File Manager (Nemo)** | <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>F</kbd> |
| **Web Browser (Firefox)** | <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>B</kbd> |
| **Close Window** | <kbd>Super</kbd> + <kbd>W</kbd> / <kbd>Super</kbd> + <kbd>Q</kbd> |
| **Toggle Floating Window** | <kbd>Super</kbd> + <kbd>V</kbd> |
| **Focus Navigation** | <kbd>Super</kbd> + <kbd>H</kbd> / <kbd>J</kbd> / <kbd>K</kbd> / <kbd>L</kbd> or Arrow Keys |
| **Switch Workspaces** | <kbd>Super</kbd> + <kbd>1-9</kbd> |
| **Move Window to Workspace** | <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>1-9</kbd> |
| **Universal Copy / Paste / Cut** | <kbd>Super</kbd> + <kbd>C</kbd> / <kbd>Super</kbd> + <kbd>V</kbd> / <kbd>Super</kbd> + <kbd>X</kbd> |

---

## 📦 Required Dependencies

Install with `pacman` and `yay`:

```bash
# Core Compositor & Tools
sudo pacman -S --noconfirm hyprland kitty nemo matugen ttf-jetbrains-mono-nerd papirus-icon-theme

# Quickshell (from AUR)
yay -S --noconfirm quickshell-git
```

---

## 🚀 Installation & Setup

Clone the repository and run the setup script:

```bash
git clone https://github.com/frsaghna/arch-lunix.git ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

---

## 🏗️ Architecture & Dotfiles Structure

```
.
├── .config/
│   ├── hypr/               # Hyprland configuration (hyprland.lua, dynamic colors)
│   ├── quickshell/         # Quickshell bar, drawer, menu, and theme engine
│   ├── matugen/            # Material You templates for Quickshell, Kitty, GTK
│   ├── kitty/              # Kitty terminal configuration & dynamic colors
│   ├── fontconfig/         # Font aliases (JetBrainsMono Nerd Font default)
│   ├── gtk-3.0/            # GTK3 / Nemo frosted theme styling
│   └── gtk-4.0/            # GTK4 prefer-dark settings
├── .local/bin/             # Helper scripts (papirus-folders)
├── wallpapers/             # Wallpaper gallery
├── install.sh              # Dotfiles symlink & deploy script
└── README.md
```
