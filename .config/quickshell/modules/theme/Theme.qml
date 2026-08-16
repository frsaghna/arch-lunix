pragma Singleton
import QtQuick
import "."

QtObject {
    id: theme

    // Fonts
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property string fontMono: "JetBrainsMono Nerd Font Mono"
    readonly property string fontPropo: "JetBrainsMono Nerd Font Propo"

    // Dynamic Accents from Matugen (Synced 100% with Hyprland and Wallpaper)
    readonly property color accent: DynamicTheme.primary
    readonly property color accentHover: DynamicTheme.secondary
    readonly property color accentLight: DynamicTheme.tertiary

    // Base Background & Frosted Acrylic Palette (Identical base color & 65% opacity as Kitty)
    readonly property color background: Qt.rgba(DynamicTheme.surface.r, DynamicTheme.surface.g, DynamicTheme.surface.b, 0.65)
    readonly property color backgroundSolid: DynamicTheme.surface
    readonly property color surface: "#26FFFFFF"          // 15% specular white on base
    readonly property color surfaceElevated: "#33FFFFFF"  // 20% specular white on base
    readonly property color surfaceHover: "#4DFFFFFF"     // 30% hover highlight
    readonly property color surfaceActive: Qt.rgba(DynamicTheme.primary.r, DynamicTheme.primary.g, DynamicTheme.primary.b, 0.3)

    // Crisp Typography
    readonly property color textPrimary: "#F0F2F5"
    readonly property color textSecondary: "#C8CCD6"
    readonly property color textMuted: "#7E8594"

    // Subtle 1px Dynamic Accent Outlines (Synced with Hyprland active outline)
    readonly property color border: Qt.rgba(DynamicTheme.primary.r, DynamicTheme.primary.g, DynamicTheme.primary.b, 0.4)
    readonly property color borderHover: Qt.rgba(DynamicTheme.primary.r, DynamicTheme.primary.g, DynamicTheme.primary.b, 0.85)
    readonly property color borderActive: DynamicTheme.primary
    readonly property color glassHighlight: "#26FFFFFF"

    readonly property color danger: "#BF616A"
    readonly property color success: "#A3BE8C"
    readonly property color warning: "#EBCB8B"

    // Radii
    readonly property real radiusSm: 8
    readonly property real radiusMd: 12
    readonly property real radiusLg: 18
    readonly property real radiusFull: 999

    // Animation Durations
    readonly property int animFast: 120
    readonly property int animNormal: 200
    readonly property int animSlow: 300
}
