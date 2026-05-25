import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Bluetooth

import qs.Assets
import qs.Utilities
import qs.Components

ColumnLayout {
    id: root
    spacing: Style.spacing * 4
    // Expects a BluetoothAdapter instance to be provided
    property BluetoothAdapter adapter: Bluetooth.defaultAdapter

    readonly property color activeColor: Style.colors.green

    StyledText {
        Layout.alignment: Qt.AlignLeft
        Layout.leftMargin: Style.padding
        Layout.rightMargin: Style.padding
        text: "Bluetooth"
        color: Style.colors.text
        font.bold: true
    }

    // --- Header Section: Adapter Status & Scan Control ---
    RowLayout {
        Layout.leftMargin: Style.padding
        Layout.rightMargin: Style.padding
        Layout.fillWidth: true
        spacing: Style.spacing

        StyledText {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            
            // Map the BluetoothAdapterState enum to clean UI indicators
            readonly property var stateMap: ({
                [BluetoothAdapterState.Blocked]: { icon: "󰂲", color: Style.colors.red },
                [BluetoothAdapterState.Disabled]: { icon: "󰂲", color: Style.colors.red },
                [BluetoothAdapterState.Disabling]: { icon: "󱥸", color: Style.colors.peach },
                [BluetoothAdapterState.Enabling]: { icon: "󱥸", color: Style.colors.peach },
                [BluetoothAdapterState.Enabled]: { icon: "󰄯", color: activeColor },
            })

            horizontalAlignment: Text.AlignLeft
            color: adapter ? stateMap[adapter.state].color : Style.colors.red
            text: adapter ? (stateMap[adapter.state].icon + " " + BluetoothAdapterState.toString(adapter.state)) : "󰄰 No Adapter Detected"
        }

        StyledText {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.rightMargin: Style.spacing
            color: Style.colors.text
            text: "Scan Devices"
        }

        Clickable {
            id: scanToggle
            enabled: adapter && adapter.state === BluetoothAdapterState.Enabled

            colors.background.idle: (adapter && adapter.discovering) ? activeColor : Style.colors.surface
            colors.background.active: colors.background.idle

            implicitWidth: 20
            implicitHeight: 20
            radius: 4
            borderWidth: 0
            
            onClicked: {
                if (adapter) {
                    adapter.discovering = !adapter.discovering;
                }
            }

            StyledText {
                anchors.centerIn: parent
                font.pixelSize: 12
                active: scanToggle.containsMouse
                style.idle: (adapter && adapter.discovering) ? Style.colors.base : Style.colors.text
                style.active: style.idle
                text: (adapter && adapter.discovering) ? "󰄯" : "󰄰"
            }
        }
    }

    // --- Helper Component for Device Rows ---
    component DeviceRow : Rectangle {
        Layout.fillWidth: true
        height: 48
        radius: Style.radius / 2
        color: "transparent"

        property BluetoothDevice device: null
        onDeviceChanged: Debug.log("Name:", device.name, "| Device Name:", device.deviceName, "| Address:", device.address)

        // Highlight connected or connecting devices
        border.color: (device.state === BluetoothDeviceState.Connected) 
            ? activeColor 
            : Qt.alpha(Style.colors.surface, 0.60)
        border.width: 1

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.spacing * 2

            StyledText {
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                leftPadding: Style.padding
                text: device.deviceName || device.address || "Unknown Device"
                color: Style.colors.text
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
            }

            // Spinner animation while connecting or disconnecting
            StyledText {
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                visible: device.state === BluetoothDeviceState.Connecting

                text: "󱥸"
                
                Behavior on rotation { NumberAnimation { duration: 200 } }
                RotationAnimation on rotation {
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                    running: device.state === BluetoothDeviceState.Connecting
                }
            }

            Item { Layout.fillWidth: true }

            StyledText {
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                visible: device.state === BluetoothDeviceState.Connected

                color: Style.colors.subtext
                text: "Connected"
            }

            Clickable {
                id: connectToggle
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.rightMargin: Style.padding
                
                // Hide button while state transition is in progress
                visible: device.state !== BluetoothDeviceState.Connecting

                colors.background.idle: (device.state === BluetoothDeviceState.Connected) 
                    ? Style.colors.red 
                    : Style.colors.green
                colors.background.active: colors.background.idle

                implicitWidth: 28
                implicitHeight: 28
                radius: 4
                borderWidth: 0
                
                onClicked: {
                    if (device.state === BluetoothDeviceState.Connected) {
                        device.disconnect();
                    } else {
                        device.connect();
                    }
                }

                StyledText {
                    anchors.centerIn: parent
                    font.pixelSize: 16
                    active: connectToggle.containsMouse
                    style.idle: Style.colors.base
                    style.active: style.idle
                    text: ""
                }
            }
        }
    }

    // --- Section: Connected / Paired Devices ---
    StyledText {
        Layout.leftMargin: Style.padding
        Layout.rightMargin: Style.padding
        text: "Connected & Paired"
        color: Style.colors.subtext
        font.bold: true
        visible: adapter && pairedRepeater.count > 0
    }

    Repeater {
        id: pairedRepeater
        // Filters devices from the adapter's devices list that are paired or connected
        model: {
            if (!adapter || !adapter.devices) return [];
            return adapter.devices.values.filter(function(dev) {
                return dev.paired || dev.state === BluetoothDeviceState.Connected;
            });
        }
        
        delegate: DeviceRow {
            Layout.leftMargin: Style.padding
            Layout.rightMargin: Style.padding
            device: modelData
        }
    }

    // --- Section: Named available devices ---
    StyledText {
        Layout.leftMargin: Style.padding
        Layout.rightMargin: Style.padding
        text: "Available Devices"
        color: Style.colors.subtext
        font.bold: true
        visible: adapter && availableRepeater.count > 0
    }

    Repeater {
        id: availableRepeater
        // Filters devices that are discovered but neither paired nor currently connected
        model: {
            if (!adapter || !adapter.devices) return [];
            return adapter.devices.values.filter(function(dev) {
                // Only show discovered devices that have an actual name
                return !dev.paired && 
                    dev.state !== BluetoothDeviceState.Connected && 
                    dev.deviceName; 
            });
        }
        
        delegate: DeviceRow {
            Layout.leftMargin: Style.padding
            Layout.rightMargin: Style.padding
            device: modelData
        }
    }

    // --- Section: Other devices (unnamed) ---
    StyledText {
        Layout.leftMargin: Style.padding
        Layout.rightMargin: Style.padding
        text: "Unidentified Devices"
        color: Style.colors.subtext
        font.bold: true
        visible: adapter && otherRepeater.count > 0
    }

    Repeater {
        id: otherRepeater
        // Filters devices that are discovered but neither paired nor currently connected
        model: {
            if (!adapter || !adapter.devices) return [];
            return adapter.devices.values.filter((dev) =>  !dev.paired && dev.state !== BluetoothDeviceState.Connected &&  !dev.deviceName);
        }
        
        delegate: DeviceRow {
            Layout.leftMargin: Style.padding
            Layout.rightMargin: Style.padding
            device: modelData
        }
    }
}