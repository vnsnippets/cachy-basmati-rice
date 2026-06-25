import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Networking
import Quickshell.Widgets

import qs.Layouts
import qs.Utilities
import qs.Components
import qs.Components.Controls

Item {
    id: root
    anchors.left: parent.left
    anchors.right: parent.right
    
    implicitHeight: container.implicitHeight

    readonly property int animduration: 200
    property int maxheight: 400

    Component {
        id: tabfactory
        ColumnLayout {
            spacing: Styles.spacing * 2
            
            // Injected dynamically via ContainerWithTabs factory context
            required property NetworkDevice device
            readonly property bool deviceiswireless: device.type === DeviceType.Wifi

            // Timers driving the automatic timeout logic and Progress Bar tracking
            Timer {
                id: scantimer

                property real starttime: -1
                readonly property int remaining: (running && starttime > 0) ? Math.max(0, interval - (ticker.now - starttime)) : interval
                
                // Track your semantic setup: defaults to the custom timeout value
                interval: Styles.network.toolbar.scan.timeout
                running: deviceiswireless && device.scannerEnabled
                
                onTriggered: device.scannerEnabled = false
                onRunningChanged: starttime = running ? Date.now() : -1;
            }

            Timer {
                id: ticker
                property real now: Date.now()
                interval: 50
                running: scantimer.running
                repeat: true
                onTriggered: now = Date.now()
            }

            StyledText {
                id: deviceStatusText
                text: device.connected ? "Status: Connected" : "Status: Disconnected"
                color: Styles.network.toolbar.text
            }

            // Toolbar / Header Area
            RowLayout {
                visible: deviceiswireless
                spacing: Styles.spacing
                Layout.alignment: Qt.AlignTop
                
                // Dynamic Scan Progress Bar
                BarControl {
                    id: scanprogress
                    opacity: visible ? 1 : 0

                    Layout.fillWidth: true
                    
                    value: 1.0 - (scantimer.remaining / scantimer.interval)
                    length: (visible) ? Styles.network.toolbar.scan.progressbar.length : 0
                    blinkLastActive: Styles.network.toolbar.scan.progressbar.blink
                    
                    spacing: Styles.spacing / 2
                    styles.idle: Styles.network.toolbar.scan.progressbar.idle
                    styles.active: Styles.network.toolbar.scan.progressbar.active

                    Behavior on opacity {
                        NumberAnimation { duration: root.animduration }
                    }
                }

                // Scan Action (Only visible and usable on Wifi Interfaces)
                ClickableWithIcon {
                    id: scantoggle
                    size: Styles.size - Styles.padding * 2
                    padding: Styles.padding / 1.5 

                    enabled: deviceiswireless
                    // In Quickshell 0.3.0, scanning is controlled via scannerEnabled
                    active: deviceiswireless && device.scannerEnabled
                    radius: Styles.size

                    iconname: Styles.network.toolbar.scan.icon
                    iconstyle.idle: Styles.network.toolbar.scan.text.idle
                    iconstyle.active: Styles.network.toolbar.scan.text.active
                    
                    enablebackground: true
                    backgroundstyle.idle: Styles.network.toolbar.scan.background.idle
                    backgroundstyle.active: Styles.network.toolbar.scan.background.active

                    onClicked: {
                        if (deviceiswireless) {
                            device.scannerEnabled = !device.scannerEnabled;
                        }
                    }

                    states: State {
                        name: "spinning"
                        when: deviceiswireless && device.scannerEnabled
                        PropertyChanges { target: scantoggle; rotation: 360 }
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
                }
            }

            // Fallback Empty State Message Pane
            Rectangle {
                id: nonetworkfound
                Layout.fillWidth: true
                height: 48
                radius: Styles.radius
                color: Styles.network.emptymessage.background

                // Hide empty block if networks are found or if the interface is wired (Ethernet auto-manages)
                readonly property int totalNets: (deviceiswireless && device.networks) ? device.networks.values.length : 0
                opacity: (deviceiswireless || totalNets > 0) ? 0 : 1
                visible: opacity > 0

                StyledText {
                    leftPadding: Styles.padding
                    rightPadding: Styles.padding
                    anchors.verticalCenter: parent.verticalCenter
                    text: "No networks available"
                    color: Styles.network.emptymessage.text
                }

                Behavior on opacity {
                    NumberAnimation { duration: root.animduration }
                }
            }

            // Main Content Execution Engine
            ScrollView {
                visible: !nonetworkfound.visible
                Layout.fillWidth: true
                Layout.maximumHeight: root.maxheight

                clip: true
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Item {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    implicitHeight: networksections.height

                    ColumnLayout {
                        id: networksections
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Styles.spacing * 3
                        
                        readonly property var sortedNetworks: {
                            const connected = [];
                            const known = [];
                            const available = [];

                            if (!deviceiswireless || !device.networks) return { connected, known, available };

                            const allNets = device.networks.values;
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

                        // Wired Single-Link Information block 
                        Loader {
                            Layout.fillWidth: true
                            active: !deviceiswireless && device.connected
                            visible: active
                            sourceComponent: Rectangle {
                                height: 56
                                radius: Styles.radius
                                color: Qt.alpha(Styles.network.emptymessage.background, 0.4)
                                border.color: device.connected ? Styles.network.device.border.active : Styles.network.device.border.idle
                                border.width: 1

                                StyledText {
                                    anchors.centerIn: parent
                                    text: `Wired Link Active (${device.name})`
                                    color: Styles.network.device.text.idle
                                }
                            }
                        }

                        // Dynamic Wireless Filter Sections
                        DeviceSection {
                            Layout.fillWidth: true
                            networks: networksections.sortedNetworks.connected
                            title: "Connected Network"
                        }

                        DeviceSection {
                            Layout.fillWidth: true
                            networks: networksections.sortedNetworks.known
                            title: "Saved Networks"
                        }

                        DeviceSection {
                            Layout.fillWidth: true
                            networks: networksections.sortedNetworks.available
                            title: "Available Networks"
                        }
                    }
                }
            }
        }
    }


    ContainerWithTabs {
        id: container
        tabs: Networking.devices.values.map((dev) => {
            return {
                name: dev.name.toUpperCase(),
                content: { "device": dev }
            };
        })
        template: tabfactory
        title: "Network Adapters"
        options: Clickable {
            styles.background.idle: "transparent"
            styles.background.active: "transparent"

            StyledText {
                readonly property color textcolor: (Networking.wifiEnabled) ? Styles.colors.green : Styles.colors.red

                Layout.fillWidth: false
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                active: Networking.wifiEnabled
                text: `WIFI: ${(Networking.wifiEnabled) ? "ON" : "OFF"}`
                style.idle: Qt.alpha(textcolor, 0.6)
                style.active: Qt.alpha(textcolor, 1)
            }

            onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
        }
    }
}