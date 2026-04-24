import QtQuick
import QtQuick.Layouts
import Quickshell

import NetworkMonitorPlugin

import qs
import qs.Style
import qs.Services

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

Base {
    id: container

    readonly property int critical_threshold: 25
    readonly property int degraded_threshold: 60
    readonly property int recency_threshold : 2592000 // 15 days

    readonly property int strength_levels: 5

    readonly property int global_offline_index: 40
    readonly property int global_online_index: 70

    readonly property var ui: {
        switch (NetworkMonitor.GlobalState) {
            case 10: return { icon: "", label: "Asleep", color: Theme.color_slate };
            case 20: return { icon: "", label: "Disconnected", color: Theme.color_slate };
            case 30: return { icon: "", label: "Disconnecting", color: Theme.color_yellow };
            case 40: return { icon: "", label: "Connecting", color: Theme.color_yellow };
            case 50: return { icon: "", label: "Limited (Site)", color: Theme.color_green };
            case 60: return { icon: "", label: `${NetworkMonitor.ActiveAccessPoint.Ssid} (Limited)`, color: Theme.color_blue };
            case 70: 
                const _strength = NetworkMonitor.ActiveAccessPoint?.Strength;
                const baseColor = (!_strength || _strength < critical_threshold) ? Theme.color_red 
                                : (_strength < degraded_threshold) ? Theme.color_yellow 
                                : Theme.color_green;
                return { 
                    icon: "", 
                    // label: `${NetworkMonitor.ActiveAccessPoint?.Ssid} (${_strength}%)` || "Unknown", 
                    label: NetworkMonitor.ActiveAccessPoint?.Ssid || "Unknown", 
                    color: baseColor
                };
            default: return { icon: "", label: "Unknown", color: Theme.color_red };
        }
    }

    icon: Global.stopwatch.scan_networks?.running ? "󰑓" : ui.icon
    label: `${ui.label}`
    style.foreground.idle: ui.color

    Row {
        id: strength_row
        spacing: 2
        Layout.leftMargin: Theme.spacing

        Repeater {
            id: strength_meter_container
            model: strength_levels
            
            Rectangle {
                id: strength_bar

                readonly property int animation_duration: 150
                readonly property bool is_online: NetworkMonitor.GlobalState === global_online_index
                readonly property bool is_active: NetworkMonitor.ActiveAccessPoint?.Strength > (index * 100/strength_levels)
                readonly property bool is_scanning: Global.stopwatch.scan_networks?.running ?? false
                
                radius: 2

                height: 12
                width: 0     // Start at 0
                opacity: (is_active ? 1.0 : 0.3) 

                clip: true

                color: (!NetworkMonitor.ActiveAccessPoint || is_scanning) ? Theme.color_slate : is_active ? ui.color : Theme.color_slate
                
                states: [
                    State {
                        name: "visible"
                        when: strength_bar.is_online
                        PropertyChanges { target: strength_bar; width: 4; }
                    },
                    State {
                        name: "hidden"
                        when: !strength_bar.is_online
                        PropertyChanges { target: strength_bar; width: 0; }
                    }
                ]

                transitions: [
                    Transition {
                        from: "hidden"; to: "visible"
                        SequentialAnimation {
                            PauseAnimation { duration: (index * animation_duration + animation_duration) } // The Stagger
                            ParallelAnimation {
                                NumberAnimation { properties: "width"; duration: 0; easing.type: Easing.OutBack }
                                // NumberAnimation { property: "opacity"; duration: 400 }
                            }
                        }
                    },
                    Transition {
                        from: "visible"; to: "hidden"
                        SequentialAnimation {
                            // Reverse stagger: last bar disappears first
                            PauseAnimation { duration: (strength_levels - index) * animation_duration } 
                            ParallelAnimation {
                                NumberAnimation { properties: "width"; duration: 0; easing.type: Easing.InBack }
                                // NumberAnimation { property: "opacity"; duration: 200 }
                            }
                        }
                    }
                ]

                // Maintain color reactivity while visible
                Behavior on color { ColorAnimation { duration: Theme.duration } }
            }
        }
    }

    onClicked: () => {
        if (NetworkMonitor.GlobalState > global_offline_index) {
            NetworkMonitor.ActiveDevice && NetworkMonitor.ActiveDevice.DevicePath && NetworkControl.DisconnectDevice(NetworkMonitor.ActiveDevice.DevicePath);
        } else {
            if (Global.stopwatch?.scan_networks?.running) return;

            Global.stopwatch.scan_networks = Stopwatch.create(container);

            const _devices = NetworkControl.GetAllDevices();
            const _network_device = _devices.find((e) => e.DeviceType === 2) ?? _devices.find((e) => e.DeviceType === 30);

            Global.stopwatch.scan_networks.begin(2000, () => {
                const _known_networks = NetworkControl.GetKnownNetworksInRange(_network_device.DevicePath);
                _known_networks.sort((a, b) => {
                    // 1. Primary: Always prioritize Saved networks over guest/random ones
                    if (a.Saved !== b.Saved) return b.Saved - a.Saved;
                    
                    // 2. Prioritize recent connections (86400 for a full day) 
                    const now = Math.floor(Date.now() / 1000); // Current Unix time
                    
                    const aIsRecent = a.Saved && (now - a.LastConnected) < recency_threshold;
                    const bIsRecent = b.Saved && (now - b.LastConnected) < recency_threshold;

                    // If one is recent and the other isn't, the recent one wins
                    if (aIsRecent !== bIsRecent) return bIsRecent ? 1 : -1;

                    // 3. Tie-breaker for Recency
                    // If both are recent, or both are old/unsaved, look at signal strength. 
                    // If strengths are within 5% of each other, choose the most recent connection.
                    const strengthDiff = Math.abs(a.Strength - b.Strength);
                    if (strengthDiff > 5) {
                        return b.Strength - a.Strength;
                    }

                    // 4. Final Fallback: If strengths are nearly equal, most recent connection wins
                    return b.LastConnected - a.LastConnected;
                });

                if (_known_networks.length === 0) return;

                const _best_network = _known_networks[0];
                if (!_best_network.Saved) return;

                NetworkControl.ActivateConnection(_network_device.DevicePath, _best_network.SettingsPath, _best_network.AccessPointPath);
            });
            NetworkControl.RequestScan(_network_device.DevicePath);
        }
    }

    Connections {
        target: NetworkMonitor
        function onScanFinished() { Global.stopwatch.scan_networks.end(); }
    }
}