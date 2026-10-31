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

    component DatamapModel: QtObject {
        property string icon:   "Battery-Empty.svg"
        property color accent:  Constants.battery_color_charging
    }

    property DatamapModel datamap: DatamapModel {
        readonly property list<string> icons: [
            "Battery-Empty.svg",
            "Battery-01.svg",
            "Battery-02.svg",
            "Battery-03.svg",
            "Battery-04.svg",
            "Battery-05.svg",
            "Battery-06.svg",
            "Battery-Full.svg",
        ]

        icon: {
            if (root.charging) return "Battery-Charge.svg";
            const targetIndex = Math.floor(root.batterypercentage * icons.length);
            const safeIndex = Math.min(Math.max(0, targetIndex), icons.length - 1);
            return icons[safeIndex];
        }

        accent: {
            if (root.charging) return Constants.battery_color_charging;
            if (root.batterypercentage <= Constants.battery_threshold_critical) return Constants.battery_color_critical;
            if (root.batterypercentage <= Constants.battery_threshold_warning) return Constants.battery_color_warning;
            return Constants.battery_color_ink_default;
        }
    }

    size: Constants.icon_size
    padding: Constants.padding 
    leftPadding: Constants.padding
    rightPadding: Constants.padding

    styles.background_color_idle: Constants.control_color_background_default
    styles.background_color_active: datamap.accent
    styles.icon_color_idle: datamap.accent
    styles.icon_color_active: Constants.battery_color_ink_active

    styles.border_width: 1
    styles.border_color_idle: Constants.control_color_border_default
    styles.border_color_active: datamap.accent

    styles.text_color_idle: datamap.accent
    styles.text_color_active: Constants.battery_color_ink_active

    font.family: Constants.font_family
    text: Math.floor(root.batterypercentage * 100) + "%"
    iconname: datamap.icon

    radius: (active) ? Constants.radius_active : Constants.radius
    Behavior on radius { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
}