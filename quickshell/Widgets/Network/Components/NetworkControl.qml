import QtQuick
import QtQuick.Layouts

import Quickshell

import qs
import qs.Styles
import qs.Widgets
import qs.Utilities

import NetworkMonitorPlugin

RowLayout {
    id: root
    spacing: Style.popup.spacing

    property bool wifiOn: false

    // Flattened properties to avoid object re-creation overhead
    readonly property int networkState: NetworkMonitor.GlobalState
    readonly property var activieWifiDevice: NetworkMonitor.ActiveAccessPoint

    Column {
        Layout.alignment: Qt.AlignVCenter
        Text {
            text: "Connected"
            font.pixelSize: 14
            color: Style.color_light
            opacity: 0.6
        }
        Text {
            text: (networkState >= 70) ? `${activieWifiDevice?.Ssid} (${activieWifiDevice.Strength}%)` : (networkState >= 60) ? `${activieWifiDevice?.Ssid} (Local)` : (networkState >= 40) ? "Connecting" : "Disconnected"
            font.pixelSize: 16
            color: Style.color_light
        }
    }

    Row {
        spacing: 8

        Clickable {
            id: wifiToggle
            icon: ""

            style.background.idle: (root.wifiOn) ? Style.color_blue : Style.color_dark
            style.border.idle: (root.wifiOn) ? Style.color_blue : Style.color_dark
            style.text.idle: (root.wifiOn) ? Style.color_dark : Style.color_light

            style.background.active: Style.color_blue
            style.border.active: Style.color_blue
            style.text.active: Style.color_dark

            onClicked: Daemon.execute(["nmcli", "radio", "wifi", (root.wifiOn) ? "off" : "on"], () => {
                Daemon.execute(["nmcli", "radio", "wifi"], (e) => {
                    if (!e || !e.output) return;
                    root.wifiOn = e.output === "enabled"
                })
            });

            Component.onCompleted: {
                Daemon.execute(["nmcli", "radio", "wifi"], (e) => {
                    if (!e || !e.output) return;
                    root.wifiOn = e.output === "enabled"
                })
            }
        }

        Clickable {
            id: bluetoothToggle
            icon: "󰂯"
        }
    }
}