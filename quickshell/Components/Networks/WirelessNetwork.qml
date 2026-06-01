import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Networking

import qs.Assets
import qs.Utilities
import qs.Components

ColumnLayout {
    id: root
    spacing: Style.spacing * 4
    width: parent ? parent.width : implicitWidth

    property WifiDevice device: null

    readonly property color activeColor: Style.colors.green

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Style.padding
        Layout.rightMargin: Style.padding
        spacing: Style.spacing

        StyledText {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            
            readonly property var stateMap: ({
                [ConnectionState.Unknown]: { icon: "󰀨", color: Style.colors.red, text: "Offline" },
                [ConnectionState.Disconnected]: { icon: "󰄰", color: Style.colors.subtext, text: "Disconnected" },
                [ConnectionState.Disconnecting]: { icon: "󱥸", color: Style.colors.peach, text: "Disconnecting" },
                [ConnectionState.Connecting]: { icon: "󱥸", color: Style.colors.peach, text: "Connecting"},
                [ConnectionState.Connected]: { icon: "󰄯", color: activeColor, text: "Connected" },
            })

            horizontalAlignment: Text.AlignLeft
            color: stateMap[device.state].color
            text: stateMap[device.state].icon + " " + stateMap[device.state].text + " (" + WifiDeviceMode.toString(device.mode) + ")"
        }

        StyledText {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.rightMargin: Style.spacing
            color: Style.colors.text
            text: "Auto Connect"
        }

        Clickable {
            id: autoconnectToggle
            Layout.rightMargin: Style.padding

            colors.background.idle: device.autoconnect ? activeColor : Style.colors.surface
            colors.background.active: colors.background.idle

            implicitWidth: 20
            implicitHeight: 20
            radius: 4

            borderWidth: 0
            onClicked: device.autoconnect = !device.autoconnect

            StyledText {
                anchors.centerIn: parent
                font.pixelSize: 12
                active: autoconnectToggle.containsMouse
                style.idle: device.autoconnect ? Style.colors.base : Style.colors.text
                style.active: style.idle
                text: device.autoconnect ? "󰄯" : "󰄰"
            }
        }

        StyledText {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.rightMargin: Style.spacing
            color: Style.colors.text
            text: "Scan Networks"
        }

        Clickable {
            id: scanToggle
            colors.background.idle: device.scannerEnabled ? activeColor : Style.colors.surface
            colors.background.active: colors.background.idle

            implicitWidth: 20
            implicitHeight: 20
            radius: 4

            borderWidth: 0
            onClicked: device.scannerEnabled = !device.scannerEnabled

            StyledText {
                anchors.centerIn: parent
                font.pixelSize: 12
                active: scanToggle.containsMouse
                style.idle: device.scannerEnabled ? Style.colors.base : Style.colors.text
                style.active: style.idle
                text: device.scannerEnabled ? "󰄯" : "󰄰"
            }
        }
    }

    ListView {
        model: device.networks.values

        Layout.fillWidth: true
        Layout.leftMargin: Style.padding
        Layout.rightMargin: Style.padding

        spacing: Style.spacing
        implicitHeight: 300

        clip: true

        delegate: Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            readonly property Network network: modelData

            radius: Style.radius/2
            height: 48

            border.color: network.connected ? activeColor : Qt.alpha(Style.colors.surface, 0.60)
            border.width: 1

            color: "transparent"

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.spacing * 2

                StyledText {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    leftPadding: Style.padding
                    text: network.name
                    color: Style.colors.text
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }

                StyledText {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    visible: network.stateChanging
                    text: "󱥸"
                    
                    // Smoothly return to 0 when not running
                    Behavior on rotation { NumberAnimation { duration: 200 } }

                    RotationAnimation on rotation {
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                        running: network.stateChanging
                    }
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    visible: network.connected

                    color: Style.colors.subtext
                    text: "Connected"
                }

                Clickable {
                    id: connectToggle
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    
                    visible: !network.stateChanging
                    Layout.rightMargin: Style.padding

                    colors.background.idle: network.connected ? Style.colors.red : Style.colors.green
                    colors.background.active: colors.background.idle

                    implicitWidth: 28
                    implicitHeight: 28
                    radius: 4

                    borderWidth: 0
                    onClicked: (network.connected) ? network.disconnect() : network.connect()

                    StyledText {
                        anchors.centerIn: parent
                        font.pixelSize: 16
                        active: connectToggle.containsMouse
                        style.idle: Style.colors.base
                        style.active: style.idle
                        text: ""
                    }
                }
            }
        }
    }
}