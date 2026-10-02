pragma ComponentBehavior: Bound

import QtQuick

import Quickshell.Networking

import qs
import qs.Services
import qs.Components

ClickableWithIcon {
    id: root

    property var datamap: switch (NetworkService.activeNetwork?.device.type) {
        case (DeviceType.Wired): return {
            icon:           "ethernet.svg",
            label:          "Ethernet",
            highlighted:    false,
            accent:         Constants.network_color_default
        }

        case (DeviceType.Wifi):
            const icons =       [ "wifi-empty.svg", "wifi-low.svg", "wifi-medium.svg", "wifi-high.svg", "wifi-full.svg" ];
            const targetIndex = Math.floor(NetworkService.activeNetwork.signalStrength * icons.length);
            const safeIndex =   Math.min(Math.max(0, targetIndex), icons.length - 1);
            const iscritical =  NetworkService.activeNetwork.signalStrength <= Constants.network_threshold_critical
            const iswarning =   NetworkService.activeNetwork.signalStrength <= Constants.network_threshold_warning
            return {
                icon:           icons[safeIndex],
                label:          NetworkService.activeNetwork.name,
                highlighted:    (iscritical || iswarning),
                accent:         (iscritical) ? Constants.network_color_critical :
                                    (iswarning) ? Constants.network_color_warning :
                                        Constants.network_color_default
            }

        default: return {
            icon:          "wifi-disconnect.svg",
            label:         "Not Connected",
            highlighted:    false,
            accent:         Constants.network_color_default
        }
    }

    size: Constants.icon_size 
    padding: Constants.padding
    leftPadding: Constants.padding
    rightPadding: Constants.padding
    iconname: datamap.icon
    radius: Constants.radius

    styles.background_color_idle: Constants.network_color_background
    styles.background_color_active: datamap.accent
    styles.icon_color_idle: datamap.accent
    styles.icon_color_active: Constants.network_color_text_active

    styles.border_width: 1
    styles.border_color_idle: Constants.network_color_border
    styles.border_color_active: datamap.accent

    palette.buttonText: (hovered || active) ? Constants.network_color_text_active : datamap.accent

    font.family: Constants.font_family
    text: datamap.label
}