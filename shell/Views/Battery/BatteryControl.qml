pragma ComponentBehavior: Bound

import QtQuick

import Quickshell.Services.UPower

import qs
import qs.Components

ClickableWithIcon {
    id: root
    
    readonly property var device: UPower.displayDevice
    readonly property bool charging: root.device.state === UPowerDeviceState.Charging || root.device.state === UPowerDeviceState.PendingCharge
    readonly property real batterypercentage: root.device.percentage

    property var datamap: {
        if (root.charging) return {
            icon:   "battery-charge.svg",
            accent: Constants.battery_control_color_charging
        };

        const icons = [ "battery-empty.svg", "battery-low.svg", "battery-medium.svg", "battery-high.svg", "battery-full.svg" ];

        const targetIndex = Math.floor(root.batterypercentage * icons.length);
        const safeIndex =   Math.min(Math.max(0, targetIndex), icons.length - 1);

        return {
            icon:   icons[safeIndex],
            accent: (root.batterypercentage <= Constants.battery_threshold_critical) ? Constants.battery_control_color_critical :
                    (root.batterypercentage <= Constants.battery_threshold_warning) ? Constants.battery_control_color_warning :
                        Constants.battery_control_color_default
        };
    }

    size: Constants.icon_size
    padding: Constants.padding 
    leftPadding: Constants.padding
    rightPadding: Constants.padding

    styles.background_color_idle: Constants.battery_control_color_background
    styles.background_color_active: datamap.accent
    styles.icon_color_idle: datamap.accent
    styles.icon_color_active: Constants.battery_control_color_text_active

    styles.border_width: 1
    styles.border_color_idle: Constants.battery_control_color_border
    styles.border_color_active: datamap.accent

    styles.text_color_idle: datamap.accent
    styles.text_color_active: Constants.battery_control_color_text_active

    font.family: Constants.font_family
    text: Math.floor(root.batterypercentage * 100) + "%"
    iconname: datamap.icon

    radius: (active) ? Constants.icon_size : Constants.radius
    Behavior on radius { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
}