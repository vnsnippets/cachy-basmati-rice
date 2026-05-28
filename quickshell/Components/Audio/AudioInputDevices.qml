import QtQuick
import QtQuick.Layouts

import Quickshell.Services.Pipewire

import qs.Assets
import qs.Services
import qs.Utilities
import qs.Components

ColumnLayout {
    id: root
    width: parent ? parent.width : implicitWidth
    spacing: Style.spacing * 4
    readonly property color activeColor: Style.colors.green
    readonly property color activeTextColor: Style.colors.base
    
    readonly property color backgroundColor: Style.colors.surface
    readonly property color textColor: Style.colors.text

    StyledText {
        text: "Audio Input Devices"
        color: textColor
        font.bold: true
        Layout.alignment: Qt.AlignLeft
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.spacing * 2

        Repeater {
            model: PipewireService.connectedMicrophones
            
            delegate: Clickable {
                readonly property PwNode node: modelData.node
                readonly property bool isActive: node === Pipewire.defaultAudioSource

                enabled: (modelData.plugged && !isActive) ?? false
                opacity: modelData.plugged ? 1 : 0.5

                width: parent.width
                radius: Style.radius / 2

                colors.background.idle: isActive ? activeColor : backgroundColor
                colors.background.active: colors.background.idle

                borderWidth: 0

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: Style.padding
                    rightPadding: Style.padding
                    text: node.description || node.name
                    color: isActive ? activeTextColor : textColor
                    elide: Text.ElideRight
                }

                onClicked: Pipewire.preferredDefaultAudioSource = node;
            }
        }
    }

    // Current Active Status Section
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.spacing

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.spacing

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                text: "Current:"
                color: textColor
                font.bold: true
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                text: Pipewire.defaultAudioSource ? Pipewire.defaultAudioSource.description : "No Microphone Detected"
                color: Style.colors.text
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
            }
        }

        Clickable {
            colors.background.idle: Qt.alpha(Style.colors.surface, 0.60)
            colors.background.active: Style.colors.surface
            borderWidth: 0

            StyledText {
                anchors.centerIn: parent
                text: Pipewire.defaultAudioSource?.muted ? "" : ""
                color: Style.colors.text
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
            }
            onClicked: Pipewire.defaultAudioSource.muted = !Pipewire.defaultAudioSource?.muted ?? false
        }
    }
}