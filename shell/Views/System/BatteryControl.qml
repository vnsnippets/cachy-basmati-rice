import QtQuick

import Quickshell.Services.UPower

import qs
import qs.Types
import qs.Components

ClickableWithIcon {
    id: root

    readonly property color color_background: Constants.color_surface

    readonly property color color_charging: Constants.color_yellow
    readonly property color color_warning: Constants.color_peach
    readonly property color color_critical: Constants.color_red
    readonly property color color_default: Constants.color_text
    
    readonly property var device: UPower.displayDevice
    readonly property bool charging: root.device.state === UPowerDeviceState.Charging || root.device.state === UPowerDeviceState.PendingCharge
    readonly property real batterypercentage: root.device.percentage

    radius: Constants.radius

    property var datamap: {
        if (root.charging) return {
            icon:           "battery-charge.svg",
            highlighted:    true,
            accent:         root.color_charging
        };

        const icons = [ "battery-empty.svg", "battery-low.svg", "battery-medium.svg", "battery-high.svg", "battery-full.svg" ];

        const targetIndex = Math.floor(root.batterypercentage * icons.length);
        const safeIndex =   Math.min(Math.max(0, targetIndex), icons.length - 1);

        return {
            icon:           icons[safeIndex],
            highlighted:    (root.batterypercentage <= root.color_warning),
            accent:         (root.batterypercentage <= Constants.battery_critical_threshold) ? root.color_critical :
                                (root.batterypercentage <= Constants.battery_warning_threshold) ? root.color_warning :
                                    root.color_default
        };
    }

    size: Constants.size / 2
    padding: Constants.padding / 1.5
    leftPadding: Constants.padding
    rightPadding: Constants.padding
    iconname: datamap.icon

    styles.background.color.idle: (active) ? datamap.accent : root.color_background
    styles.background.color.active: datamap.accent

    styles.icon.color.idle: datamap.accent
    styles.icon.color.active: Constants.color_text_accent

    // styles.border.color: (hovered || active) ? datamap.accent: Constants.color_overlay
    // styles.border.width: 1

    palette.buttonText: (hovered || active) ? Constants.color_text_accent : datamap.accent

    font.family: Constants.font_family
    font.pixelSize: Constants.font_size
    text: Math.floor(root.batterypercentage * 100) + "%"
}