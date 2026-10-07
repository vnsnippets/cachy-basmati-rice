pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell.Networking

import qs
import qs.Layouts
import qs.Components

ContentTabContainer {
    id: container

    Component {
        id: component_network_device
        ColumnLayout {
            id: network_device_view

            property var context: null
            readonly property NetworkDevice device: context.device

            readonly property int device_type: network_device_view.device?.type

            spacing: Constants.spacing
            implicitHeight: device_loader.implicitHeight

            readonly property bool is_connected: network_device_view.device?.state === ConnectionState.Connected
            readonly property color status_color: is_connected ? Constants.network_device_color_connected : Constants.network_device_color_disconnected
            readonly property string status_label: network_device_view.is_connected ? "Connected" : "Disconnected"

            // --- WIRED / ETHERNET VIEW ---
            Loader {
                id: device_loader
                Layout.fillWidth: true
                sourceComponent: switch (network_device_view.device_type) {
                    case DeviceType.Wired: return component_wired_device;
                    case DeviceType.Wifi: return component_wireless_device;
                    default: return null
                }
            }

            Component {
                id: component_wireless_device
                NetworkDeviceWireless {
                    Layout.fillWidth: true
                    device: network_device_view.device as WifiDevice
                }
            }

            Component {
                id: component_wired_device
                NetworkDeviceWired {
                    Layout.fillWidth: true
                    device: network_device_view.device as WiredDevice
                }
            }
        }
    }

    title: "Network Adapters"

    tabs: (Networking.devices.values ?? []).slice().sort((a, b) => {
        const aIsWifi = a.type === DeviceType.Wifi;
        const bIsWifi = b.type === DeviceType.Wifi;
        
        // Wifi comes first
        if (aIsWifi && !bIsWifi) return -1;
        if (!aIsWifi && bIsWifi) return 1;
        
        // Optional secondary sort by name
        return (a.name ?? "").localeCompare(b.name ?? "");
    }).map(dev => ({
        name: dev.name.toUpperCase(),
        delegate: component_network_device,
        context: { "device": dev }
    }))
}