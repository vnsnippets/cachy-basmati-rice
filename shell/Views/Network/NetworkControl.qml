pragma ComponentBehavior: Bound

import QtQuick

import Quickshell.Networking

import qs
import qs.Services
import qs.Components

ClickableWithIcon {
    id: root

    component DatamapModel: QtObject {
        property string icon: "wifi-error.svg"
        property string label: ""
        property bool highlighted: false
        property color accent: Constants.network_color_ink_default
    }

    property DatamapModel datamap: DatamapModel {
        readonly property list<string> icons: [
            "wifi-empty.svg",
            "wifi-low.svg",
            "wifi-medium.svg",
            "wifi-high.svg",
            "wifi-full.svg"
        ]

        icon: {
            if (!Networking.wifiEnabled) return "wifi-disconnect.svg";

            const type = NetworkService.activeNetwork?.device.type;
            if (type === DeviceType.Wired) return "ethernet.svg";

            if (type === DeviceType.Wifi) {
                const targetIndex = Math.floor(NetworkService.activeNetwork.signalStrength * icons.length);
                const safeIndex = Math.min(Math.max(0, targetIndex), icons.length - 1);
                return icons[safeIndex];
            }

            return "wifi-disconnect.svg";
        }

        label: {
            const type = NetworkService.activeNetwork?.device.type;
            if (type === DeviceType.Wired) return "Ethernet";

            if (type === DeviceType.Wifi && NetworkService.activeNetwork) {
                const netName = NetworkService.activeNetwork.name;
                return Constants.network_scramble_ssid ? NetworkService.scramble(netName) : netName;
            }

            return "";
        }

        highlighted: {
            if (!Networking.wifiEnabled) return false;

            const type = NetworkService.activeNetwork?.device.type;
            if (type === DeviceType.Wifi && NetworkService.activeNetwork) {
                const strength = NetworkService.activeNetwork.signalStrength;
                return strength <= Constants.network_threshold_critical || strength <= Constants.network_threshold_warning;
            }

            return false;
        }

        accent: {
            if (!Networking.wifiEnabled) return Constants.network_color_ink_default;

            const type = NetworkService.activeNetwork?.device.type;
            if (type === DeviceType.Wired) return Constants.network_color_active;

            if (type === DeviceType.Wifi && NetworkService.activeNetwork) {
                const strength = NetworkService.activeNetwork.signalStrength;
                if (strength <= Constants.network_threshold_critical) return Constants.network_color_critical;
                if (strength <= Constants.network_threshold_warning) return Constants.network_color_warning;
                return Constants.network_color_active;
            }

            return Constants.network_color_active;
        }
    }

    size: Constants.icon_size
    padding: Constants.padding
    leftPadding: Constants.padding
    rightPadding: (text.length > 0) ? Constants.padding * 1.25 : Constants.padding
    iconname: datamap.icon

    styles.background_color_idle: Constants.control_color_background_default
    styles.background_color_active: datamap.accent
    styles.icon_color_idle: datamap.accent
    styles.icon_color_active: Constants.network_color_ink_active

    styles.border_width: 1
    styles.border_color_idle: Constants.control_color_border_default
    styles.border_color_active: datamap.accent

    styles.text_color_idle: datamap.accent
    styles.text_color_active: Constants.network_color_ink_active

    font.family: Constants.font_family
    text: datamap?.label ?? ""

    radius: (active) ? Constants.icon_size : Constants.radius
    Behavior on radius { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
}