import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Bluetooth

import qs.Utilities
import qs.Components

ColumnLayout {
    id: root
    
    required property list<BluetoothDevice> devices
    required property string title
    property int animduration: 200

    spacing: Styles.spacing
    visible: repeater.count > 0

    // --- Section: Connected / Paired Devices ---
    StyledText {
        text: root.title + " (" + repeater.count + ")"
        color: Styles.bluetooth.section.titlecolor
        font.bold: true
    }

    Repeater {
        id: repeater

        model: root.devices        

        delegate: Rectangle {
            id: deviceitem
            Layout.fillWidth: true
            height: 52
            radius: Styles.radius
            color: "transparent"

            readonly property BluetoothDevice device: modelData ?? null
            readonly property bool isconnected: (device && device.state === BluetoothDeviceState.Connected)

            // Highlight connected or connecting devices
            border.color: (isconnected) ? Styles.bluetooth.device.border.active : Styles.bluetooth.device.border.idle
            border.width: 1

            readonly property bool paired: device.paired
            onPairedChanged: if (paired && !trusted) trusted = true;

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right

                anchors.margins: Styles.padding
                anchors.verticalCenter: parent.verticalCenter
                spacing: Styles.spacing

                StyledText {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    leftPadding: Styles.padding / 2
                    text: device.deviceName || "Unknown Device"
                    color: (isconnected) ? Styles.bluetooth.device.text.active : Styles.bluetooth.device.text.idle
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }

                StyledText {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    visible: device.batteryAvailable
                    text: "(" + (device.battery * 100).toFixed(0) + "%)"
                    active: (isconnected)
                    color: Qt.alpha(Styles.bluetooth.device.text.idle, 0.6)
                    horizontalAlignment: Text.AlignLeft
                }

                Item { Layout.fillWidth: true }
                
                Clickable {
                    id: deviceaddress
                    styles.background.idle: "transparent"
                    styles.background.active: "transparent"

                    StyledText {
                        Layout.fillWidth: false
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        active: deviceaddress.containsMouse || Quickshell.clipboardText === device.address
                        text: device.address
                        style.idle: Qt.alpha(Styles.bluetooth.device.text.idle, 0.6)
                        style.active: Qt.alpha(Styles.bluetooth.device.text.idle, 1)
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignLeft
                    }

                    onClicked: Quickshell.clipboardText = device.address
                }

                Row {
                    spacing: Styles.spacing / 2
                    Loader {
                        Layout.fillWidth: false
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        active: !device.connected
                        visible: active
                        sourceComponent: ClickableWithIcon {
                            readonly property QtObject styles: Styles.bluetooth.device.connect
                            size: Styles.bluetooth.device.buttonsize
                            padding: Styles.bluetooth.device.buttonsize / 2
                            
                            radius: Styles.radius

                            iconname: styles.icon
                            iconstyle.idle: styles.background
                            iconstyle.active: styles.text

                            enablebackground: true
                            backgroundstyle.idle: Qt.alpha(styles.background, 0.1)
                            backgroundstyle.active: Qt.alpha(styles.background, 1)

                            onClicked: {
                                if (device.paired) device.connect()
                                else Quickshell.execDetached([
                                    "foot", 
                                    "sh", 
                                    "-c", 
                                    `(echo 'agent on'; echo 'default-agent'; echo 'pair ${device.address}'; cat) | bluetoothctl`
                                ]);
                            }
                        }
                    }

                    Loader {
                        Layout.fillWidth: false
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        active: device.connected
                        visible: active
                        sourceComponent: ClickableWithIcon {
                            readonly property QtObject styles: Styles.bluetooth.device.disconnect
                            size: Styles.bluetooth.device.buttonsize
                            padding: Styles.bluetooth.device.buttonsize / 2
                            
                            radius: Styles.radius

                            iconname: styles.icon
                            iconstyle.idle: styles.background
                            iconstyle.active: styles.text

                            enablebackground: true
                            backgroundstyle.idle: Qt.alpha(styles.background, 0.1)
                            backgroundstyle.active: Qt.alpha(styles.background, 1)

                            onClicked: device.disconnect()
                        }
                    }

                    Loader {
                        Layout.fillWidth: false
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        active: device.paired
                        visible: active
                        sourceComponent: ClickableWithIcon {
                            readonly property QtObject styles: Styles.bluetooth.device.forget
                            size: Styles.bluetooth.device.buttonsize
                            padding: Styles.bluetooth.device.buttonsize / 2
                            
                            radius: Styles.radius

                            iconname: styles.icon
                            iconstyle.idle: styles.background
                            iconstyle.active: styles.text

                            enablebackground: true
                            backgroundstyle.idle: Qt.alpha(styles.background, 0.1)
                            backgroundstyle.active: Qt.alpha(styles.background, 1)

                            onClicked: device.forget()
                        }
                    }
                }
            }
        }
    }
}