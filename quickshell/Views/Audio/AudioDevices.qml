import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets

import qs.Layouts
import qs.Services
import qs.Utilities
import qs.Components
import qs.Components.Controls

Item {
    id: root

    anchors.left: parent.left
    anchors.right: parent.right
    
    implicitHeight: container.implicitHeight
    property int maxheight: 400

    // Component templates without the "required property" binding overhead
    Component {
        id: outputFactory
        AudioOutputDevices {
            devices: PipewireService.sortedAudioSinks
        }
    }

    Component {
        id: inputFactory
        AudioInputDevices {
            devices: PipewireService.connectedMicrophones
        }
    }

    ContainerWithTabs {
        id: container
        title: "Audio Devices"
        
        // Pass the structural component directly in the tab meta-object
        tabs: [
            {
                name: "OUTPUT DEVICES",
                content: { "targetTemplate": outputFactory }
            },
            {
                name: "INPUT DEVICES",
                content: { "targetTemplate": inputFactory }
            }
        ]

        // Handle the instantiation directly at the container factory rule
        template: Component {
            ColumnLayout {
                spacing: Styles.spacing * 2
                
                // Injected via tab meta data safely
                required property Component targetTemplate

                Loader {
                    Layout.fillWidth: true
                    sourceComponent: parent.targetTemplate
                }
            }
        }
    }
}