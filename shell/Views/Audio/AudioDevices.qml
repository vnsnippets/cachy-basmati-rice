pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell.Services.Pipewire

import qs
import qs.Layouts
import qs.Services
import qs.Components

ColumnLayout {
    id: root
    spacing: Constants.padding

    StyledText {
        Layout.topMargin: (Constants.padding * 1.5)
        Layout.alignment: Qt.AlignVCenter
        text: "AUDIO CONTROL"
        color: Constants.tab_color_ink_muted
        font.weight: 600
    }

    ContentContainerForTabs {
        id: container

        Component {
            id: component_audio_output
            AudioOutputDevices {
                Layout.fillWidth: true
                nodes: PipewireService.sortedAudioSinks
                defaultNode: PipewireService.defaultSink
            }
        }

        Component {
            id: component_audio_input
            AudioInputDevices {
                Layout.fillWidth: true
                nodes: PipewireService.connectedMicrophones
                defaultNode: Pipewire.defaultAudioSource
            }
        }

        tabs: [
            {
                name: "Speakers",
                template: component_audio_output,
                context: null,
                active: true
            },
            {
                name: "Microphones",
                template: component_audio_input,
                context: null,
                active: true
            }
        ]
    }
}