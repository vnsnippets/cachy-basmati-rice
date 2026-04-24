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
import qs.Widgets

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: status_bar
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

                RowLayout {
                    id: container_left
                    spacing: Theme.spacing
                    Clock { 
                        Layout.alignment: Qt.AlignCenter
                    }
                }

                // --- MIDDLE: Workspace Dots ---
                Rectangle {
                    readonly property int offset: container_right.width - container_left.width

                    Layout.fillWidth: true
                    height: status_bar.height
                    Layout.leftMargin: Math.max(offset, 0)
                    Layout.rightMargin: Math.max(-offset, 0)

                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        spacing: Theme.spacing
                        Layout.alignment: Qt.AlignCenter

                        Item { Layout.fillWidth: true }

                        Repeater {
                            model: 9

                            Base {
                                property var workspace: Hyprland.workspaces.values.find(ws => ws.id === index + 1) ?? null
                                property bool is_active: Hyprland.focusedWorkspace?.id === (index + 1)
                                property bool has_windows: workspace !== null

                                Layout.preferredHeight: 24
                                implicitWidth: is_active ? 40 : 24

                                radius: 20
                                visible: has_windows
                                style.border.idle: Theme.color_slate

                                onClicked: Hyprland.dispatch("workspace " + (index + 1))
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }
                }

                // --- RIGHT --- //
                RowLayout {
                    id: container_right
                    spacing: Theme.spacing
                    
                    Network {
                        Layout.alignment: Qt.AlignCenter
                    }
                    
                    Volume {
                        Layout.alignment: Qt.AlignCenter
                    }
                    
                    Battery {
                        Layout.alignment: Qt.AlignCenter
                    }
                    
                    Profile {
                        Layout.alignment: Qt.AlignCenter
                    }
                    
                    Caffeine {
                        Layout.alignment: Qt.AlignCenter
                    }
                    
                    Power {
                        Layout.alignment: Qt.AlignCenter
                    }
                }
            }
        }
    }
}
