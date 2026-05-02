import QtQuick
import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Styles
import qs.Widgets

Clickable {
    id: root
    required property Component popup

    // Defaults to references
    property color color_critical: Style.color_red
    property color color_warning: Style.color_yellow
    property color color_charging: Style.color_yellow
    property color color_default: Style.color_green

    readonly property var device: UPower.displayDevice
    property int batteryPercentage: Math.round(device.percentage * 100)

    property bool isCharging: device.state === UPowerDeviceState.Charging || device.state === UPowerDeviceState.PendingCharge

    // Display
    icon: isCharging ? "" : ["", "", "", "", ""][Math.min(4, Math.floor(batteryPercentage / 21))]
    label: batteryPercentage + "%"

    // Style logic
    style.text.idle: {
        if (root.device.state === UPowerDeviceState.Charging) return color_charging;
        if (batteryPercentage <= Context.battery.criticalLimit) return color_critical;
        if (batteryPercentage <= Context.battery.warningLimit) return color_warning;
        return color_default;
    }

    onClicked: canvas.handleWidgetPopup(this);
}
