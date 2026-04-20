import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Widgets

import qs
import qs.Utilities
import qs.Widgets

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: taskbar
            property var modelData: modelData
            screen: modelData

            implicitHeight: Theme.size

            anchors { top: true; left: true; right: true; }
            margins { top: Theme.margin; bottom: 0; left: Theme.margin; right: Theme.margin; }
            
            color: "transparent"


            RowLayout {
                anchors.fill: parent
                spacing: Theme.spacing

                // --- LEFT: Clock ---
                Clock { id: clockWidget }

                Item { Layout.fillWidth: true } // Spacer

                // --- MIDDLE: Workspace Dots ---
                Row {
                    spacing: Theme.spacing
                    Layout.alignment: Qt.AlignCenter
                }

                Item { Layout.fillWidth: true }

                // --- RIGHT --- //
                RowLayout {
                    spacing: Theme.spacing
                    Network { id: networkWidget }
                    Volume { id: volumeWidget }
                    Battery { id: batteryWidget }
                    Profile { id: profileWidget }
                    Power { id: powerWidget }
                }
            }
        }
    }
}
