import QtQuick
import "../theme"

Rectangle {
    id: clockRoot
    implicitHeight: 20
    implicitWidth: clockRow.width + 12
    radius: Theme.radiusSm
    color: clockMouse.containsMouse ? Theme.surfaceHover : "transparent"
    border.color: clockMouse.containsMouse ? Theme.border : "transparent"
    border.width: 1

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    property var currentTime: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            clockRoot.currentTime = new Date();
        }
    }

    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clockRoot.currentTime, "ddd d MMM")
            font.pixelSize: 10
            font.bold: false
            font.family: Theme.fontFamily
            color: Theme.textMuted
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "•"
            font.pixelSize: 8
            color: Theme.borderHover
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clockRoot.currentTime, "hh:mm AP")
            font.pixelSize: 11
            font.bold: true
            font.family: Theme.fontFamily
            color: Theme.textPrimary
        }
    }

    MouseArea {
        id: clockMouse
        anchors.fill: parent
        hoverEnabled: true
    }
}
