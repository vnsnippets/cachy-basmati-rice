import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Bluetooth
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

    // Wrapper component factory used inside rendercontent
    Component {
        id: tabfactory
        ColumnLayout {
            spacing: Styles.spacing * 2
            
            // This property will be injected dynamically when the component is created
            required property BluetoothAdapter adapter

            Timer {
                id: scantimer

                property real starttime: -1
                // Corrected to calculate remaining time (intervals are in ms)
                readonly property int remaining: (running && starttime > 0) ? Math.max(0, interval - (ticker.now - starttime)) : 0
                
                interval: Styles.bluetooth.toolbar.scan.timeout
                running: adapter.discovering
                onTriggered: {
                    adapter.pairable = false
                    adapter.discovering = false
                }

                onRunningChanged: {
                    starttime = running ? Date.now() : -1;
                }
            }

            // Secondary high-frequency timer to drive progress bar updates
            Timer {
                id: ticker
                property real now: Date.now()
                interval: 50
                running: scantimer.running
                repeat: true
                onTriggered: now = Date.now()
            }

            RowLayout {
                spacing: Styles.spacing
                Layout.alignment: Qt.AlignTop

                StyledText {
                    id: scanningtext
                    visible: !scantimer.running
                    opacity: visible ? 1 : 0
                    text: Styles.bluetooth.toolbar.notscanning
                    color: Styles.bluetooth.toolbar.text

                    Behavior on opacity {
                        NumberAnimation {
                            duration: root.animduration
                        }
                    }
                }

                BarControl {
                    id: scanprogress
                    // FIX: Look at the source state instantly
                    visible: scantimer.running
                    opacity: visible ? 1 : 0

                    Layout.fillWidth: true
                    
                    // Simplified: Safe to remove inline condition checking since visibility matches running state
                    value: 1.0 - (scantimer.remaining / scantimer.interval)
                    length: (visible) ? Styles.bluetooth.toolbar.scan.progressbar.length : 0
                    blinkLastActive: Styles.bluetooth.toolbar.scan.progressbar.blink
                    
                    spacing: Styles.spacing / 2
                    styles.idle: Styles.bluetooth.toolbar.scan.progressbar.idle
                    styles.active: Styles.bluetooth.toolbar.scan.progressbar.active

                    Behavior on opacity {
                        NumberAnimation {
                            duration: root.animduration
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                ClickableWithIcon {
                    id: scantoggle
                    size: Styles.size - Styles.padding * 2
                    padding: Styles.padding / 1.5 

                    enabled: adapter.enabled
                    active: adapter.discovering
                    radius: Styles.size

                    iconname: Styles.bluetooth.toolbar.scan.icon
                    iconstyle.idle: (adapter.enabled) ? Styles.bluetooth.toolbar.scan.text.idle : Styles.bluetooth.toolbar.scan.text.disabled
                    iconstyle.active: Styles.bluetooth.toolbar.scan.text.active
                    
                    enablebackground: true
                    backgroundstyle.idle: Styles.bluetooth.toolbar.scan.background.idle
                    backgroundstyle.active: Styles.bluetooth.toolbar.scan.background.active

                    onClicked: {
                        adapter.pairable = !adapter.pairable ?? false
                        adapter.discovering = !adapter.discovering ?? false
                    }

                    // 1. Map the condition directly to a QML State
                    states: State {
                        name: "spinning"
                        when: adapter.discovering
                        PropertyChanges { target: scantoggle; rotation: 360 }
                    }

                    // 2. Define how to behave during transitions
                    transitions: [
                        // When entering the spinning state, loop infinitely
                        Transition {
                            to: "spinning"
                            RotationAnimation {
                                direction: RotationAnimation.Clockwise
                                loops: Animation.Infinite
                                duration: 800
                            }
                        },
                        // When leaving the spinning state (going back to upright), smoothly ease to 0
                        Transition {
                            from: "spinning"
                            RotationAnimation {
                                duration: 400
                                easing.type: Easing.OutQuad
                            }
                        }
                    ]
                }

                ClickableWithIcon {
                    id: bluetoothtoggle
                    size: Styles.size - Styles.padding * 2
                    padding: Styles.padding / 1.5 
                    enablebackground: true

                    active: adapter.enabled

                    // radius: (adapter.enabled) ? Styles.size : Styles.radius
                    radius: Styles.size

                    iconname: Styles.bluetooth.toolbar.toggle.icon
                    iconstyle.idle: Styles.bluetooth.toolbar.toggle.text.idle
                    iconstyle.active: Styles.bluetooth.toolbar.toggle.text.active

                    backgroundstyle.idle: Styles.bluetooth.toolbar.toggle.background.idle
                    backgroundstyle.active: Styles.bluetooth.toolbar.toggle.background.active

                    onClicked: adapter.enabled = !adapter.enabled ?? false

                    // Animate with rotation
                    rotation: (adapter.enabled) ? Styles.bluetooth.toolbar.toggle.rotation.active : Styles.bluetooth.toolbar.toggle.rotation.idle
                    transformOrigin: Item.Center

                    Behavior on rotation { 
                        NumberAnimation { 
                            duration: root.animduration * 2
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            Rectangle {
                id: nodevicefound
                Layout.fillWidth: true
                height: 48
                radius: Styles.radius
                color: Styles.bluetooth.emptymessage.background

                opacity: (adapter.devices.values.length > 0 || adapter.discovering) ? 0 : 1
                visible: opacity > 0

                StyledText {
                    leftPadding: Styles.padding
                    rightPadding: Styles.padding
                    anchors.verticalCenter: parent.verticalCenter
                    text: "No devices found"
                    color: Styles.bluetooth.emptymessage.text
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: root.animduration
                    }
                }
            }

            ScrollView {
                visible: (adapter.devices.values.length > 0 || adapter.discovering)
                Layout.fillWidth: true
                Layout.maximumHeight: root.maxheight

                clip: true
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Item {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    implicitHeight: devicesections.height

                    ColumnLayout {
                        id: devicesections
                        anchors.left: parent.left
                        anchors.right: parent.right

                        spacing: Styles.spacing * 3
                        visible: !nodevicefound.visible
                        
                        readonly property var groupeddevices: {
                            // Initialize clean buckets
                            const connected = [];
                            const paired = [];
                            const available = [];
                            const unknown = [];

                            if (!adapter || !adapter.devices) return { connected, paired, available, unknown };

                            const allDevices = adapter.devices.values;
                            
                            // Step 1: Group devices into their respective buckets in one pass
                            for (let i = 0; i < allDevices.length; i++) {
                                const dev = allDevices[i];

                                if (dev.state === BluetoothDeviceState.Connected) {
                                    connected.push(dev);
                                } else if (dev.paired) {
                                    paired.push(dev);
                                } else if (dev.deviceName) {
                                    available.push(dev);
                                } else {
                                    unknown.push(dev);
                                }
                            }

                            // Step 2: Flatten them back into a single array, enforcing the list order
                            return { connected, paired, available, unknown };
                        }

                        DeviceSection {
                            devices: devicesections.groupeddevices.connected
                            title: Styles.bluetooth.section.titles.connected
                        }

                        DeviceSection {
                            devices: devicesections.groupeddevices.paired
                            title: Styles.bluetooth.section.titles.paired
                        }

                        DeviceSection {
                            devices: devicesections.groupeddevices.available
                            title: Styles.bluetooth.section.titles.available
                        }

                        DeviceSection {
                            devices: devicesections.groupeddevices.unknown
                            title: Styles.bluetooth.section.titles.unknown
                        }
                    }
                }
            }
        }
    }

    ContainerWithTabs {
        id: container
        tabs: Bluetooth.adapters.values.map((e) => ({
            name: e.name.toUpperCase(),
            content: { "adapter": e }
        }))
        template: tabfactory
        title: "Bluetooth Devices"
    }
}