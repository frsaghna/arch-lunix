import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "modules/drawer"
import "modules/bar"
import "modules/theme"
import "modules/wallpaper"
import "modules/menu"

ShellRoot {
    id: root

    // Desktop Wallpaper Layer
    DesktopWallpaper {
        id: wallpaper
    }

    // Top Panel Bar
    TopBar {
        id: topBar
    }

    // Application Search Drawer
    AppDrawer {
        id: drawer
    }

    // Settings & Customization Menu Drawer
    MenuDrawer {
        id: menuDrawer
    }

    // IPC for App Drawer
    IpcHandler {
        target: "drawer"

        function toggle() {
            drawer.toggle();
        }

        function open() {
            drawer.open();
        }

        function close() {
            drawer.close();
        }
    }

    // IPC for Menu Drawer
    IpcHandler {
        target: "menu"

        function toggle() {
            menuDrawer.toggle();
        }

        function open() {
            menuDrawer.open();
        }

        function close() {
            menuDrawer.close();
        }
    }
}
