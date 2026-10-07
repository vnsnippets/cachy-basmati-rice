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

    readonly property int item_height: Constants.size

    property int page_size: Math.min(5, device.networks.values.length)
    readonly property int capped_height: (item_height * page_size) + (Constants.spacing * page_size-1)

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

    Repeater {
        model: root.device.networks.values
        implicitHeight: root.capped_height

        delegate: StyledBox {
            id: item
            Layout.fillWidth: true
            radius: Constants.radius / 2
            implicitHeight: item_details.height + (Constants.padding * 2)

            required property WifiNetwork modelData
            
            // FIX: Derive connection status directly from modelData
            readonly property bool is_connected: modelData.connected ?? false
            readonly property bool is_changing: modelData.stateChanging ?? false

            // Highlight border state depending on connection
            color: item.is_connected ? Qt.alpha(Constants.color_green, 0.10) : Qt.alpha(Constants.color_surface, 0.20)
            border.color: item.is_connected ? Qt.alpha(Constants.color_green, 0.30) : Qt.alpha(Constants.color_surface, 0.20)
            border.width: 1

            ColumnLayout {
                id: item_details
                implicitWidth: parent.width - (Constants.padding * 2)
                anchors.centerIn: parent

                 // Network Name (SSID)
                StyledText {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    leftPadding: Constants.padding / 2
                    text: item.modelData.name || "Unidentified Network"
                    color: item.is_connected ? Constants.network_device_color_text_active : Constants.network_device_color_text
                    elide: Text.ElideRight
                }
            }

            // Row {
            //     anchors.left: parent.left
            //     anchors.right: parent.right
            //     spacing: Constants.spacing

            //     // Network Name (SSID)
            //     StyledText {
            //         Layout.fillWidth: false
            //         Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            //         leftPadding: Constants.padding / 2
            //         text: item.modelData.name || "Hidden Network"
            //         color: item.is_connected ? Constants.network_device_color_text_active : Constants.network_device_color_text
            //         elide: Text.ElideRight
            //     }

            //     // Signal Strength Indicator
            //     StyledText {
            //         Layout.fillWidth: false
            //         Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            //         visible: item.modelData.signalStrength !== undefined
            //         text: visible ? "(" + (item.modelData.signalStrength * 100).toFixed(0) + "%)" : ""
            //         color: Constants.network_device_color_text
            //     }

            //     Item { Layout.fillWidth: true }
                
            //     Clickable {
            //         id: network_details
                    
            //         StyledText {
            //             Layout.fillWidth: false
            //             Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            //             active: network_details.containsMouse
            //             text: item.is_changing ? "Connecting..." : (item.is_connected ? "Connected" : "")
            //             styles.color_idle: Constants.network_device_color_text
            //             styles.color_active: Constants.network_device_color_text_active
            //         }
            //     }

            //     // Action Buttons Block (Connect / Disconnect)
            //     Row {
            //         spacing: Constants.spacing / 2

            //         // CONNECT BUTTON
            //         ClickableWithIcon {
            //             visible: !item.is_connected && !item.is_changing
            //             size: Constants.icon_size
            //             padding: Constants.padding / 2
            //             radius: Constants.radius
            //             iconname: "plug-connect.svg"
            //             styles.icon_color_idle: Constants.color_overlay
            //             styles.icon_color_active: Constants.color_green
            //             styles.background_color_idle: Constants.color_surface
            //             styles.background_color_active: Constants.color_green

            //             onClicked: {
            //                 if (item.modelData.known || !item.modelData.security) {
            //                     item.modelData.connect();
            //                 } else {
            //                     Quickshell.execDetached([
            //                         "foot", "sh", "-c", 
            //                         `nmcli device wifi connect "${item.modelData.name}"`
            //                     ]);
            //                 }
            //             }
            //         }

            //         // DISCONNECT BUTTON
            //         ClickableWithIcon {
            //             visible: item.is_connected
            //             size: Constants.icon_size
            //             padding: Constants.padding / 2
            //             radius: Constants.radius
            //             iconname: "plug-disconnect.svg"
            //             styles.icon_color_idle: Constants.color_overlay
            //             styles.icon_color_active: Constants.color_red
            //             styles.background_color_idle: Constants.color_surface
            //             styles.background_color_active: Constants.color_red

            //             onClicked: item.modelData.disconnect()
            //         }
            //     }
            // }
        }
    }

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

    // readonly property var sortedNetworks: {
    //     const connected = [];
    //     const known = [];
    //     const available = [];

    //     if (!root.device || !root.device.networks) return { connected, known, available }

    //     const allNets = root.device.networks.values;
    //     for (let i = 0; i < allNets.length; i++) {
    //         const net = allNets[i];
    //         if (net.connected) {
    //             connected.push(net);
    //         } else if (net.known) {
    //             known.push(net);
    //         } else {
    //             available.push(net);
    //         }
    //     }

    //     return { connected, known, available };
    // }

    // // --- HEADER / TOOLBAR AREA ---
    // RowLayout {
    //     Layout.fillWidth: true
    //     Layout.topMargin: Constants.spacing
    //     Layout.bottomMargin: Constants.spacing
    //     spacing: Constants.spacing

    //     BarControl {
    //         Layout.fillWidth: true
    //         Layout.alignment: Qt.AlignVCenter

    //         value: 1.0 - (timeout_scan.remaining / timeout_scan.interval)
    //         blink: false
    //         length: 30
    //         radius: Constants.radius / 2
    //         spacing: Constants.spacing / 2

    //         styles.color_idle: Constants.color_surface
    //         styles.color_active: Qt.alpha(Constants.color_green, 1)

    //         Behavior on opacity { NumberAnimation { duration: Constants.animation_duration } }
    //     }

    //     ClickableWithIcon {
    //         id: scan_button
    //         size: Constants.icon_size
    //         padding: Constants.padding / 2            

    //         active: root.device?.scannerEnabled ?? false
    //         radius: (active)  ? Constants.icon_size : Constants.radius / 2
    //         iconname: "reboot.svg"

    //         styles.background_color_idle: Constants.color_surface
    //         styles.background_color_active: Constants.color_green
    //         styles.icon_color_idle: Constants.color_text
    //         styles.icon_color_active: Constants.color_base

    //         onClicked: root.device.scannerEnabled = !root.device.scannerEnabled;

    //         states: State {
    //             name: "spinning"
    //             when: root.device?.scannerEnabled ?? false
    //             PropertyChanges { scan_button.rotation: 360 }
    //         }

    //         transitions: [
    //             Transition {
    //                 to: "spinning"
    //                 RotationAnimation {
    //                     direction: RotationAnimation.Clockwise
    //                     loops: Animation.Infinite
    //                     duration: 800
    //                 }
    //             },
    //             Transition {
    //                 from: "spinning"
    //                 RotationAnimation {
    //                     duration: 400
    //                     easing.type: Easing.OutQuad
    //                 }
    //             }
    //         ]
            
    //         Behavior on radius { NumberAnimation { duration: Constants.animation_duration/4; easing.type: Easing.OutCubic } }
    //     }
    // }

    // // --- SCROLLABLE NETWORK LIST ---
    // ScrollView {
    //     Layout.fillWidth: true
    //     implicitHeight: Math.min(networksections.implicitHeight, 300)

    //     clip: true

    //     ColumnLayout {
    //         id: networksections
    //         Layout.fillWidth: true
    //         spacing: Constants.spacing * 2

    //         NetworkDeviceSection {
    //             Layout.fillWidth: true
    //             networks: root.sortedNetworks.connected
    //             title: "Connected Network"
    //         }

    //         NetworkDeviceSection {
    //             Layout.fillWidth: true
    //             networks: root.sortedNetworks.known
    //             title: "Saved Networks"
    //         }

    //         NetworkDeviceSection {
    //             Layout.fillWidth: true
    //             networks: root.sortedNetworks.available
    //             title: "Available Networks"
    //         }
    //     }
    // }
}