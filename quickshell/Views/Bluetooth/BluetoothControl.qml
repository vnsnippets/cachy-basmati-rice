import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Bluetooth

import qs
import qs.Types
import qs.Services
import qs.Utilities
import qs.Components

ClickableWithIcon {
    id: root

    property bool active: false
    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter

    property var datamap: switch (adapter?.state ?? true) {
        // case (BluetoothAdapterState.Enabling): return {
        //     label:  "Activating...",
        //     accent: Styles.bluetooth.pill.colors.busy
        // }
        // case (BluetoothAdapterState.Disabling): return {
        //     label:  "Deactivating...",
        //     accent: Styles.bluetooth.pill.colors.busy
        // }
        case (BluetoothAdapterState.Disabled): return {
            label:  "Bluetooth",
            accent: Styles.bluetooth.pill.colors.disabled
        }
        case (BluetoothAdapterState.Enabled): return {
            label:  "Bluetooth",
            accent: Styles.bluetooth.pill.colors.enabled
        }
        case (BluetoothAdapterState.Blocked): return {
            label:  "Bluetooth",
            accent: Styles.bluetooth.pill.colors.blocked
        }
        default: return {
            label:  "Bluetooth",
            accent: Styles.colors.text
        }
    }

    size: Styles.bluetooth.pill.size
    padding: Styles.padding / 1.5
    leftPadding: Styles.padding
    rightPadding: Styles.padding
    iconname: Styles.bluetooth.icon

    enablebackground: true

    backgroundstyle.idle: (active) ? datamap.accent : Styles.bluetooth.pill.colors.background
    backgroundstyle.active: datamap.accent

    iconstyle.idle: (hovered || active) ? Styles.bluetooth.pill.colors.text : datamap.accent
    iconstyle.active: Styles.bluetooth.pill.colors.text

    palette.buttonText: (hovered || active) ? Styles.bluetooth.pill.colors.text : datamap.accent

    font.family: Styles.font.family
    font.pixelSize: Styles.font.size
    text: datamap.label

    Component.onCompleted: Debug.log("[Bluetooth]\t", (adapter?.enabled) ? "Enabled" : "Disabled")
}