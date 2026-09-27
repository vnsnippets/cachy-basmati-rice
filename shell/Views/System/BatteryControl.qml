import QtQuick

import Quickshell.Services.UPower

import qs
import qs.Components

ClickableWithIcon {
    id: root
    
    readonly property var device: UPower.displayDevice
    readonly property bool charging: root.device.state === UPowerDeviceState.Charging || root.device.state === UPowerDeviceState.PendingCharge
    readonly property real batterypercentage: root.device.percentage

    radius: Constants.radius

    property var datamap: {
        if (root.charging) return {
            icon:           "battery-charge.svg",
        };

        const icons = [ "battery-empty.svg", "battery-low.svg", "battery-medium.svg", "battery-high.svg", "battery-full.svg" ];

        const targetIndex = Math.floor(root.batterypercentage * icons.length);
        const safeIndex =   Math.min(Math.max(0, targetIndex), icons.length - 1);

        return {
            icon:           icons[safeIndex],
            accent:         (root.batterypercentage <= Constants.battery_threshold_critical) ? Constants.battery_color_critical :
                                (root.batterypercentage <= Constants.battery_threshold_warning) ? Constants.battery_color_warning :
                                    Constants.battery_color_default
        };
    }

    size: Constants.icon_size
    padding: Constants.padding / 1.5
    leftPadding: Constants.padding
    rightPadding: Constants.padding
    iconname: datamap.icon

    styles.background.color: [ Constants.battery_color_background, datamap.accent ]
    styles.icon.color: [ datamap.accent, Constants.battery_color_text_active ]

    palette.buttonText: (hovered || active) ? Constants.battery_color_text_active : datamap.accent

    font.family: Constants.font_family
    font.pixelSize: Constants.font_size
    text: Math.floor(root.batterypercentage * 100) + "%"
}