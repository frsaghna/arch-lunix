import QtQuick
import Quickshell
import Quickshell.Wayland
import "."

PanelWindow {
    id: wallpaperWindow

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell-wallpaper"

    color: "#000000"

    Image {
        id: bgImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: WallpaperManager.currentWallpaper ? ("file://" + WallpaperManager.currentWallpaper) : ""
        asynchronous: true
        cache: false
    }
}
