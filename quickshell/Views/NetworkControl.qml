import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Networking

import qs
import qs.Types
import qs.Services
import qs.Utilities
import qs.Components

ClickableWithIcon {
    id: root

    property bool active: false
    readonly property Network activenetwork: NetworkService.activeNetwork ?? null

    property var datamap: switch (activenetwork?.device.type) {
        case (DeviceType.Wired): return {
            icon:           "ethernet.svg",
            label:          "Ethernet",
            highlighted:    false,
            accent:         Styles.network.pill.colors.text.idle
        }

        case (DeviceType.Wifi):
            const icons =       [ "wifi-empty.svg", "wifi-low.svg", "wifi-medium.svg", "wifi-high.svg", "wifi-full.svg" ];
            const targetIndex = Math.floor(activenetwork.signalStrength * icons.length);
            const safeIndex =   Math.min(Math.max(0, targetIndex), icons.length - 1);
            const iscritical =  activenetwork.signalStrength <= Styles.network.thresholds.critical
            const iswarning =   activenetwork.signalStrength <= Styles.network.thresholds.warning
            return {
                icon:           icons[safeIndex],
                label:          activenetwork.name,
                highlighted:    (iscritical || iswarning),
                accent:         (iscritical) ? Styles.network.pill.colors.critical :
                                    (iswarning) ? Styles.network.pill.colors.warning :
                                        Styles.network.pill.colors.text.idle
            }

        default: return {
            icon:          "wifi-disconnect.svg",
            label:         "Not Connected",
            highlighted:    false,
            accent:         Styles.network.pill.colors.text.idle
        }
    }

    size: Styles.network.pill.size
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
    text: datamap.label
}