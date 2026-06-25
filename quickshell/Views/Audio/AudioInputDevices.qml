import QtQuick

import Quickshell.Services.Pipewire

import qs.Services
import qs.Utilities
import qs.Components

ListView {
    id: root
    required property var devices
    
    // Tells the ScrollView how tall the internal content bounds are
    implicitHeight: contentHeight 
    
    // Prevents the ListView from stealing or fighting the ScrollView's mouse wheels
    interactive: false 

    model: devices
    spacing: Styles.spacing

    delegate: Clickable {
        id: item
        width: root.width // Replaces Layout.fillWidth or anchor stretching inside lists
        height: 48 // Ensure an explicit height is set for list item layout engine tracking

        readonly property var device: modelData
        readonly property bool nodeactive: device === Pipewire.defaultAudioSource

        enabled: (device.plugged && !nodeactive) ?? false
        opacity: device.plugged ? 1 : 0.5

        radius: Styles.radius

        styles.background.idle: nodeactive ? Styles.audio.device.background.active : Styles.audio.device.background.idle
        styles.background.active: Qt.alpha(Styles.audio.device.background.active, 1)

        borderWidth: 0

        StyledText {
            id: devicename
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: Styles.padding
            rightPadding: Styles.padding
            text: device.node.description || device.node.name
            active: (nodeactive || item.containsMouse)
            style.idle: Styles.audio.device.text.idle
            style.active: Styles.audio.device.text.active
            elide: Text.ElideRight
        }

        onClicked: Pipewire.preferredDefaultAudioSource = device;
    }
}