import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../theme"

PanelWindow {
    id: drawerRoot

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-app-drawer"

    color: "transparent"
    visible: false

    property var filteredApps: []
    property int selectedIndex: 0

    function open() {
        visible = true;
        searchField.text = "";
        selectedIndex = 0;
        updateApps();
        searchField.forceActiveFocus();
    }

    function close() {
        visible = false;
        searchField.text = "";
    }

    function toggle() {
        if (visible) {
            close();
        } else {
            open();
        }
    }

    function updateApps() {
        var query = searchField.text.trim().toLowerCase();
        var allApps = DesktopEntries.applications.values;
        var list = [];

        for (var i = 0; i < allApps.length; i++) {
            var app = allApps[i];
            if (!app || app.noDisplay) continue;

            var name = (app.name || "").toLowerCase();
            var genName = (app.genericName || "").toLowerCase();
            var comment = (app.comment || "").toLowerCase();
            var id = (app.id || "").toLowerCase();

            if (query === "" || name.indexOf(query) !== -1 || genName.indexOf(query) !== -1 || comment.indexOf(query) !== -1 || id.indexOf(query) !== -1) {
                list.push(app);
            }
        }

        if (query === "") {
            list.sort(function(a, b) {
                return (a.name || "").localeCompare(b.name || "");
            });
        } else {
            list.sort(function(a, b) {
                var aStarts = (a.name || "").toLowerCase().indexOf(query) === 0;
                var bStarts = (b.name || "").toLowerCase().indexOf(query) === 0;
                if (aStarts && !bStarts) return -1;
                if (!aStarts && bStarts) return 1;
                return (a.name || "").localeCompare(b.name || "");
            });
        }

        filteredApps = list;
        if (selectedIndex >= list.length) {
            selectedIndex = Math.max(0, list.length - 1);
        }
    }

    function launchSelected() {
        if (filteredApps && filteredApps.length > 0 && selectedIndex >= 0 && selectedIndex < filteredApps.length) {
            var app = filteredApps[selectedIndex];
            if (app) {
                app.execute();
                close();
            }
        }
    }

    // Transparent click-outside dismiss backdrop (No fullscreen blur)
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            onClicked: drawerRoot.close()
        }
    }

    // Main Minimal Spotlight Card
    Rectangle {
        id: mainCard
        width: Math.min(560, parent.width - 32)
        height: Math.min(420, parent.height - 64)
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.max(48, Math.floor((parent.height - height) * 0.32))
        radius: Theme.radiusMd
        color: Theme.background
        border.color: Theme.border
        border.width: 1

        scale: drawerRoot.visible ? 1.0 : 0.98
        opacity: drawerRoot.visible ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuad }
        }
        Behavior on opacity {
            NumberAnimation { duration: Theme.animFast }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            // Minimalist Search Bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: Theme.radiusSm
                color: Theme.surface
                border.color: searchField.activeFocus ? Theme.accent : Theme.border
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        text: ""
                        font.pixelSize: 14
                        font.family: Theme.fontFamily
                        color: searchField.activeFocus ? Theme.accentLight : Theme.textMuted
                    }

                    TextInput {
                        id: searchField
                        Layout.fillWidth: true
                        font.pixelSize: 13
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                        clip: true
                        selectByMouse: true

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            text: "Type to search apps..."
                            font.pixelSize: 13
                            font.family: Theme.fontFamily
                            color: Theme.textMuted
                            visible: !searchField.text && !searchField.activeFocus
                        }

                        onTextChanged: {
                            drawerRoot.selectedIndex = 0;
                            drawerRoot.updateApps();
                        }

                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Escape) {
                                drawerRoot.close();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                drawerRoot.launchSelected();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Down || (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier))) {
                                if (drawerRoot.selectedIndex + 1 < drawerRoot.filteredApps.length) {
                                    drawerRoot.selectedIndex++;
                                    appListView.positionViewAtIndex(drawerRoot.selectedIndex, ListView.Contain);
                                }
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                                if (drawerRoot.selectedIndex > 0) {
                                    drawerRoot.selectedIndex--;
                                    appListView.positionViewAtIndex(drawerRoot.selectedIndex, ListView.Contain);
                                }
                                event.accepted = true;
                            }
                        }
                    }

                    // Clear button
                    Text {
                        visible: searchField.text.length > 0
                        text: "✕"
                        font.pixelSize: 10
                        font.family: Theme.fontFamily
                        color: Theme.textMuted

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                searchField.text = "";
                                searchField.forceActiveFocus();
                            }
                        }
                    }
                }
            }

            // Minimalist Vertical App List
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                    id: appListView
                    anchors.fill: parent
                    spacing: 2
                    model: drawerRoot.filteredApps
                    currentIndex: drawerRoot.selectedIndex
                    boundsBehavior: Flickable.StopAtBounds
                    highlightFollowsCurrentItem: true
                    highlightMoveDuration: 0

                    delegate: Rectangle {
                        id: itemRow
                        width: appListView.width
                        height: 36
                        radius: Theme.radiusSm

                        property bool isSelected: index === drawerRoot.selectedIndex
                        property bool isHovered: rowMouse.containsMouse

                        color: isSelected ? Theme.surfaceActive : (isHovered ? Theme.surfaceHover : "transparent")

                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        // Left active indicator
                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: 3
                            height: 18
                            radius: 1.5
                            color: Theme.accentLight
                            visible: itemRow.isSelected
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: itemRow.isSelected ? 10 : 8
                            anchors.rightMargin: 10
                            spacing: 10

                            // App Icon
                            Item {
                                Layout.preferredWidth: 22
                                Layout.preferredHeight: 22

                                IconImage {
                                    id: iconImg
                                    anchors.fill: parent
                                    source: modelData && modelData.icon ? Quickshell.iconPath(modelData.icon) : ""
                                    visible: iconImg.status === Image.Ready
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 4
                                    color: Theme.surfaceElevated
                                    visible: !iconImg.visible

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData && modelData.name ? modelData.name.charAt(0).toUpperCase() : "•"
                                        font.pixelSize: 10
                                        font.bold: true
                                        font.family: Theme.fontFamily
                                        color: Theme.accent
                                    }
                                }
                            }

                            // App Name
                            Text {
                                Layout.fillWidth: true
                                text: modelData ? modelData.name : ""
                                font.pixelSize: 11
                                font.bold: itemRow.isSelected
                                font.family: Theme.fontFamily
                                color: itemRow.isSelected ? Theme.textPrimary : Theme.textSecondary
                                elide: Text.ElideRight
                            }

                            // Category / Comment (dimmed)
                            Text {
                                text: modelData ? (modelData.genericName || modelData.comment || "") : ""
                                font.pixelSize: 10
                                font.family: Theme.fontFamily
                                color: Theme.textMuted
                                elide: Text.ElideRight
                                Layout.maximumWidth: 160
                                visible: text.length > 0
                            }
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                drawerRoot.selectedIndex = index;
                                modelData.execute();
                                drawerRoot.close();
                            }
                        }
                    }
                }

                // Empty state
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: drawerRoot.filteredApps.length === 0
                    spacing: 4

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No matches found"
                        font.pixelSize: 12
                        font.bold: true
                        font.family: Theme.fontFamily
                        color: Theme.textMuted
                    }
                }
            }
        }
    }
}
