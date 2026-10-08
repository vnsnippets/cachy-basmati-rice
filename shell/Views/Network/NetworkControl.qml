pragma ComponentBehavior: Bound

import QtQuick

import Quickshell.Networking

import qs
import qs.Services
import qs.Components

ClickableWithIcon {
    id: root

    property var datamap: {
        if (!Networking.wifiEnabled) return {
            icon:          "wifi-disconnect.svg",
            highlighted:    false,
            accent:         Constants.network_color_ink_muted
        }
        
        switch (NetworkService.activeNetwork?.device.type) {
            case (DeviceType.Wired): return {
                icon:           "ethernet.svg",
                label:          "Ethernet",
                highlighted:    false,
                accent:         Constants.network_color_active
            }

            case (DeviceType.Wifi):
                const icons =       [ "wifi-empty.svg", "wifi-low.svg", "wifi-medium.svg", "wifi-high.svg", "wifi-full.svg" ];
                const targetIndex = Math.floor(NetworkService.activeNetwork.signalStrength * icons.length);
                const safeIndex =   Math.min(Math.max(0, targetIndex), icons.length - 1);
                const iscritical =  NetworkService.activeNetwork.signalStrength <= Constants.network_threshold_critical
                const iswarning =   NetworkService.activeNetwork.signalStrength <= Constants.network_threshold_warning
                
                return {
                    icon:           icons[safeIndex],
                    label:          (Constants.network_hide_ssid) ? "" : NetworkService.activeNetwork.name,
                    highlighted:    (iscritical || iswarning),
                    accent:         (iscritical) ? Constants.network_color_destruct :
                                        (iswarning) ? Constants.network_color_warning :
                                            Constants.network_color_active
                }

            default: return {
                icon:          "wifi-disconnect.svg",
                highlighted:    false,
                accent:         Constants.network_color_active
            }
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

    palette.buttonText: (hovered || active) ? Constants.network_color_ink_active : datamap.accent

    font.family: Constants.font_family
    text: datamap?.label ?? ""

    radius: (active) ? Constants.icon_size : Constants.radius
    Behavior on radius { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
}