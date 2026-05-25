import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.Pipewire

import qs.Assets
import qs.Components

TabLayout {
    tabs: [
        { label: "Output Devices", content: outputDevicesComponent },
        { label: "Input Devices", content: inputDevicesComponent }
    ]

    Component {
        id: outputDevicesComponent
        AudioOutputDevices { width: parent.width }
    }

    Component {
        id: inputDevicesComponent
        AudioInputDevices { width: parent.width }
    }
}