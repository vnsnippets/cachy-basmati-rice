import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Types
import qs.Utilities
import qs.Components

ClickableWithIcon {
    id: root

    property bool active: false

    readonly property var device: UPower.displayDevice
    readonly property bool charging: root.device.state === UPowerDeviceState.Charging || root.device.state === UPowerDeviceState.PendingCharge
    readonly property real batterypercentage: root.device.percentage

    property var datamap: {
        if (root.charging) return {
            icon:           "battery-charge.svg",
            highlighted:    true,
            accent:         Styles.battery.pill.colors.charging
        };

        const icons = [ "battery-empty.svg", "battery-low.svg", "battery-medium.svg", "battery-high.svg", "battery-full.svg" ];

        const targetIndex = Math.floor(root.batterypercentage * icons.length);
        const safeIndex =   Math.min(Math.max(0, targetIndex), icons.length - 1);

        return {
            icon:           icons[safeIndex],
            highlighted:    (root.batterypercentage <= Styles.battery.thresholds.warning),
            accent:         (root.batterypercentage <= Styles.battery.thresholds.critical) ? Styles.battery.pill.colors.critical :
                                (root.batterypercentage <= Styles.battery.thresholds.warning) ? Styles.battery.pill.colors.warning :
                                    Styles.battery.pill.colors.text.idle
        };
    }

    size: Styles.battery.pill.size
    padding: Styles.padding / 1.5
    leftPadding: Styles.padding
    rightPadding: Styles.padding
    iconname: datamap.icon

    enablebackground: true

    backgroundstyle.idle: (active) ? datamap.accent : Styles.network.pill.colors.background
    backgroundstyle.active: datamap.accent

    iconstyle.idle: (hovered || active) ? Styles.network.pill.colors.text.active : datamap.accent
    iconstyle.active: Styles.network.pill.colors.text.active

    palette.buttonText: (hovered || active) ? Styles.network.pill.colors.text.active : datamap.accent

    font.family: Styles.font.family
    font.pixelSize: Styles.font.size
    text: Math.floor(root.batterypercentage * 100) + "%"
}