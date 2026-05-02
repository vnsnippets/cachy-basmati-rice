pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

import NetworkMonitorPlugin

import qs
import qs.Utilities

Singleton {
    id: logic

    // Move thresholds here to centralize configuration
    readonly property int recency_threshold: 2592000 
    readonly property int offline_index: 40

    /**
     * Toggles connection state or initiates a smart scan
     */
    function handleConnectionToggle() {
        if (NetworkMonitor.GlobalState > offline_index) {
            disconnectActiveDevice();
        } else {
            initiateSmartConnect();
        }
    }

    /**
     * Safely disconnects the current active device
     */
    function disconnectActiveDevice() {
        const device = NetworkMonitor.ActiveDevice;
        if (device?.DevicePath) {
            NetworkControl.DisconnectDevice(device.DevicePath);
        }
    }

    /**
     * Scans for the best available known network and connects
     */
    function initiateSmartConnect() {
        if (Context.stopwatch?.scan_networks?.running) return;

        // Initialize stopwatch on the global state object
        Context.stopwatch.scan_networks = Stopwatch.create(logic, false, true);

        // Filter for Wireless (2) or WiFi (30) devices
        const devices = NetworkControl.GetAllDevices();
        const netDevice = devices.find(d => d.DeviceType === 2 || d.DeviceType === 30);
        
        if (!netDevice) return;

        // Start the scan interval
        Context.stopwatch.scan_networks.begin(2000, () => {
            const networks = NetworkControl.GetKnownNetworksInRange(netDevice.DevicePath);
            if (networks.length === 0) return;

            // Sort logic: Performance optimized by minimizing property access in sort
            networks.sort((a, b) => {
                // 1. Saved status priority
                if (a.Saved !== b.Saved) return b.Saved - a.Saved;
                
                const now = Math.floor(Date.now() / 1000);
                const aRecent = a.Saved && (now - a.LastConnected) < recency_threshold;
                const bRecent = b.Saved && (now - b.LastConnected) < recency_threshold;

                if (aRecent !== bRecent) return bRecent ? 1 : -1;

                // 2. Signal Strength (5% hysteresis)
                if (Math.abs(a.Strength - b.Strength) > 5) {
                    return b.Strength - a.Strength;
                }

                // 3. Recency Fallback
                return b.LastConnected - a.LastConnected;
            });

            const best = networks[0];
            if (best.Saved) {
                NetworkControl.ActivateConnection(
                    netDevice.DevicePath, 
                    best.SettingsPath, 
                    best.AccessPointPath
                );
            }
        });

        NetworkControl.RequestScan(netDevice.DevicePath);
    }
}