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

            // Expects a Quickshell NetworkDevice object
            property NetworkDevice device: null

            spacing: Constants.spacing
            implicitHeight: device_loader.implicitHeight

            readonly property bool is_connected: network_device_view.device?.state === ConnectionState.Connected
            readonly property color status_color: is_connected ? Constants.network_device_color_connected : Constants.network_device_color_disconnected
            readonly property string status_label: network_device_view.is_connected ? "Connected" : "Disconnected"

            // --- WIRED / ETHERNET VIEW ---
            Loader {
                id: device_loader
                Layout.fillWidth: true
                sourceComponent: {
                    if (network_device_view.device.networks.values.length === 0) return component_no_network;

                    // qmllint disable
                    var deviceType = network_device_view.device?.type
                    // qmllint enable

                    switch (deviceType) {
                        case DeviceType.Wired: return component_wired_device;
                        case DeviceType.Wifi: return component_wireless_device
                    }
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

            Component {
                id: component_no_network
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: no_network_label.implicitHeight + Constants.padding * 3
                    radius: Constants.radius
                    color: Qt.alpha(Constants.network_device_color_nonetwork_background, 0.15)
                    border.width: 1
                    border.color: Constants.network_device_color_nonetwork_background

                    StyledText {
                        id: no_network_label
                        leftPadding: Constants.padding * 1.5
                        rightPadding: Constants.padding * 1.5
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Not connected to any networks"
                        color: Constants.network_device_color_nonetwork_text
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: Constants.animation_duration }
                    }
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