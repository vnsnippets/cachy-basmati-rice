pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell.Networking

import qs
import qs.Components

ColumnLayout {
    id: root

    // Expects a Quickshell NetworkDevice object
    property NetworkDevice device

    spacing: Constants.spacing
    implicitHeight: details.implicitHeight

    readonly property bool is_connected: root.device?.state === ConnectionState.Connected
    readonly property color status_color: is_connected ? Constants.network_device_status_connected : Constants.network_device_status_disconnected
    readonly property string status_label: root.is_connected ? "Connected" : "Disconnected"

    ColumnLayout {
        id: details
        Layout.fillWidth: true
        spacing: Constants.spacing

        // --- DEVICE STATUS HEADER ---
        // RowLayout {
        //     Layout.fillWidth: true
        //     spacing: Constants.spacing


        //     StyledText {
        //         horizontalAlignment: Text.AlignLeft
        //         verticalAlignment: Text.AlignVCenter
        //         text: root.status_label.toUpperCase()
        //         color: root.status_color
        //     }
        // }

        // --- WIRED / ETHERNET VIEW ---
        Loader {
            Layout.fillWidth: true
            sourceComponent: if (root.device.networks.values.length > 0) {
                switch (root.device?.type) {
                    case DeviceType.Wired: return component_wired_device;
                    case DeviceType.Wifi: return component_wireless_device
                }
            } else return component_no_network
        }        
    }

    Component {
        id: component_wireless_device
        NetworkDeviceWireless { device: root.device as WifiDevice }
    }

    Component {
        id: component_wired_device
        NetworkDeviceWired { device: root.device as WiredDevice }
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