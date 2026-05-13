import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Types
import qs.Styles
import qs.Controls

Clickable {
    id: root
    implicitWidth: content.width + Style.clickable.padding * 2

    // Defaults to references
    required property color color_critical
    required property color color_warning
    required property color color_charging
    required property color color_default

    property int batteryPercentage: Math.round(device.percentage * 100)

    property bool isCharging: device.state === UPowerDeviceState.Charging || device.state === UPowerDeviceState.PendingCharge

    readonly property var device: UPower.displayDevice
    readonly property color textColor: {
        if (device.state === UPowerDeviceState.Charging) return color_charging;
        if (batteryPercentage <= Context.battery.criticalLimit) return color_critical;
        if (batteryPercentage <= Context.battery.warningLimit) return color_warning;
        return color_default;
    }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: Style.clickable.spacing

        StyledText {
            id: icon
            text: isCharging ? "\u{E9AC}" : + ["\u{F1BC}", "\u{F1BE}", "\u{F1C0}", "\u{F1C2}", "\u{F1C4}", "\u{F1C6}", "\u{F1C8}", "\u{F1CA}", "\u{F1CC}", "\u{F1CE}", "\u{E14F}"][Math.min(4, Math.floor(batteryPercentage / 10))] 
            // isCharging ? "" : "\u{F0399}"  // ["", "", "", "", ""][Math.min(4, Math.floor(batteryPercentage / 21))]
            style.idle: root.textColor
            style.active: Style.colors.text
            active: root.containsMouse
            font.pixelSize: 18
        }

        StyledText {
            id: label
            text: batteryPercentage + "%"
            style.idle: root.textColor
            style.active: Style.colors.text
            active: root.containsMouse
        }
    }
}
