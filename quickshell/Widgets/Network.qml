import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.Utilities
import qs.Style
import qs.Services

WidgetBase {
    id: wifiWidget

    property int watch_interval: 60000 // 60s
    property bool watch: true
    
    property int critical: 30
    property int warning: 60

    // Icons
    readonly property string wifiIcon: ""
    readonly property string wiredIcon: ""

    // Bind directly to NMCLI properties
    property bool connected: NMCLI.isConnected
    property var activeWifi: NMCLI.active
    property var activeEthernet: NMCLI.activeEthernet

    // Determine type
    property bool isWifi: activeWifi !== null
    property int strength: isWifi ? activeWifi.strength : 100

    // Icon selection
    property string currentIcon: isWifi ? wifiIcon : wiredIcon

    // Display
    icon: currentIcon
    label: isWifi ? activeWifi.ssid + " (" + strength + "%)" : NMCLI.activeConnection
    tooltip: isWifi ? "Strength: (" + strength + "%)" : "Direct: " + NMCLI.activeConnection

    // Style logic
    style.foreground.idle: {
        if (!isWifi) {
            return Theme.color_green
        } else if (strength <= critical) {
            return Theme.color_red
        } else if (strength <= warning) {
            return Theme.color_yellow
        } else {
            return Theme.color_green
        }
    }

    // Secondary process to watch signal strength
    Process {
        id: strengthProc
        command: ["nmcli", "-f", "IN-USE,SIGNAL", "device", "wifi", "list", "--rescan", "no"]
        stdout: SplitParser {
            onRead: (output) => {
                var lines = output.trim().split("\n")
                console.log(JSON.stringify(lines));
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (line.startsWith("*")) {
                        var parts = line.split(/\s+/)
                        if (parts.length >= 2) {
                            strength = parseInt(parts[1])
                        }
                    }
                }
            }
        }
    }

    // Rerun periodically to refresh strength
    Timer {
        interval: watch_interval; running: watch; repeat: watch
        onTriggered: strengthProc.running = true
    }
}