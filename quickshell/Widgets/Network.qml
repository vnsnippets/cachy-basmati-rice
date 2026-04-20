import QtQuick
import Quickshell
import qs
import qs.Utilities
import qs.Style
import qs.Services

WidgetBase {
    id: wifiWidget

    property int critical: 30
    property int warning: 60

    // Icons
    readonly property string wifiIcon: ""
    readonly property string wiredIcon: ""

    // Active connection info from NMCLI
    property bool connected: NMCLI.isConnected
    property string activeInterface: NMCLI.activeInterface
    property string activeConnection: NMCLI.activeConnection
    property var activeNetwork: NMCLI.active   // AccessPoint object if WiFi
    property var activeEthernet: NMCLI.activeEthernet

    // Determine type
    property bool isWifi: activeNetwork !== null
    property int strength: isWifi ? activeNetwork.strength : 100

    // Icon selection
    property string currentIcon: isWifi ? wifiIcon : wiredIcon

    // Display
    icon: currentIcon
    label: isWifi ? activeNetwork.ssid : activeConnection
    tooltip: isWifi ? "Strength: (" + strength + "%)"
        : "Direct: " + activeConnection

    // Style logic
    style.foreground.idle: {
        if (!isWifi) {
            // Wired/direct connection → always green
            return Theme.color_green
        } else if (strength <= critical) {
            return Theme.color_red
        } else if (strength <= warning) {
            return Theme.color_yellow
        } else {
            return Theme.color_green
        }
    }
}