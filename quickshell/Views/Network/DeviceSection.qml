import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Networking

import qs.Utilities
import qs.Components

ColumnLayout {
    id: root
    
    required property var networks // List or array of Network objects
    required property string title
    property int animduration: 200

    spacing: Styles.spacing
    visible: repeater.count > 0

    // --- Section Header ---
    StyledText {
        text: root.title + " (" + repeater.count + ")"
        color: Styles.network.section.titlecolor // Reusing your semantic structure
        font.bold: true
    }

    Repeater {
        id: repeater
        model: root.networks        

        delegate: Rectangle {
            id: networkitem
            Layout.fillWidth: true
            height: 52
            radius: Styles.radius
            color: "transparent"

            readonly property Network net: modelData ?? null
            readonly property bool isconnected: (net && net.connected)
            readonly property bool ischanging: (net && net.stateChanging)

            // Highlight border state depending on connection
            border.color: isconnected ? Styles.network.device.border.active : Styles.network.device.border.idle
            border.width: 1

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Styles.padding
                anchors.verticalCenter: parent.verticalCenter
                spacing: Styles.spacing

                // Network Name (SSID)
                StyledText {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    leftPadding: Styles.padding / 2
                    text: net.name || "Hidden Network"
                    color: isconnected ? Styles.network.device.text.active : Styles.network.device.text.idle
                    elide: Text.ElideRight
                }

                // Signal Strength Indicator (Only visible if it's a Wifi Network)
                StyledText {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    visible: net.signalStrength !== undefined
                    text: visible ? "(" + (net.signalStrength * 100).toFixed(0) + "%)" : ""
                    color: Qt.alpha(Styles.network.device.text.idle, 0.6)
                }

                Item { Layout.fillWidth: true }
                
                // Clicking network items lets you easily inspect or capture hardware properties
                Clickable {
                    id: netdetails
                    styles.background.idle: "transparent"
                    styles.background.active: "transparent"

                    StyledText {
                        Layout.fillWidth: false
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        active: netdetails.containsMouse
                        text: ischanging ? "Connecting..." : (isconnected ? "Connected" : "")
                        style.idle: Qt.alpha(Styles.network.device.text.idle, 0.6)
                        style.active: Qt.alpha(Styles.network.device.text.idle, 1)
                    }
                }

                // Action Buttons Block (Connect / Disconnect / Forget)
                Row {
                    spacing: Styles.spacing / 2

                    // Connect Trigger
                    Loader {
                        Layout.fillWidth: false
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        active: !net.connected && !net.stateChanging
                        visible: active
                        sourceComponent: ClickableWithIcon {
                            readonly property QtObject styles: Styles.network.device.connect
                            size: Styles.network.device.buttonsize
                            padding: Styles.network.device.buttonsize / 2
                            radius: Styles.radius
                            iconname: styles.icon
                            iconstyle.idle: styles.background
                            iconstyle.active: styles.text
                            enablebackground: true
                            backgroundstyle.idle: Qt.alpha(styles.background, 0.1)
                            backgroundstyle.active: Qt.alpha(styles.background, 1)

                            onClicked: {
                                // If it is a known network or unprotected, connect immediately
                                if (net.known || !net.security) {
                                    net.connect();
                                } else {
                                    // Fallback text environment launcher for protected configurations 
                                    Quickshell.execDetached([
                                        "foot", "sh", "-c", 
                                        `nmcli device wifi connect "${net.name}"`
                                    ]);
                                }
                            }
                        }
                    }

                    // Disconnect Trigger
                    Loader {
                        Layout.fillWidth: false
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        active: net.connected
                        visible: active
                        sourceComponent: ClickableWithIcon {
                            readonly property QtObject styles: Styles.network.device.disconnect
                            size: Styles.network.device.buttonsize
                            padding: Styles.network.device.buttonsize / 2
                            radius: Styles.radius
                            iconname: styles.icon
                            iconstyle.idle: styles.background
                            iconstyle.active: styles.text
                            enablebackground: true
                            backgroundstyle.idle: Qt.alpha(styles.background, 0.1)
                            backgroundstyle.active: Qt.alpha(styles.background, 1)

                            onClicked: net.disconnect()
                        }
                    }
                }
            }
        }
    }
}