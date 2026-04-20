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

    readonly property int defaultSpacing: 4
    readonly property int defaultSize: 40
    readonly property int defaultMargin: 10

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: taskbar
            property var modelData: modelData
            screen: modelData

            implicitHeight: defaultSize

            anchors { top: true; left: true; right: true; }
            margins { top: defaultMargin; bottom: 0; left: defaultMargin; right: defaultMargin; }
            
            color: "transparent"


            RowLayout {
                anchors.fill: parent
                spacing: defaultSpacing

                // --- LEFT: Clock ---
                Clock { id: clockWidget }

                Item { Layout.fillWidth: true } // Spacer

                // --- MIDDLE: Workspace Dots ---
                Row {
                    spacing: defaultSpacing
                    Layout.alignment: Qt.AlignCenter
                }

                Item { Layout.fillWidth: true }

                // --- RIGHT --- //
                RowLayout {
                    spacing: defaultSpacing
                    Volume { id: volumeWidget }
                    Battery { id: batteryWidget }
                    Profile { id: profileWidget }
                    Power { id: powerWidget }
                }
            }
        }
    }
}
