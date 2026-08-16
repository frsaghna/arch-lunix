#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "❄️ Installing Arch Linux + Hyprland + Quickshell dotfiles..."

# Create target directories
mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/Pictures/Wallpapers" "$HOME/.cache/matugen"

# Symlink configurations
configs=("hypr" "quickshell" "matugen" "kitty" "gtk-3.0" "gtk-4.0" "fontconfig")
for cfg in "${configs[@]}"; do
    if [ -d "$DOTFILES_DIR/.config/$cfg" ]; then
        echo "  -> Linking ~/.config/$cfg"
        rm -rf "$HOME/.config/$cfg"
        cp -r "$DOTFILES_DIR/.config/$cfg" "$HOME/.config/"
    fi
done

# Copy helpers
if [ -d "$DOTFILES_DIR/.local/bin" ]; then
    echo "  -> Installing helper scripts to ~/.local/bin"
    cp -r "$DOTFILES_DIR/.local/bin/"* "$HOME/.local/bin/"
    chmod +x "$HOME/.local/bin/"*
fi

# Copy wallpapers
if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    echo "  -> Copying wallpapers to ~/Pictures/Wallpapers"
    cp -rn "$DOTFILES_DIR/wallpapers/"* "$HOME/Pictures/Wallpapers/" 2>/dev/null || true
fi

# Set executable permissions on quickshell scripts
chmod +x "$HOME/.config/quickshell/scripts/"* 2>/dev/null || true

# Set dark theme in gsettings & xdg-mime
echo "  -> Setting system-wide dark theme and Nemo default..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
gsettings set org.nemo.desktop show-desktop-icons false 2>/dev/null || true
xdg-mime default nemo.desktop inode/directory 2>/dev/null || true

# Run initial Matugen generation if wallpapers exist
FIRST_WP=$(find "$HOME/Pictures/Wallpapers" -type f \( -name "*.png" -o -name "*.jpg" \) | head -n 1)
if [ -n "$FIRST_WP" ] && command -v matugen &>/dev/null; then
    echo "  -> Generating dynamic Material You color scheme..."
    matugen image "$FIRST_WP" -m dark --prefer saturation
    echo "$FIRST_WP" > "$HOME/.cache/current_wallpaper"
fi

echo "✅ Installation complete! Reload Hyprland with: hyprctl reload"
