pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

import qs.Utilities

Singleton {
    id: root

    // --- Hardwired / Ethernet Adapters ---
    
    // List of all ethernet devices
    readonly property var wiredDevices: Networking.devices.values.filter(
        device => device.type === DeviceType.Wired
    )

    // The currently active/connected ethernet device (if any)
    readonly property var activeWiredDevice: Networking.devices.values.find(
        device => device.type === DeviceType.Wired && device.state === ConnectionState.Connected
    )


    // --- Wireless / Wi-Fi Adapters ---

    // List of all Wi-Fi devices
    readonly property var wirelessDevices: Networking.devices.values.filter(
        device => device.type === DeviceType.Wifi
    )

    // The currently active/connected Wi-Fi device (if any)
    readonly property var activeWirelessDevice: Networking.devices.values.find(
        device => device.type === DeviceType.Wifi && device.state === ConnectionState.Connected
    )


    // --- High-Level Global States (Convenience Helpers) ---

    // True if any adapter has internet access
    readonly property bool isConnected: activeWiredDevice !== undefined || activeWirelessDevice !== undefined

    // Returns the exact network object currently active (ethernet takes priority)
    readonly property var activeNetwork: {
        if (activeWiredDevice) {
            return activeWiredDevice.networks.values.find(net => net.connected);
        }
        if (activeWirelessDevice) {
            return activeWirelessDevice.networks.values.find(net => net.connected);
        }
        return null;
    }
}