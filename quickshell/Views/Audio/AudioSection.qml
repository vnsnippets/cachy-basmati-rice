import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.Pipewire

import qs.Utilities
import qs.Components

ColumnLayout {
    id: root
    
    required property var nodes // List or array of Pipewire Node objects
    required property string title

    spacing: Styles.spacing
    visible: repeater.count > 0

    // --- Section Header ---
    StyledText {
        text: root.title + " (" + repeater.count + ")"
        color: Styles.network.section.titlecolor
        font.bold: true
    }

    Repeater {
        id: repeater
        model: root.nodes        

        delegate: Rectangle {
            id: nodeItem
            Layout.fillWidth: true
            height: 52
            radius: Styles.radius
            color: "transparent"

            readonly property PwNode node: modelData ?? null
            readonly property bool isActive: (node && node.isDefault)

            // Highlight border state depending on whether it's the active/default route
            border.color: isActive ? Styles.network.device.border.active : Styles.network.device.border.idle
            border.width: 1

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Styles.padding
                anchors.verticalCenter: parent.verticalCenter
                spacing: Styles.spacing

                // Node Name / Description
                StyledText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    leftPadding: Styles.padding / 2
                    text: node.description || node.name || "Unknown Audio Device"
                    color: isActive ? Styles.network.device.text.active : Styles.network.device.text.idle
                    elide: Text.ElideRight
                }

                // Volume Percentage Indicator
                StyledText {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    text: node.muted ? "(Muted)" : "(" + Math.round(node.audio.volume * 100) + "%)"
                    color: Qt.alpha(Styles.network.device.text.idle, 0.6)
                }

                // Action Buttons Block (Set Default / Mute / Unmute)
                Row {
                    spacing: Styles.spacing / 2
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                    // Toggle Mute Button
                    ClickableWithIcon {
                        size: Styles.network.device.buttonsize
                        padding: Styles.network.device.buttonsize / 2
                        radius: Styles.radius
                        
                        // Pick icon depending on mute status
                        iconname: node.muted ? "audio-volume-muted" : "audio-volume-high" 
                        iconstyle.idle: Styles.network.device.connect.background
                        iconstyle.active: Styles.network.device.connect.text
                        
                        enablebackground: true
                        backgroundstyle.idle: Qt.alpha(Styles.network.device.connect.background, 0.1)
                        backgroundstyle.active: Qt.alpha(Styles.network.device.connect.background, 1)

                        onClicked: node.muted = !node.muted
                    }

                    // Set Default Trigger (Only visible if NOT already default)
                    Loader {
                        active: !node.isDefault
                        visible: active
                        sourceComponent: ClickableWithIcon {
                            size: Styles.network.device.buttonsize
                            padding: Styles.network.device.buttonsize / 2
                            radius: Styles.radius
                            
                            iconname: "emblem-default" // Or any standard routing icon
                            iconstyle.idle: Styles.network.device.connect.background
                            iconstyle.active: Styles.network.device.connect.text
                            
                            enablebackground: true
                            backgroundstyle.idle: Qt.alpha(Styles.network.device.connect.background, 0.1)
                            backgroundstyle.active: Qt.alpha(Styles.network.device.connect.background, 1)

                            onClicked: node.isDefault = true
                        }
                    }
                }
            }
        }
    }
}