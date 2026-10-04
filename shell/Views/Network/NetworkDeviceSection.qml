pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Networking

import qs
import qs.Components

ColumnLayout {
    id: root
    
    required property var networks // List or array of Network objects
    required property string title

    spacing: Constants.spacing
    visible: repeater.count > 0

    // --- Section Header ---
    StyledText {
        text: root.title + " (" + repeater.count + ")"
        color: Constants.network_device_section_color_title
        font.bold: true
    }

    Repeater {
        id: repeater
        model: root.networks        

        delegate: Rectangle {
            id: item
            Layout.fillWidth: true
            height: Constants.size
            radius: Constants.radius
            color: "transparent"

            required property WifiNetwork modelData
            
            // FIX: Derive connection status directly from modelData
            readonly property bool is_connected: modelData.connected
            readonly property bool is_changing: modelData.stateChanging

            // Highlight border state depending on connection
            border.color: item.is_connected ? Constants.network_device_status_connected : Constants.network_device_status_disconnected
            border.width: 1

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Constants.padding
                anchors.verticalCenter: parent.verticalCenter
                spacing: Constants.spacing

                // Network Name (SSID)
                StyledText {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    leftPadding: Constants.padding / 2
                    text: item.modelData.name || "Hidden Network"
                    color: item.is_connected ? Constants.network_device_color_text_active : Constants.network_device_color_text
                    elide: Text.ElideRight
                }

                // Signal Strength Indicator
                StyledText {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    visible: item.modelData.signalStrength !== undefined
                    text: visible ? "(" + (item.modelData.signalStrength * 100).toFixed(0) + "%)" : ""
                    color: Constants.network_device_color_text
                }

                Item { Layout.fillWidth: true }
                
                Clickable {
                    id: network_details
                    
                    StyledText {
                        Layout.fillWidth: false
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        active: network_details.containsMouse
                        text: item.is_changing ? "Connecting..." : (item.is_connected ? "Connected" : "")
                        styles.color_idle: Constants.network_device_color_text
                        styles.color_active: Constants.network_device_color_text_active
                    }
                }

                // Action Buttons Block (Connect / Disconnect)
                Row {
                    spacing: Constants.spacing / 2

                    // CONNECT BUTTON
                    ClickableWithIcon {
                        visible: !item.is_connected && !item.is_changing
                        size: Constants.icon_size
                        padding: Constants.padding / 2
                        radius: Constants.radius
                        iconname: "plug-connect.svg"
                        styles.icon_color_idle: Constants.color_overlay
                        styles.icon_color_active: Constants.color_green
                        styles.background_color_idle: Constants.color_surface
                        styles.background_color_active: Constants.color_green

                        onClicked: {
                            if (item.modelData.known || !item.modelData.security) {
                                item.modelData.connect();
                            } else {
                                Quickshell.execDetached([
                                    "foot", "sh", "-c", 
                                    `nmcli device wifi connect "${item.modelData.name}"`
                                ]);
                            }
                        }
                    }

                    // DISCONNECT BUTTON
                    ClickableWithIcon {
                        visible: item.is_connected
                        size: Constants.icon_size
                        padding: Constants.padding / 2
                        radius: Constants.radius
                        iconname: "plug-disconnect.svg"
                        styles.icon_color_idle: Constants.color_overlay
                        styles.icon_color_active: Constants.color_red
                        styles.background_color_idle: Constants.color_surface
                        styles.background_color_active: Constants.color_red

                        onClicked: item.modelData.disconnect()
                    }
                }
            }
        }
    }
}