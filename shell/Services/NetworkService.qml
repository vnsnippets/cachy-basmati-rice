pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

import qs.Utilities

Singleton {
    id: root
    property var channels: ({})

    // --- Hardwired / Ethernet Adapters ---
    
    // List of all ethernet devices
    readonly property var wiredDevices: Networking.devices.values.filter(
        device => device.type === DeviceType.Wired
    ) ?? [];

    // The currently active/connected ethernet device (if any)
    readonly property var activeWiredDevice: wiredDevices.find(
        device => device.state === ConnectionState.Connected
    )


    // --- Wireless / Wi-Fi Adapters ---

    // List of all Wi-Fi devices
    readonly property var wirelessDevices: Networking.devices.values.filter(
        device => device.type === DeviceType.Wifi
    ) ?? [];

    // The currently active/connected Wi-Fi device (if any)
    readonly property var activeWirelessDevice: wirelessDevices.find(
        device => device.state === ConnectionState.Connected
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

    Component.onCompleted: root.refreshChannels()

    Connections {
        target: Networking.devices

        // Triggers when network interfaces or state objects change
        function onValuesChanged() { root.refreshChannels(); }
    }

    // Utilities
    function refreshChannels() {
        Daemon.execute([
            "sh", "-c",
            "nmcli -t -f SSID,FREQ dev wifi list"
        ], (e) => {
            Debug.log(e);

            const lines = (e.output || "").split("\n");
            const networkMap = {};

            for (let i = 0; i < lines.length; i++) {
                const line = lines[i].trim();
                if (!line) continue;

                const parts = line.split(":");
                if (parts.length < 2) continue;

                const ssid = parts[0].trim();
                const freqStr = parts[1].trim();
                const rawMHz = parseInt(freqStr.replace(/[^0-9]/g, "")) || 0;

                if (ssid !== "" && rawMHz > 0) {
                    const ghz = parseFloat((rawMHz / 1000).toFixed(2));
                    if (!networkMap[ssid]) {
                        networkMap[ssid] = ghz;
                    }
                }
            }

            // Reassign map to trigger QML bindings
            root.channels = networkMap;
        });
    }

    function scramble(_ssid) {
        if (!_ssid) return "Hidden Network";

        const adjectives = [
            "Quiet", "Brisk", "Silent", "Velvet", "Golden",
            "Silver", "Cozy", "Rustic", "Bright", "Shadow",
            "Amber", "Copper", "Frozen", "Wandering", "Cosmic"
        ];

        const nouns = [
            "Pond", "Harbor", "Meadow", "Summit", "Forest",
            "Valley", "Breeze", "Canyon", "Haven", "Orchard",
            "Ridge", "Stream", "Glade", "Beacon", "Pinnacle"
        ];

        // Integer block index (increments every 15 minutes)
        const timeBlock = Math.floor(Date.now() / 900000);

        // Epoch timestamp in ms for the start of the current 15-minute window (e.g., 12:00:00, 12:15:00)
        const nearest15MinTimestamp = timeBlock * 900000;

        // Combine original SSID with the 15-minute time block for hashing
        const key = `${_ssid}_${nearest15MinTimestamp}`;

        let hash = 0;
        for (let i = 0; i < key.length; i++) {
            hash = (hash << 5) - hash + key.charCodeAt(i);
            hash |= 0; // Convert to 32bit integer
        }

        const adj = adjectives[Math.abs(hash) % adjectives.length];
        const noun = nouns[Math.abs(hash >> 3) % nouns.length];

        return `${adj} ${noun}`;
    }
}