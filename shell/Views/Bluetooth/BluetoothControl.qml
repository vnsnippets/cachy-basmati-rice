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

    component DatamapModel: QtObject {
        property string label: "Bluetooth"
        property string icon: "Bluetooth-Off.svg"
        property color accent: Constants.bluetooth_color_critical
    }

    QtObject {
        id: states
        property DatamapModel enabling: DatamapModel {
            icon: "Bluetooth-On.svg"
            accent: Constants.bluetooth_color_busy
        }
        property DatamapModel disabling: DatamapModel {
            icon: "Bluetooth-Off.svg"
            accent: Constants.bluetooth_color_busy
        }
        property DatamapModel disabled: DatamapModel {
            icon: "Bluetooth-Off.svg"
            accent: Constants.bluetooth_color_ink_default
        }
        property DatamapModel enabled: DatamapModel {
            icon: "Bluetooth-On.svg"
            accent: Constants.bluetooth_color_active
        }
        property DatamapModel blocked: DatamapModel {
            icon: "Bluetooth-Error.svg"
            accent: Constants.bluetooth_color_critical
        }
        property DatamapModel unknown: DatamapModel {
            icon: "Bluetooth-Error.svg"
            accent: Constants.bluetooth_color_critical
        }
    }

    property DatamapModel statemap: switch (adapter.state ?? BluetoothAdapterState.Blocked) {
        case BluetoothAdapterState.Enabling: return states.enabling;
        case BluetoothAdapterState.Disabling: return states.disabling;
        case BluetoothAdapterState.Disabled: return states.disabled;
        case BluetoothAdapterState.Enabled: return states.enabled;
        case BluetoothAdapterState.Blocked: return states.blocked;
        default: return states.unknown;
    }

    property DatamapModel datamap: statemap ?? states.unknown

    size: Constants.icon_size

    padding: Constants.padding
    rightPadding: (text.length > 0) ? Constants.padding * 1.25 : Constants.padding

    iconname: datamap.icon
    styles.background_color_idle: Constants.control_color_background_default
    styles.background_color_active: datamap.accent

    styles.icon_color_idle: datamap.accent
    styles.icon_color_active: Constants.bluetooth_color_ink_active

    styles.border_width: 1
    styles.border_color_idle: Constants.control_color_border_default
    styles.border_color_active: datamap.accent

    styles.text_color_idle: datamap.accent
    styles.text_color_active: Constants.bluetooth_color_ink_active

    font.family: Constants.font_family

    radius: (active) ? Constants.radius_active : Constants.radius
    Behavior on radius { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
}