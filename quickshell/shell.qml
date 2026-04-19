import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Widgets

import "./Utilities"
import "./Widgets"
import "./Modules"

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: taskbar
            property var modelData: modelData
            screen: modelData

            implicitHeight: 40

            anchors { top: true; left: true; right: true; }
            margins { top: 10; bottom: 0; left: 10; right: 10; }
            
            color: "transparent"


            RowLayout {
                anchors.fill: parent
                spacing: 0

                // --- LEFT: Clock ---
                Clock {
                    backgroundColor: Theme.background
                    foregroundColor: Theme.foreground
                    borderColor: Theme.border
                    fontSize: Theme.fontsize
                    fontFamily: Theme.fontfamily
                }

                Item { Layout.fillWidth: true } // Spacer

                // --- MIDDLE: Workspace Dots ---
                Row {
                    spacing: 10
                    Layout.alignment: Qt.AlignCenter
                }

                Item { Layout.fillWidth: true }

                // --- RIGHT --- //
                RowLayout {
                    spacing: 4
                    Volume {
                        backgroundColor: Theme.background
                        foregroundColor: Theme.foreground
                        borderColor: Theme.border
                        fontSize: Theme.fontsize
                        fontFamily: Theme.fontfamily
                    }
                }
            }
        }
    }
}
