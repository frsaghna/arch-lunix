import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../wallpaper"

PanelWindow {
    id: menuRoot

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-menu-drawer"

    color: "transparent"
    visible: false

    // Navigation state: "menu" | "style" | "wallpaper_picker" | "wallpaper_installer"
    property string currentView: "menu"
    property int selectedMenuIndex: 0
    property int selectedWallpaperIndex: 0
    property string filterQuery: ""

    function open() {
        visible = true;
        currentView = "menu";
        menuSearchField.text = "";
        filterQuery = "";
        selectedMenuIndex = 0;
        updateMenuItems();
        menuSearchField.forceActiveFocus();
        WallpaperManager.refresh();
    }

    function close() {
        visible = false;
        currentView = "menu";
        menuSearchField.text = "";
        filterQuery = "";
    }

    function toggle() {
        if (visible) close();
        else open();
    }

    function openWallpaperPicker() {
        currentView = "wallpaper_picker";
        filterQuery = "";
        selectedWallpaperIndex = 0;
        WallpaperManager.refresh();
        wallpaperPickerView.forceActiveFocus();
    }

    function openWallpaperInstaller() {
        currentView = "wallpaper_installer";
    }

    function goBack() {
        if (currentView === "wallpaper_installer") {
            currentView = "wallpaper_picker";
            wallpaperPickerView.forceActiveFocus();
        } else if (currentView === "wallpaper_picker" || currentView === "style") {
            currentView = "menu";
            menuSearchField.forceActiveFocus();
        } else {
            close();
        }
    }

    // Root Menu Items
    property var allMenuItems: [
        { id: "style", icon: "🎨", title: "Style & Appearance", subtitle: "Background, theme, window gaps & radius", category: "System" },
        { id: "wallpaper", icon: "🖼️", title: "Background Wallpaper", subtitle: "Full-screen horizontal wallpaper picker", category: "Style" },
        { id: "installer", icon: "⬇️", title: "Wallpaper Installer", subtitle: "Install curated presets or custom image URLs", category: "Style" },
        { id: "random_wp", icon: "🎲", title: "Random Wallpaper", subtitle: "Shuffle desktop wallpaper randomly", category: "Action" },
        { id: "display", icon: "🖥️", title: "Display & Resolution", subtitle: "1920x1080 @ 60Hz (Virtual-1)", category: "Hardware" }
    ]

    property var styleSubMenuItems: [
        { id: "wallpaper", icon: "🖼️", title: "Background", subtitle: "Side-scrolling wallpaper picker" },
        { id: "gaps", icon: "🪟", title: "Window Gaps", subtitle: "Outer 8px, Inner 4px, Rounding 8px" },
        { id: "animations", icon: "⚡", title: "Animations", subtitle: "High-speed EaseOutExpo snappy curves" },
        { id: "back", icon: "←", title: "Back to Main Menu", subtitle: "Return to commands list" }
    ]

    property var filteredMenuItems: []

    function updateMenuItems() {
        var query = menuSearchField.text.trim().toLowerCase();
        if (currentView === "style") {
            filteredMenuItems = styleSubMenuItems;
            return;
        }

        if (query === "") {
            filteredMenuItems = allMenuItems;
        } else {
            var list = [];
            for (var i = 0; i < allMenuItems.length; i++) {
                var item = allMenuItems[i];
                var t = item.title.toLowerCase();
                var s = item.subtitle.toLowerCase();
                var c = item.category.toLowerCase();
                if (t.indexOf(query) !== -1 || s.indexOf(query) !== -1 || c.indexOf(query) !== -1) {
                    list.push(item);
                }
            }
            filteredMenuItems = list;
        }
        if (selectedMenuIndex >= filteredMenuItems.length) {
            selectedMenuIndex = Math.max(0, filteredMenuItems.length - 1);
        }
    }

    function executeMenuAction(item) {
        if (!item) return;
        if (item.id === "style") {
            currentView = "style";
            selectedMenuIndex = 0;
            menuSearchField.text = "";
            updateMenuItems();
        } else if (item.id === "wallpaper") {
            openWallpaperPicker();
        } else if (item.id === "installer") {
            openWallpaperInstaller();
        } else if (item.id === "random_wp") {
            WallpaperManager.setRandomWallpaper();
            close();
        } else if (item.id === "back") {
            currentView = "menu";
            selectedMenuIndex = 0;
            updateMenuItems();
        }
    }

    // Filtered Wallpapers for side-scroller
    property var filteredWallpapers: {
        var all = WallpaperManager.wallpapers || [];
        var q = filterQuery.trim().toLowerCase();
        if (q === "") return all;
        var res = [];
        for (var i = 0; i < all.length; i++) {
            var path = all[i] || "";
            var name = path.substring(path.lastIndexOf("/") + 1).toLowerCase();
            if (name.indexOf(q) !== -1) {
                res.push(path);
            }
        }
        return res;
    }

    // Transparent click-outside dismiss backdrop (No fullscreen blur)
    Rectangle {
        anchors.fill: parent
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (menuRoot.currentView === "wallpaper_picker" || menuRoot.currentView === "wallpaper_installer") {
                    menuRoot.goBack();
                } else {
                    menuRoot.close();
                }
            }
        }
    }

    // =========================================================================
    // VIEW 1: SPOTLIGHT COMMAND PALETTE (Menu & Style Submenu)
    // =========================================================================
    Rectangle {
        id: menuCard
        visible: menuRoot.currentView === "menu" || menuRoot.currentView === "style"
        width: Math.min(560, parent.width - 32)
        height: Math.min(380, parent.height - 64)
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.max(48, Math.floor((parent.height - height) * 0.32))
        radius: Theme.radiusMd
        color: Theme.background
        border.color: Theme.border
        border.width: 1

        scale: (menuRoot.visible && visible) ? 1.0 : 0.98
        opacity: (menuRoot.visible && visible) ? 1.0 : 0.0

        Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuad } }
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            // Search Header
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: Theme.radiusSm
                color: Theme.surface
                border.color: menuSearchField.activeFocus ? Theme.accent : Theme.border
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        text: menuRoot.currentView === "style" ? "🎨" : ""
                        font.pixelSize: 13
                        font.family: Theme.fontFamily
                        color: Theme.accentLight
                    }

                    TextInput {
                        id: menuSearchField
                        Layout.fillWidth: true
                        font.pixelSize: 13
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                        clip: true
                        selectByMouse: true

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            text: menuRoot.currentView === "style" ? "Style settings..." : "Search menu & settings..."
                            font.pixelSize: 13
                            font.family: Theme.fontFamily
                            color: Theme.textMuted
                            visible: !menuSearchField.text && !menuSearchField.activeFocus
                        }

                        onTextChanged: {
                            menuRoot.selectedMenuIndex = 0;
                            menuRoot.updateMenuItems();
                        }

                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Escape) {
                                menuRoot.goBack();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (menuRoot.filteredMenuItems.length > 0 && menuRoot.selectedMenuIndex < menuRoot.filteredMenuItems.length) {
                                    menuRoot.executeMenuAction(menuRoot.filteredMenuItems[menuRoot.selectedMenuIndex]);
                                }
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Down || (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier))) {
                                if (menuRoot.selectedMenuIndex + 1 < menuRoot.filteredMenuItems.length) {
                                    menuRoot.selectedMenuIndex++;
                                    menuListView.positionViewAtIndex(menuRoot.selectedMenuIndex, ListView.Contain);
                                }
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                                if (menuRoot.selectedMenuIndex > 0) {
                                    menuRoot.selectedMenuIndex--;
                                    menuListView.positionViewAtIndex(menuRoot.selectedMenuIndex, ListView.Contain);
                                }
                                event.accepted = true;
                            }
                        }
                    }
                }
            }

            // Command Items List
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                    id: menuListView
                    anchors.fill: parent
                    spacing: 2
                    model: menuRoot.filteredMenuItems
                    currentIndex: menuRoot.selectedMenuIndex
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        id: menuItemRow
                        width: menuListView.width
                        height: 42
                        radius: Theme.radiusSm

                        property bool isSelected: index === menuRoot.selectedMenuIndex
                        property bool isHovered: rowMouse.containsMouse

                        color: isSelected ? Theme.surfaceActive : (isHovered ? Theme.surfaceHover : "transparent")

                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: 3
                            height: 20
                            radius: 1.5
                            color: Theme.accentLight
                            visible: menuItemRow.isSelected
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: menuItemRow.isSelected ? 12 : 10
                            anchors.rightMargin: 12
                            spacing: 10

                            Text {
                                text: modelData.icon || "•"
                                font.pixelSize: 14
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: modelData.title
                                    font.pixelSize: 11
                                    font.bold: menuItemRow.isSelected
                                    font.family: Theme.fontFamily
                                    color: menuItemRow.isSelected ? Theme.textPrimary : Theme.textSecondary
                                }

                                Text {
                                    text: modelData.subtitle || ""
                                    font.pixelSize: 9
                                    font.family: Theme.fontFamily
                                    color: Theme.textMuted
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    visible: text.length > 0
                                }
                            }

                            Text {
                                text: "↵"
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                                color: menuItemRow.isSelected ? Theme.accentLight : "transparent"
                            }
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                menuRoot.selectedMenuIndex = index;
                                menuRoot.executeMenuAction(modelData);
                            }
                        }
                    }
                }
            }
        }
    }

    // =========================================================================
    // VIEW 2: MINIMALIST KEYBOARD-DRIVEN SIDE-SCROLLING WALLPAPER PICKER
    // =========================================================================
    Item {
        id: wallpaperPickerView
        visible: menuRoot.currentView === "wallpaper_picker"
        anchors.fill: parent
        focus: visible

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                if (menuRoot.filterQuery.length > 0) {
                    menuRoot.filterQuery = "";
                    menuRoot.selectedWallpaperIndex = 0;
                } else {
                    menuRoot.goBack();
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L || (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier))) {
                if (menuRoot.filteredWallpapers.length > 0) {
                    if (menuRoot.selectedWallpaperIndex + 1 < menuRoot.filteredWallpapers.length) {
                        menuRoot.selectedWallpaperIndex++;
                    } else {
                        menuRoot.selectedWallpaperIndex = 0;
                    }
                    wpListView.positionViewAtIndex(menuRoot.selectedWallpaperIndex, ListView.Center);
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Left || event.key === Qt.Key_H || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                if (menuRoot.filteredWallpapers.length > 0) {
                    if (menuRoot.selectedWallpaperIndex > 0) {
                        menuRoot.selectedWallpaperIndex--;
                    } else {
                        menuRoot.selectedWallpaperIndex = menuRoot.filteredWallpapers.length - 1;
                    }
                    wpListView.positionViewAtIndex(menuRoot.selectedWallpaperIndex, ListView.Center);
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (menuRoot.filteredWallpapers.length > 0 && menuRoot.selectedWallpaperIndex < menuRoot.filteredWallpapers.length) {
                    WallpaperManager.setWallpaper(menuRoot.filteredWallpapers[menuRoot.selectedWallpaperIndex]);
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Backspace) {
                if (menuRoot.filterQuery.length > 0) {
                    menuRoot.filterQuery = menuRoot.filterQuery.substring(0, menuRoot.filterQuery.length - 1);
                    menuRoot.selectedWallpaperIndex = 0;
                }
                event.accepted = true;
            } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) <= 126) {
                menuRoot.filterQuery += event.text.toLowerCase();
                menuRoot.selectedWallpaperIndex = 0;
                event.accepted = true;
            }
        }

        // Top Minimalist Breadcrumb & Counter HUD
        RowLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 28
            spacing: 12

            Text {
                text: "style / background"
                font.pixelSize: 11
                font.family: Theme.fontFamily
                color: Theme.textMuted
            }

            Item { Layout.fillWidth: true }

            // Active Type-to-Filter Query Indicator (appears seamlessly when user types)
            Rectangle {
                visible: menuRoot.filterQuery.length > 0
                implicitWidth: filterRow.implicitWidth + 16
                implicitHeight: 28
                radius: Theme.radiusSm
                color: Theme.surfaceElevated
                border.color: Theme.accent
                border.width: 1

                RowLayout {
                    id: filterRow
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "/"
                        font.pixelSize: 11
                        font.bold: true
                        font.family: Theme.fontFamily
                        color: Theme.accentLight
                    }
                    Text {
                        text: menuRoot.filterQuery
                        font.pixelSize: 11
                        font.bold: true
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                    }
                    Text {
                        text: "(" + menuRoot.filteredWallpapers.length + ")"
                        font.pixelSize: 10
                        font.family: Theme.fontFamily
                        color: Theme.textMuted
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Counter (e.g. 01 / 04)
            Text {
                text: {
                    if (menuRoot.filteredWallpapers.length === 0) return "0 / 0";
                    var cur = (menuRoot.selectedWallpaperIndex + 1);
                    var total = menuRoot.filteredWallpapers.length;
                    return (cur < 10 ? "0" + cur : cur) + " / " + (total < 10 ? "0" + total : total);
                }
                font.pixelSize: 11
                font.bold: true
                font.family: Theme.fontFamily
                color: Theme.textMuted
            }
        }

        // Side-Scrolling Wallpaper Carousel Track
        Item {
            anchors.centerIn: parent
            width: parent.width
            height: 400

            ListView {
                id: wpListView
                anchors.fill: parent
                orientation: ListView.Horizontal
                snapMode: ListView.SnapToItem
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: Math.floor((width - 640) / 2)
                preferredHighlightEnd: Math.floor((width - 640) / 2)
                highlightMoveDuration: 180
                model: menuRoot.filteredWallpapers
                currentIndex: menuRoot.selectedWallpaperIndex
                boundsBehavior: Flickable.StopAtBounds
                spacing: 24

                delegate: Item {
                    width: 640
                    height: wpListView.height

                    property bool isSelected: index === menuRoot.selectedWallpaperIndex
                    property bool isActive: WallpaperManager.currentWallpaper === modelData

                    Rectangle {
                        anchors.centerIn: parent
                        width: 640
                        height: 360
                        radius: Theme.radiusMd
                        color: Theme.surface
                        clip: true

                        scale: isSelected ? 1.0 : 0.86
                        opacity: isSelected ? 1.0 : 0.32

                        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                        Behavior on opacity { NumberAnimation { duration: 180 } }

                        border.color: isActive ? Theme.accentLight : (isSelected ? Theme.accent : Theme.border)
                        border.width: isActive || isSelected ? 2 : 1

                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            source: "file://" + modelData
                            asynchronous: true
                            cache: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            menuRoot.selectedWallpaperIndex = index;
                            wpListView.positionViewAtIndex(index, ListView.Center);
                            WallpaperManager.setWallpaper(modelData);
                        }
                    }
                }
            }

            // Empty state
            Text {
                anchors.centerIn: parent
                visible: menuRoot.filteredWallpapers.length === 0
                text: "no wallpapers matching \"" + menuRoot.filterQuery + "\""
                font.pixelSize: 12
                font.family: Theme.fontFamily
                color: Theme.textMuted
            }
        }

        // Bottom Filename & Active Status Indicator
        Item {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 36
            height: 32
            width: Math.min(600, parent.width - 48)

            RowLayout {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: {
                        if (menuRoot.filteredWallpapers.length === 0 || menuRoot.selectedWallpaperIndex >= menuRoot.filteredWallpapers.length) return "";
                        var path = menuRoot.filteredWallpapers[menuRoot.selectedWallpaperIndex] || "";
                        return path.substring(path.lastIndexOf("/") + 1);
                    }
                    font.pixelSize: 12
                    font.bold: true
                    font.family: Theme.fontFamily
                    color: Theme.textPrimary
                }

                // Active Indicator Dot
                Rectangle {
                    visible: {
                        if (menuRoot.filteredWallpapers.length === 0 || menuRoot.selectedWallpaperIndex >= menuRoot.filteredWallpapers.length) return false;
                        return WallpaperManager.currentWallpaper === menuRoot.filteredWallpapers[menuRoot.selectedWallpaperIndex];
                    }
                    implicitWidth: activeLabel.implicitWidth + 12
                    implicitHeight: 20
                    radius: 4
                    color: Theme.accent

                    RowLayout {
                        id: activeLabel
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: "ACTIVE"
                            font.pixelSize: 9
                            font.bold: true
                            font.family: Theme.fontFamily
                            color: "#FFFFFF"
                        }
                    }
                }
            }
        }
    }

    // =========================================================================
    // VIEW 3: WALLPAPER INSTALLER
    // =========================================================================
    Rectangle {
        id: installerCard
        visible: menuRoot.currentView === "wallpaper_installer"
        width: Math.min(640, parent.width - 32)
        height: Math.min(460, parent.height - 64)
        anchors.centerIn: parent
        radius: Theme.radiusMd
        color: Theme.background
        border.color: Theme.border
        border.width: 1

        scale: visible ? 1.0 : 0.98
        opacity: visible ? 1.0 : 0.0

        Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuad } }
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                spacing: 10

                Text {
                    text: "Wallpaper Installer"
                    font.pixelSize: 13
                    font.bold: true
                    font.family: Theme.fontFamily
                    color: Theme.textPrimary
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 28
                    height: 28
                    radius: Theme.radiusSm
                    color: instCloseMouse.containsMouse ? Theme.surfaceHover : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.pixelSize: 11
                        font.family: Theme.fontFamily
                        color: Theme.textMuted
                    }

                    MouseArea {
                        id: instCloseMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: menuRoot.goBack()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.border
            }

            // Presets
            Text {
                text: "Curated Presets"
                font.pixelSize: 11
                font.bold: true
                font.family: Theme.fontFamily
                color: Theme.textSecondary
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Preset 1: Nordic Minimal
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    radius: Theme.radiusSm
                    color: Theme.surface
                    border.color: Theme.border
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 4

                        Text {
                            text: "Nordic Minimal"
                            font.pixelSize: 10
                            font.bold: true
                            font.family: Theme.fontFamily
                            color: Theme.textPrimary
                        }
                        Text {
                            text: "Mountain range"
                            font.pixelSize: 9
                            font.family: Theme.fontFamily
                            color: Theme.textMuted
                        }

                        Item { Layout.fillHeight: true }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 22
                            radius: 4
                            color: p1Mouse.containsMouse ? Theme.accentHover : Theme.accent

                            Text {
                                anchors.centerIn: parent
                                text: "Install"
                                font.pixelSize: 9
                                font.bold: true
                                font.family: Theme.fontFamily
                                color: "#FFFFFF"
                            }

                            MouseArea {
                                id: p1Mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: WallpaperManager.installWallpaper("https://gitlab.com/dwt1/wallpapers/-/raw/master/0001.jpg", "nord_mountain.png")
                            }
                        }
                    }
                }

                // Preset 2: Dark Forest
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    radius: Theme.radiusSm
                    color: Theme.surface
                    border.color: Theme.border
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 4

                        Text {
                            text: "Dark Forest"
                            font.pixelSize: 10
                            font.bold: true
                            font.family: Theme.fontFamily
                            color: Theme.textPrimary
                        }
                        Text {
                            text: "Misty canopy"
                            font.pixelSize: 9
                            font.family: Theme.fontFamily
                            color: Theme.textMuted
                        }

                        Item { Layout.fillHeight: true }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 22
                            radius: 4
                            color: p2Mouse.containsMouse ? Theme.accentHover : Theme.accent

                            Text {
                                anchors.centerIn: parent
                                text: "Install"
                                font.pixelSize: 9
                                font.bold: true
                                font.family: Theme.fontFamily
                                color: "#FFFFFF"
                            }

                            MouseArea {
                                id: p2Mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: WallpaperManager.installWallpaper("https://gitlab.com/dwt1/wallpapers/-/raw/master/0014.jpg", "dark_forest.png")
                            }
                        }
                    }
                }

                // Preset 3: Cosmic Space
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    radius: Theme.radiusSm
                    color: Theme.surface
                    border.color: Theme.border
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 4

                        Text {
                            text: "Cosmic Space"
                            font.pixelSize: 10
                            font.bold: true
                            font.family: Theme.fontFamily
                            color: Theme.textPrimary
                        }
                        Text {
                            text: "Starfield nebula"
                            font.pixelSize: 9
                            font.family: Theme.fontFamily
                            color: Theme.textMuted
                        }

                        Item { Layout.fillHeight: true }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 22
                            radius: 4
                            color: p3Mouse.containsMouse ? Theme.accentHover : Theme.accent

                            Text {
                                anchors.centerIn: parent
                                text: "Install"
                                font.pixelSize: 9
                                font.bold: true
                                font.family: Theme.fontFamily
                                color: "#FFFFFF"
                            }

                            MouseArea {
                                id: p3Mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: WallpaperManager.installWallpaper("https://gitlab.com/dwt1/wallpapers/-/raw/master/0045.jpg", "minimal_space.png")
                            }
                        }
                    }
                }
            }

            // Custom URL
            Text {
                text: "Install from URL"
                font.pixelSize: 11
                font.bold: true
                font.family: Theme.fontFamily
                color: Theme.textSecondary
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                radius: Theme.radiusSm
                color: Theme.surface
                border.color: instUrlInput.activeFocus ? Theme.accent : Theme.border
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text { text: "🔗"; font.pixelSize: 11 }

                    TextInput {
                        id: instUrlInput
                        Layout.fillWidth: true
                        font.pixelSize: 11
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                        clip: true
                        selectByMouse: true

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            text: "Paste image URL..."
                            font.pixelSize: 11
                            font.family: Theme.fontFamily
                            color: Theme.textMuted
                            visible: !instUrlInput.text && !instUrlInput.activeFocus
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 34
                    radius: Theme.radiusSm
                    color: Theme.surface
                    border.color: instNameInput.activeFocus ? Theme.accent : Theme.border
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        TextInput {
                            id: instNameInput
                            Layout.fillWidth: true
                            text: "custom_wallpaper.png"
                            font.pixelSize: 11
                            font.family: Theme.fontFamily
                            color: Theme.textPrimary
                            clip: true
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    radius: Theme.radiusSm
                    color: instDownloadMouse.containsMouse ? Theme.accentHover : Theme.accent

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text { text: WallpaperManager.isDownloading ? "⏳" : "⬇️"; font.pixelSize: 11 }
                        Text {
                            text: WallpaperManager.isDownloading ? "Downloading..." : "Download & Set"
                            font.pixelSize: 10
                            font.bold: true
                            font.family: Theme.fontFamily
                            color: "#FFFFFF"
                        }
                    }

                    MouseArea {
                        id: instDownloadMouse
                        anchors.fill: parent
                        enabled: !WallpaperManager.isDownloading && instUrlInput.text.trim().length > 0
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var fname = instNameInput.text.trim() || "wallpaper_" + Date.now() + ".png";
                            WallpaperManager.installWallpaper(instUrlInput.text.trim(), fname);
                        }
                    }
                }
            }

            // Download Status
            Text {
                visible: WallpaperManager.downloadMessage.length > 0
                text: WallpaperManager.downloadMessage
                font.pixelSize: 10
                font.bold: true
                font.family: Theme.fontFamily
                color: WallpaperManager.downloadMessage.indexOf("success") !== -1 ? Theme.success : Theme.warning
            }

            Item { Layout.fillHeight: true }
        }
    }
}
