pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell.Services.Pipewire

import qs.Layouts
import qs.Services

ContentTabContainer {
    id: container

    title: "Audio Devices"

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
            name: "OUTPUT",
            delegate: component_audio_output
        },
        {
            name: "INPUT",
            delegate: component_audio_input
        }
    ]
}