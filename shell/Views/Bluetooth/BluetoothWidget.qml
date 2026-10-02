pragma ComponentBehavior: Bound

import QtQuick

import Quickshell.Bluetooth

import qs
import qs.Components

// qmllint disable
ClickableWithIcon {
    id: root

    property var datamap: switch (Bluetooth.defaultAdapter.state ?? true) {
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
    padding: Constants.padding / 1.5
    iconname: "bluetooth.svg"

    styles.background_color_idle: Constants.bluetooth_color_background
    styles.background_color_active: datamap.accent

    styles.icon_color_idle: datamap.accent
    styles.icon_color_active: Constants.bluetooth_color_text_active

    // styles.border.width: 1
    // styles.border_color_idle: Constants.bluetooth_color_border

    palette.buttonText: (hovered || active) ? Constants.bluetooth_color_text_active : datamap.accent

    font.family: Constants.font_family
    // text: datamap.label

    onClicked: Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled ?? false
}