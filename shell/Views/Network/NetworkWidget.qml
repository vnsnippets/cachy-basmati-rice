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
    padding: Constants.padding / 1.5
    leftPadding: Constants.padding
    rightPadding: Constants.padding
    iconname: datamap.icon

    styles.background.color: [ Constants.network_color_background, datamap.accent ]
    styles.icon.color: [ datamap.accent, Constants.network_color_text_active ]

    palette.buttonText: (hovered || active) ? Constants.network_color_text_active : datamap.accent

    font.family: Constants.font_family
    font.pixelSize: Constants.font_size
    text: datamap.label
}