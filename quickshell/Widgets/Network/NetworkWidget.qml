import QtQuick
import QtQuick.Layouts
import Quickshell

import NetworkMonitorPlugin

import qs
import qs.Styles
import qs.Services
import qs.Widgets

/**
* Network.qml
* Status bar Base for network information and quick actions
*
* States:
*   • Connected to internet via wired connection
*   • Connected to internet via wireless connection
*        • Display current SSID
*   • Disconnected
*        • Offline with no connectivity
*        • Offline but retrying connections in background
*
* Icons and colors vary based on state changes and ongoing actions
*     󰑓  
*
* Device Types
* | Value | Constant Name | Description                                      |
* | ----- | ------------- | ------------------------------------------------ |
* | 0     | UNKNOWN       | Unknown device type.                             |
* | 1     | ETHERNET      | Standard wired Ethernet device.                  |
* | 2     | WIFI          | 802.11 Wi-Fi device.                             |
* | 3     | UNUSED1       | Unused (historically related to old hardware).   |
* | 4     | UNUSED2       | Unused (historically related to old hardware).   |
* | 5     | BT            | Bluetooth device (PAN/DUN).                      |
* | 6     | OLPC_MESH     | OLPC Mesh networking (802.11s).                  |
* | 7     | WIMAX         | WiMAX device.                                    |
* | 8     | MODEM         | Mobile broadband modem (GSM, CDMA, LTE, 5G).     |
* | 9     | INFINIBAND    | InfiniBand network device.                       |
* | 10    | BOND          | Bonded interface (software aggregation).         |
* | 11    | VLAN          | 802.1Q VLAN interface.                           |
* | 12    | ADSL          | ADSL modem.                                      |
* | 13    | BRIDGE        | Software bridge device.                          |
* | 14    | GENERIC       | Generic device (unrecognized by NM but visible). |
* | 15    | TEAM          | Teamed interface (similar to bonding).           |
* | 16    | TUN           | TUN/TAP virtual interface.                       |
* | 17    | IP_TUNNEL     | IP tunnel (GRE, IPIP, SIT, etc.).                |
* | 18    | MACVLAN       | MACVLAN interface.                               |
* | 19    | VXLAN         | VXLAN interface.                                 |
* | 20    | VETH          | Virtual Ethernet pair.                           |
* | 21    | MACSEC        | MACsec (IEEE 802.1AE) interface.                 |
* | 22    | DUMMY         | Dummy/loopback-style software interface.         |
* | 23    | PPP           | PPP interface (Point-to-Point).                  |
* | 24    | OVS_INTERFACE | Open vSwitch interface.                          |
* | 25    | OVS_PORT      | Open vSwitch port.                               |
* | 26    | OVS_BRIDGE    | Open vSwitch bridge.                             |
* | 27    | WPAN          | IEEE 802.15.4 (Low-Rate Wireless PAN).           |
* | 28    | 6LOWPAN       | 6LoWPAN interface.                               |
* | 29    | WIREGUARD     | WireGuard VPN interface.                         |
* | 30    | WIFI_P2P      | Wi-Fi Direct (P2P) device.                       |
* | 31    | VRF           | Virtual Routing and Forwarding interface.        |
* | 32    | LOOPBACK      | Loopback interface (standard 127.0.0.1).         |
**/

Clickable {
    id: root
    required property Component popup

    // Use required properties for better performance/type safety
    readonly property int criticalLimit: 25
    readonly property int degraded_threshold: 60
    
    // Flattened properties to avoid object re-creation overhead
    readonly property int network_state: NetworkMonitor.GlobalState
    readonly property var active_device: NetworkMonitor.ActiveAccessPoint

    property color color_disconnected: null
    property color color_connecting: null
    property color color_connected_default: null
    property color color_connected_critical: null
    property color color_connected_limited: null

    readonly property bool isScanning: Context.stopwatch.scan_networks?.running ?? false
    
    readonly property color status_color: {
        if (isScanning) return color_connecting;
        if (network_state <= 20) return color_disconnected;
        if (network_state <= 50) return color_connecting;
        if (network_state < 70) return color_connected_limited;
        const s = active_device?.Strength ?? 0;
        if (s < criticalLimit) return color_connected_critical;
        if (s < degraded_threshold) return color_connected_limited;
        return color_connected_default;
    }

    icon: (network_state >= 60) ? "": (network_state >= 30 || isScanning) ? "" : ""
    label: (network_state >= 70) ? `${active_device?.Ssid} (${active_device.Strength}%)` : (network_state >= 60) ? `${active_device?.Ssid} (Local)` : (network_state >= 40) ? "Connecting" : "Disconnected"
    style.text.idle: status_color

    // onClicked: Networking.handleConnectionToggle()
    onClicked: canvas.handleWidgetPopup(this);
}