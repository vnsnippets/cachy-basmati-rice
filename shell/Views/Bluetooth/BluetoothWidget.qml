pragma ComponentBehavior: Bound

import QtQuick

import Quickshell.Bluetooth

import qs
import qs.Utilities
import qs.Components

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

    styles.background.color: [ Constants.bluetooth_color_background, datamap.accent ]
    styles.icon.color: [ datamap.accent, Constants.bluetooth_color_text_active ]

    palette.buttonText: (hovered || active) ? Constants.bluetooth_color_text_active : datamap.accent

    font.family: Constants.font_family
    font.pixelSize: Constants.font_size
    // text: datamap.label

    onClicked: Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled ?? false
}