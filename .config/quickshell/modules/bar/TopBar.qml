import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: barRoot

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 4
        left: 8
        right: 8
    }

    implicitHeight: 30
    exclusiveZone: 30

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-topbar"

    color: "transparent"

    Rectangle {
        id: barCard
        anchors.fill: parent
        radius: Theme.radiusFull
        color: Theme.background
        border.color: Theme.border
        border.width: 1

        // ================= LEFT: WORKSPACES =================
        Workspaces {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
        }

        // ================= CENTER: CLOCK & DATE =================
        ClockWidget {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        // ================= RIGHT: BATTERY =================
        BatteryWidget {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
