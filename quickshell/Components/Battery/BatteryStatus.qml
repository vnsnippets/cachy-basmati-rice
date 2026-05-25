import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Assets
import qs.Components

Clickable {
    id: root
    radius: Style.radius - 4

    colors.background.idle: Qt.alpha(Style.colors.surface, 0.60)
    colors.background.active: Qt.alpha(Style.colors.surface, 0.75)

    colors.border.idle: "transparent"
    colors.border.active: "transparent"

    clip: true

    readonly property var device: UPower.displayDevice
    readonly property real batteryPercentage: device.percentage * 100
    readonly property bool isPluggedIn: root.device.state === UPowerDeviceState.Charging || root.device.state === UPowerDeviceState.PendingCharge

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.spacing * 2

        ArcControl {
            Layout.leftMargin: Style.padding/2

            readonly property int targetHeight: root.height - Style.padding
            implicitHeight: targetHeight
            implicitWidth: targetHeight

            showText: true

            arcColor: {
                if (root.device.state === UPowerDeviceState.Charging) {
                    return Style.colors.yellow
                } else if (root.batteryPercentage <= Context.battery.criticalLimit) {
                    return Style.colors.red
                } else if (root.batteryPercentage <= Context.battery.warningLimit) {
                    return Style.colors.yellow
                } else {
                    return Style.colors.green
                }
            }

            trackColor: Qt.alpha(Style.colors.subtext, 0.1)
            target: root.device.percentage * 100
        }

        ColumnLayout {
            spacing: Style.spacing/2
            Layout.alignment: Qt.AlignVCenter
            Layout.margins: Style.padding
            Layout.leftMargin: 0
            
            RowLayout {
                Layout.fillWidth: true
                
                StyledText {
                    Layout.fillWidth: false
                    Layout.preferredWidth: implicitWidth
                    Layout.alignment: Qt.AlignVCenter
                    
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    
                    color: Style.colors.subtext
                    text: root.isPluggedIn ? "" : ["", "", "", "", ""][Math.min(4, Math.floor(root.batteryPercentage / 21))]
                }
                
                StyledText {
                    Layout.fillWidth: true
                    Layout.preferredWidth: implicitWidth
                    Layout.alignment: Qt.AlignVCenter
                    
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    
                    color: Style.colors.subtext
                    text: (root.isPluggedIn) ? "Plugged" : "Battery"
                }
            }

            StyledText {
                Layout.fillWidth: true

                horizontalAlignment: Text.AlignLeft
                color: Style.colors.text

                readonly property bool isCharging: root.device.state === UPowerDeviceState.Charging || root.device.state === UPowerDeviceState.PendingCharge
                text: {
                    if (root.device.state === UPowerDeviceState.Charging) return "Full in: " + secondsToHoursAndMinutesString(device.timeToFull);
                    if (root.device.state === UPowerDeviceState.Discharging) return "ETA: " + secondsToHoursAndMinutesString(device.timeToEmpty);
                    return "Not Charging";
                }

                function secondsToHoursAndMinutesString(totalSeconds) {
                    const total = Math.floor(totalSeconds);
                    const hours = Math.floor(total / 3600);
                    const minutes = Math.floor((total % 3600) / 60);

                    return `${hours.toString().padStart(2,'0')}:${minutes.toString().padStart(2,'0')}`
                }
            }
        }
    }
}