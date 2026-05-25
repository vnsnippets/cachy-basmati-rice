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
        text: "Audio Output Devices"
        color: textColor
        font.bold: true
        Layout.alignment: Qt.AlignLeft
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.spacing * 2

        Repeater {
            model: PipewireService.audioSinks.sort((a, b) => {
                // Name/Description: Alphabetical order
                const nameA = a.description ?? a.name ?? '';
                const nameB = b.description ?? b.name ?? '';
                const sortName = nameA.localeCompare(nameB);
                if (sortName !== 0) return sortName;

                // (Fallback) ID: Smaller ID comes first
                return a.id - b.id;
            })
            
            delegate: Clickable {
                readonly property var sinkNode: modelData
                readonly property bool isActive: sinkNode === Pipewire.defaultAudioSink

                enabled: !isActive
                radius: Style.radius/2

                colors.background.idle: isActive ? activeColor : Qt.alpha(Style.colors.surface, 0.60)
                colors.background.active: Qt.alpha(Style.colors.surface, 0.75)

                borderWidth: 0

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: Style.padding
                    rightPadding: Style.padding
                    text: (sinkNode.description || sinkNode.name)
                    color: (sinkNode === PipewireService.defaultSink) ? activeTextColor : textColor
                    elide: Text.ElideRight
                }

                onClicked: Pipewire.preferredDefaultAudioSink = sinkNode;
            }
        }
    }

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
            
            text: PipewireService.defaultSink ? PipewireService.defaultSink.description : "None"
            color: Style.colors.text
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
        }
    }
}