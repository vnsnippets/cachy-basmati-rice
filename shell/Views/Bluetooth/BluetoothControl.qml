pragma ComponentBehavior: Bound

import QtQuick

import Quickshell.Bluetooth

import qs
import qs.Components

ClickableWithIcon {
    id: root

    // qmllint disable
    readonly property var adapter: Bluetooth.defaultAdapter
    // qmllint enable

    property var datamap: switch (adapter.state ?? true) {
        case (BluetoothAdapterState.Enabling): return {
            label:  "Activating...",
            accent: Constants.bluetooth_color_busy
        }
        case (BluetoothAdapterState.Disabling): return {
            label:  "Deactivating...",
            accent: Constants.bluetooth_color_busy
        }
        case (BluetoothAdapterState.Disabled): return {
            label:  "Bluetooth",
            accent: Constants.bluetooth_color_disabled
        }
        case (BluetoothAdapterState.Enabled): return {
            label:  "Bluetooth",
            accent: Constants.bluetooth_color_enabled
        }
        case (BluetoothAdapterState.Blocked): return {
            label:  "Bluetooth",
            accent: Constants.bluetooth_color_blocked
        }
        default: return {
            label:  "Bluetooth",
            accent: Constants.bluetooth_color_default
        }
    }
    
    size: Constants.icon_size
    
    padding: Constants.padding
    iconname: "bluetooth.svg"

    styles.background_color_idle: Constants.bluetooth_color_background
    styles.background_color_active: datamap.accent

    styles.icon_color_idle: datamap.accent
    styles.icon_color_active: Constants.bluetooth_color_text_active

    styles.border_width: 1
    styles.border_color_idle: Constants.bluetooth_color_border
    styles.border_color_active: datamap.accent

    palette.buttonText: (hovered || active) ? Constants.bluetooth_color_text_active : datamap.accent

    font.family: Constants.font_family

    radius: (active) ? Constants.icon_size : Constants.radius
    Behavior on radius { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
}