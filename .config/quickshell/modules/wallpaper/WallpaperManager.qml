pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

QtObject {
    id: wm

    property var wallpapers: []
    property string currentWallpaper: ""
    property bool isDownloading: false
    property string downloadMessage: ""

    function setWallpaper(path) {
        if (!path) return;
        currentWallpaper = path;
        applyProcess.command = ["sh", "-c", "echo '" + path + "' > /home/kimmi/.cache/current_wallpaper && matugen image '" + path + "' -m dark --prefer saturation && /home/kimmi/.config/quickshell/scripts/reload-theme.sh"];
        applyProcess.running = true;
    }

    function setRandomWallpaper() {
        if (wallpapers && wallpapers.length > 0) {
            var idx = Math.floor(Math.random() * wallpapers.length);
            setWallpaper(wallpapers[idx]);
        }
    }

    function refresh() {
        scanProcess.running = true;
    }

    function installWallpaper(url, filename) {
        if (!url || !filename) return;
        isDownloading = true;
        downloadMessage = "Downloading " + filename + "...";
        
        var targetPath = "/home/kimmi/Pictures/Wallpapers/" + filename;
        downloadProcess.targetFile = targetPath;
        downloadProcess.command = ["curl", "-L", "-s", "-o", targetPath, url];
        downloadProcess.running = true;
    }

    // Unified process to atomically persist wallpaper, extract colors, and run reload hooks
    property var applyProcess: Process {
        command: ["sh", "-c", "echo ''"]
    }

    // Process to scan wallpapers directory
    property var scanProcess: Process {
        command: ["sh", "-c", "find /home/kimmi/Pictures/Wallpapers -maxdepth 1 -type f \\( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \\) | sort"]
        running: true

        stdout: StdioCollector {
            id: scanCollector
            onStreamFinished: {
                if (scanCollector.text) {
                    var lines = scanCollector.text.trim().split("\n");
                    var list = [];
                    for (var i = 0; i < lines.length; i++) {
                        var line = lines[i].trim();
                        if (line.length > 0) list.push(line);
                    }
                    wm.wallpapers = list;
                }
            }
        }
    }

    // Process to load saved wallpaper on startup
    property var loadProcess: Process {
        command: ["sh", "-c", "cat /home/kimmi/.cache/current_wallpaper 2>/dev/null || echo ''"]
        running: true

        stdout: StdioCollector {
            id: loadCollector
            onStreamFinished: {
                var path = loadCollector.text.trim();
                if (path.length > 0) {
                    wm.currentWallpaper = path;
                } else if (wm.wallpapers.length > 0) {
                    wm.currentWallpaper = wm.wallpapers[0];
                }
            }
        }
    }

    // Process to download wallpaper
    property var downloadProcess: Process {
        property string targetFile: ""
        command: ["sh", "-c", "echo ''"]

        onExited: function(exitCode, exitStatus) {
            wm.isDownloading = false;
            if (exitCode === 0 && targetFile) {
                wm.downloadMessage = "Installed successfully!";
                wm.refresh();
                wm.setWallpaper(targetFile);
            } else {
                wm.downloadMessage = "Download failed. Check URL.";
            }
        }
    }
}
