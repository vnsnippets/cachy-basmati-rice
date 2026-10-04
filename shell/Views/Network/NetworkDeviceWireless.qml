pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Networking

import qs
import qs.Components

ColumnLayout {
    id: root
    spacing: Constants.spacing

    required property WifiDevice device

    Timer {
        id: timeout_scan

        property real starttime: -1
        readonly property int remaining: (running && starttime > 0) ? Math.max(0, interval - (timeout_tick.now - starttime)) : interval

        interval: 10000
        running: root.device?.scannerEnabled ?? false

        onTriggered: if (root.device) root.device.scannerEnabled = false
        onRunningChanged: starttime = running ? Date.now() : -1
    }

    Timer {
        id: timeout_tick
        property real now: Date.now()
        interval: 50
        running: timeout_scan.running
        repeat: true
        onTriggered: now = Date.now()
    }

    readonly property var sortedNetworks: {
        const connected = [];
        const known = [];
        const available = [];

        if (!root.device || !root.device.networks) return { connected, known, available }

        const allNets = root.device.networks.values;
        for (let i = 0; i < allNets.length; i++) {
            const net = allNets[i];
            if (net.connected) {
                connected.push(net);
            } else if (net.known) {
                known.push(net);
            } else {
                available.push(net);
            }
        }

        return { connected, known, available };
    }

    // --- HEADER / TOOLBAR AREA ---
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: Constants.spacing
        Layout.bottomMargin: Constants.spacing
        spacing: Constants.spacing

        BarControl {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            value: 1.0 - (timeout_scan.remaining / timeout_scan.interval)
            blink: false
            length: 30
            radius: Constants.radius / 2
            spacing: Constants.spacing / 2

            styles.color_idle: Constants.color_surface
            styles.color_active: Qt.alpha(Constants.color_green, 1)

            Behavior on opacity { NumberAnimation { duration: Constants.animation_duration } }
        }

        ClickableWithIcon {
            id: scan_button
            size: Constants.icon_size
            padding: Constants.padding / 2            

            active: root.device?.scannerEnabled ?? false
            radius: (active)  ? Constants.icon_size : Constants.radius / 2
            iconname: "reboot.svg"

            styles.background_color_idle: Constants.color_surface
            styles.background_color_active: Constants.color_green
            styles.icon_color_idle: Constants.color_text
            styles.icon_color_active: Constants.color_base

            onClicked: root.device.scannerEnabled = !root.device.scannerEnabled;

            states: State {
                name: "spinning"
                when: root.device?.scannerEnabled ?? false
                PropertyChanges { scan_button.rotation: 360 }
            }

            transitions: [
                Transition {
                    to: "spinning"
                    RotationAnimation {
                        direction: RotationAnimation.Clockwise
                        loops: Animation.Infinite
                        duration: 800
                    }
                },
                Transition {
                    from: "spinning"
                    RotationAnimation {
                        duration: 400
                        easing.type: Easing.OutQuad
                    }
                }
            ]
            
            Behavior on radius { NumberAnimation { duration: Constants.animation_duration/4; easing.type: Easing.OutCubic } }
        }
    }

    // --- SCROLLABLE NETWORK LIST ---
    ScrollView {
        Layout.fillWidth: true
        implicitHeight: Math.min(networksections.implicitHeight, 300)

        clip: true

        ColumnLayout {
            id: networksections
            Layout.fillWidth: true
            spacing: Constants.spacing * 2

            NetworkDeviceSection {
                Layout.fillWidth: true
                networks: root.sortedNetworks.connected
                title: "Connected Network"
            }

            NetworkDeviceSection {
                Layout.fillWidth: true
                networks: root.sortedNetworks.known
                title: "Saved Networks"
            }

            NetworkDeviceSection {
                Layout.fillWidth: true
                networks: root.sortedNetworks.available
                title: "Available Networks"
            }
        }
    }
}