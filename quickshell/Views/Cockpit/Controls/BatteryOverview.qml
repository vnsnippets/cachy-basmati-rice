import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Styles
import qs.Controls

Clickable {
    id: root
    radius: Style.panel.radius - 4
    colors.background.idle: Qt.alpha(Style.colors.surface, 0.5)
    colors.background.active: Qt.alpha(Style.colors.surface, 0.75)

    colors.border.idle: "transparent"
    colors.border.active: "transparent"

    readonly property var device: UPower.displayDevice
    readonly property real batteryPercentage: device.percentage * 100
    readonly property bool isPluggedIn: root.device.state === UPowerDeviceState.Charging || root.device.state === UPowerDeviceState.PendingCharge

    clip: true

    RowLayout {
        id: layout
        spacing: Style.panel.padding/2
        anchors.left: parent.left
        anchors.right: parent.right

        // Clickable {
        //     Layout.margins: Style.panel.padding
        //     Layout.rightMargin: 0

        //     implicitHeight: parent.height - (Style.panel.padding * 2)
        //     implicitWidth: parent.height - (Style.panel.padding * 2)
        // }

        ArcControl {
            Layout.margins: Style.panel.padding/2
            Layout.rightMargin: 0
    
            implicitHeight: root.implicitHeight - Style.panel.padding
            implicitWidth: root.implicitHeight - Style.panel.padding

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
            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.margins: Style.panel.padding
            Layout.leftMargin: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: false

                StyledText {
                    Layout.fillWidth: false
                    Layout.fillHeight: true
                    Layout.preferredWidth: implicitWidth
                    Layout.alignment: Qt.AlignVCenter
                    
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    
                    font.pixelSize: 18
                    color: Style.colors.subtext
                    text: ["\u{F1BC}", "\u{F1BE}", "\u{F1C0}", "\u{F1C2}", "\u{F1C4}", "\u{F1C6}", "\u{F1C8}", "\u{F1CA}", "\u{F1CC}", "\u{F1CE}", "\u{E14F}"][Math.min(4, Math.floor(root.batteryPercentage / 10))]
                    //root.isPluggedIn ? "\u{F0399}" : ["", "", "", "", ""][Math.min(4, Math.floor(root.batteryPercentage / 21))]
                }
                
                StyledText {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: implicitWidth
                    Layout.alignment: Qt.AlignVCenter
                    
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    
                    color: Style.colors.subtext
                    text: (root.isPluggedIn) ? "Plugged" : "Unplugged"
                }

                // BarStrength {
                //     // visible: NetworkMonitor.GlobalState >= 50
                //     Layout.fillWidth: true
                //     Layout.fillHeight: true
                //     Layout.preferredWidth: implicitWidth
                //     Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

                //     strength: root.batteryPercentage ?? 0
                //     dimensions: Qt.size(12, 12)
                    
                //     colors.active: {
                //         if (root.device.state === UPowerDeviceState.Charging) {
                //             return Style.colors.yellow
                //         } else if (root.batteryPercentage <= Context.battery.criticalLimit) {
                //             return Style.colors.red
                //         } else if (root.batteryPercentage <= Context.battery.warningLimit) {
                //             return Style.colors.yellow
                //         } else {
                //             return Style.colors.green
                //         }
                //     }

                //     blinkLastActive: root.device.state === UPowerDeviceState.Charging
                //     length: 4
                // }

                // StyledText {
                //     Layout.fillWidth: false
                //     Layout.fillHeight: true
                //     Layout.preferredWidth: implicitWidth
                //     Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    
                //     color: Style.colors.text
                //     text: root.batteryPercentage + "%"
                // }
            }

            StyledText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter

                horizontalAlignment: Text.AlignLeft
                color: Style.colors.text

                readonly property bool isCharging: root.device.state === UPowerDeviceState.Charging || root.device.state === UPowerDeviceState.PendingCharge
                text: {
                    if (root.device.state === UPowerDeviceState.Charging) return "Full in: " + secondsToHoursAndMinutesString(device.timeToFull);
                    if (root.device.state === UPowerDeviceState.Discharging) return secondsToHoursAndMinutesString(device.timeToEmpty);
                    return "Charging paused";
                }
            }
        }
    }
}