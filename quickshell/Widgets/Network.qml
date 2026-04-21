import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.Utilities
import qs.Style
import qs.Services

WidgetBase {
    id: widget

    property int criticalthreshold: 25
    property int warningthreshold: 50
    property bool autoreconnect: true

    // "" "" "" "" "󰑓"

    icon: (NMCLI.active) ? (NMCLI.active.ssid) ? "" : "" : (autoreconnect) ? "󰑓" : ""
    label: (NMCLI.active) ? ( NMCLI.active.ssid) ? `${NMCLI.active.ssid} (${NMCLI.active.strength}%)` : "Ethernet" : "Disconnected"

    style.foreground.idle: (NMCLI.active) ? (NMCLI.active.ssid) ?
        (NMCLI.active.strength <= criticalthreshold) ? Theme.color_red : (NMCLI.active.strength <= warningthreshold) ? Theme.color_yellow : Theme.color_green
        : Theme.color_green : Theme.color_red

    // React to NMCLI signals
    Connections {
        target: NMCLI
        function onConnectionFailed(ssid) {
            widget.icon = ""
            tooltip = "Disconnected"
            style.foreground.idle = Theme.color_red
        }
    }

    Timer {
        interval: 10000 //10s
        running: !NMCLI.active && autoreconnect
        repeat: true
        onTriggered: NMCLI.getNetworks(() => {
            const best = NMCLI.networks
                .filter((e) => NMCLI.savedConnectionSsids.includes(e.ssid))
                .reduce((previous, current) => {
                    if (!previous) return current
                    return (previous.strength > current.strength) ? previous : current
                }, null)

            NMCLI.activateConnection(best.ssid, (e) => {
                console.log(JSON.stringify(e))
            });
        })
    }

    onClicked: () => {
        if (!NMCLI.active) {
            autoreconnect = true
        } else if (NMCLI.active.ssid) {
            NMCLI.disconnectFromNetwork()
            autoreconnect = false
        }
    }

    // Initial refresh when widget loads
    Component.onCompleted: {
        NMCLI.refreshStatus(() => {})
    }
}
