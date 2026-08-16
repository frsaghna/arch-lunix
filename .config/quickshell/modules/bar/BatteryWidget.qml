import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "../theme"

Item {
    id: batRoot
    
    readonly property bool hasBattery: UPower.displayDevice !== null && 
                                       UPower.displayDevice.isPresent && 
                                       (UPower.displayDevice.isLaptopBattery || UPower.displayDevice.percentage > 0)
    
    visible: hasBattery
    implicitHeight: 20
    implicitWidth: visible ? (batRow.width + 4) : 0

    readonly property real rawPercent: UPower.displayDevice ? UPower.displayDevice.percentage : 0
    readonly property int percent: Math.round(rawPercent <= 1.0 ? (rawPercent * 100) : rawPercent)
    readonly property bool isCharging: UPower.displayDevice ? (UPower.displayDevice.state === UPowerDeviceState.Charging) : false
    readonly property bool isLow: !isCharging && percent > 0 && percent <= 20

    Row {
        id: batRow
        anchors.centerIn: parent
        spacing: 4

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: batRoot.isCharging ? "⚡" : (batRoot.percent >= 80 ? "󰁹" : (batRoot.percent >= 30 ? "󰁾" : "󰁺"))
            font.pixelSize: 11
            color: batRoot.isCharging ? Theme.warning : (batRoot.isLow ? Theme.danger : Theme.accentLight)
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: batRoot.percent + "%"
            font.pixelSize: 10
            font.bold: true
            font.family: Theme.fontFamily
            color: batRoot.isLow ? Theme.danger : Theme.textSecondary
        }
    }
}
