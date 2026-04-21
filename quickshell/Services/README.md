# NMCLI Service

The `NMCLI.qml` service is a singleton providing a comprehensive interface for managing network connections via the `nmcli` command-line tool. It supports both wireless (Wi-Fi) and wired (Ethernet) interfaces, connection monitoring, and network scanning.

## Variables for Client Use

These properties are intended for external use by components consuming this service.

| Variable | Type | Description |
| :--- | :--- | :--- |
| `deviceStatus` | `var` | Raw status information for network devices. |
| `wirelessInterfaces` | `var` | List of detected wireless network interfaces. |
| `ethernetInterfaces` | `var` | List of detected ethernet network interfaces. |
| `isConnected` | `bool` | Indicates if any network connection is currently active. |
| `activeInterface` | `string` | The name of the currently active network interface (e.g., "wlan0"). |
| `activeConnection` | `string` | The name of the currently active network connection. |
| `wifiEnabled` | `bool` | Indicates if the Wi-Fi radio is enabled. |
| `scanning` | `readonly bool` | True if a Wi-Fi network scan is currently in progress. |
| `networks` | `readonly list<AccessPoint>` | List of available Wi-Fi access points. Each `AccessPoint` object contains: `ssid`, `bssid`, `strength`, `frequency`, `active`, `security`, and `isSecure`. |
| `active` | `readonly AccessPoint` | The currently active Wi-Fi access point, or `null` if not connected to Wi-Fi. |
| `savedConnections` | `list<string>` | List of all saved network connection names. |
| `savedConnectionSsids` | `list<string>` | List of SSIDs for which Wi-Fi connection profiles are saved. |
| `ethernetDevices` | `list<var>` | List of ethernet devices with status and configuration details. |
| `activeEthernet` | `readonly var` | The currently active ethernet device object. |
| `wirelessDeviceDetails` | `var` | Configuration details (IP, gateway, DNS, etc.) for the active wireless interface. |
| `ethernetDeviceDetails` | `var` | Configuration details for the active ethernet interface. |

## Functions

### Wireless Management

| Function | Arguments | Description |
| :--- | :--- | :--- |
| `rescanWifi()` | None | Triggers a background scan for available Wi-Fi networks. |
| `getNetworks(callback)` | `callback: function(networks)` | Refreshes the list of available networks and returns them via callback. |
| `connectToNetwork(ssid, password, bssid, callback)` | `ssid: string`, `password: string`, `bssid: string`, `callback: function(result)` | Connects to a Wi-Fi network using the provided credentials. |
| `connectToNetworkWithPasswordCheck(ssid, isSecure, callback, bssid)` | `ssid: string`, `isSecure: bool`, `callback: function(result)`, `bssid: string` | Attempts to connect to a network. If `isSecure` is true, it first tries to use a saved password. |
| `forgetNetwork(ssid, callback)` | `ssid: string`, `callback: function(result)` | Deletes the saved connection profile for the specified SSID. |
| `hasSavedProfile(ssid)` | `ssid: string` | Returns `true` if a connection profile exists for the given SSID. |
| `enableWifi(enabled, callback)` | `enabled: bool`, `callback: function(result)` | Enables or disables the Wi-Fi radio. |
| `toggleWifi(callback)` | `callback: function(result)` | Toggles the Wi-Fi radio state. |
| `getWifiStatus(callback)` | `callback: function(enabled)` | Checks if the Wi-Fi radio is enabled. |
| `disconnectFromNetwork()` | None | Disconnects from the current active Wi-Fi network. |

### Ethernet Management

| Function | Arguments | Description |
| :--- | :--- | :--- |
| `getEthernetInterfaces(callback)` | `callback: function(interfaces)` | Updates the list of ethernet interfaces and devices. |
| `connectEthernet(connectionName, interfaceName, callback)` | `connectionName: string`, `interfaceName: string`, `callback: function(result)` | Connects an ethernet device using a connection profile name or interface name. |
| `disconnectEthernet(connectionName, callback)` | `connectionName: string`, `callback: function(result)` | Disconnects the specified ethernet connection. |
| `getEthernetDeviceDetails(interfaceName, callback)` | `interfaceName: string`, `callback: function(details)` | Updates and returns configuration details for an ethernet interface. |

### General Device & Status

| Function | Arguments | Description |
| :--- | :--- | :--- |
| `refreshStatus(callback)` | `callback: function(status)` | Updates general connection status, active interface, and active connection name. |
| `getDeviceStatus(callback)` | `callback: function(output)` | Gets the status of all network devices from `nmcli`. |
| `getDeviceDetails(interfaceName, callback)` | `interfaceName: string`, `callback: function(output)` | Gets raw detail output for a specific interface. |
| `getAllInterfaces(callback)` | `callback: function(interfaces)` | Gets a list of all detected network interfaces. |
| `isInterfaceConnected(interfaceName, callback)` | `interfaceName: string`, `callback: function(connected)` | Checks if a specific interface is currently connected. |
| `bringInterfaceUp(interfaceName, callback)` | `interfaceName: string`, `callback: function(result)` | Attempts to connect the specified interface. |
| `bringInterfaceDown(interfaceName, callback)` | `interfaceName: string`, `callback: function(result)` | Disconnects the specified interface. |
| `loadSavedConnections(callback)` | `callback: function(ssids)` | Refreshes the list of saved connection profiles and wireless SSIDs. |

## Processes

The service utilizes several background processes to interact with the system and monitor network changes.

| Process | Description | Lifecycle | Behavior |
| :--- | :--- | :--- | :--- |
| `monitorProc` | Monitors network state changes via `nmcli monitor`. | **Startup** | Runs continuously in the background. If it exits, it is automatically restarted after a 2-second delay. It triggers `refreshOnConnectionChange()` whenever output is detected. |
| `rescanProc` | Performs a manual Wi-Fi scan. | **Triggered** | Started by calling `rescanWifi()`. Runs once and then exits. Triggers `getNetworks()` upon completion. |
| `commandProc` | Used for executing one-off `nmcli` commands. | **Triggered** | Created dynamically via `executeCommand()`. Runs the specified command and returns the result through a callback. |

## Startup Lifecycle

When the service is initialized (`Component.onCompleted`):
1.  **Initial Data Fetch**: It immediately fetches Wi-Fi status, available networks, saved connection profiles, and ethernet interfaces.
2.  **Delayed Detail Update**: After a 2-second delay, it attempts to fetch detailed IP and configuration information for both the active wireless and active ethernet interfaces to ensure all properties are populated correctly once connections are established.
