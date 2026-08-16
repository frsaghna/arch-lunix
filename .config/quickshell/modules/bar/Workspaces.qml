import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../theme"

Item {
    id: wsRoot
    implicitHeight: 22
    implicitWidth: wsRow.width

    Row {
        id: wsRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: 8

            delegate: Rectangle {
                id: wsButton
                property int wsId: index + 1

                property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
                property bool isOccupied: {
                    if (isFocused) return true;
                    var list = Hyprland.workspaces.values;
                    for (var i = 0; i < list.length; i++) {
                        if (list[i] && list[i].id === wsId) return true;
                    }
                    return false;
                }

                width: isFocused ? 22 : (isOccupied ? 16 : 8)
                height: 16
                radius: Theme.radiusFull

                color: isFocused ? Theme.accent : (wsMouse.containsMouse ? Theme.surfaceHover : (isOccupied ? Theme.surfaceElevated : "transparent"))
                border.color: isFocused ? Theme.accentLight : "transparent"
                border.width: isFocused ? 1 : 0

                Behavior on width {
                    NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuad }
                }
                Behavior on color {
                    ColorAnimation { duration: Theme.animFast }
                }

                Text {
                    anchors.centerIn: parent
                    text: wsButton.wsId
                    font.pixelSize: 9
                    font.bold: wsButton.isFocused
                    font.family: Theme.fontFamily
                    color: wsButton.isFocused ? "#FFFFFF" : (wsButton.isOccupied ? Theme.textPrimary : Theme.textMuted)
                    visible: wsButton.isFocused || (wsButton.isOccupied && wsMouse.containsMouse)
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: wsButton.isOccupied ? 5 : 3
                    height: wsButton.isOccupied ? 5 : 3
                    radius: Theme.radiusFull
                    color: wsButton.isOccupied ? Theme.accentLight : Theme.textMuted
                    opacity: wsButton.isOccupied ? 0.8 : 0.4
                    visible: !wsButton.isFocused && !(wsButton.isOccupied && wsMouse.containsMouse)
                }

                MouseArea {
                    id: wsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Hyprland.dispatch("workspace " + wsButton.wsId);
                    }
                }
            }
        }
    }
}
