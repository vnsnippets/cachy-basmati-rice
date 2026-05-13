import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

import qs
import qs.Types
import qs.Styles
import qs.Controls
import qs.Utilities
import qs.Views.Cockpit

ShellRoot {
    id: shell
    readonly property bool _DEBUG_MODE_: Quickshell.env("DEBUG") === "1"

    IpcHandler {
        target: "cockpit"
        function toggle() {
            const currentMonitor = Hyprland.focusedMonitor?.name;
            cockpitTargetMonitor = (cockpitTargetMonitor === currentMonitor) ? "" : currentMonitor;
        }
    }

    property string cockpitTargetMonitor: ""

    Variants {
        model: Quickshell.screens
        delegate: Scope {
            id: scope
            required property var modelData

            PanelWindow {
                id: dockspace
                screen: modelData

                anchors { top: true; left: true; right: true }
                margins { top: Style.margin; left: Style.margin; right: Style.margin; } 

                implicitHeight: dock.height
                WlrLayershell.layer: WlrLayer.Bottom

                color: "transparent"

                Dock {
                    id: dock
                    anchors.top: parent.top;
                    anchors.left: parent.left;
                    anchors.right: parent.right;
                }
            }

            Cockpit { id: cockpit; screen: modelData; expand: (modelData.name === cockpitTargetMonitor); }

            // PanelWindow {
            //     id: canvas
            //     screen: modelData

            //     // Full screen — anchored to all four edges
            //     anchors { top: true; left: true; right: true; bottom: true; }
            //     margins { top: Style.margin; left: Style.margin; right: Style.margin; bottom: Style.margin; } 

            //     exclusionMode: ExclusionMode.Ignore
            //     WlrLayershell.layer: WlrLayer.Top

            //     color: "transparent"
            //     surfaceFormat.opaque: false
            //     focusable: false

            //     mask: Region {
            //         Region { item: dock }
            //         Region { item: (panelRight.item) ? panelRight : null }
            //         Region { item: (cockpit.item) ? cockpit : null }
            //     }

            //     Dock {
            //         id: dock
            //         anchors.top: parent.top;
            //         anchors.left: parent.left;
            //         anchors.right: parent.right; 
            //     }

            //     PanelContainer {
            //         id: panelRight
            //         anchors.right: parent.right
            //     }

            //     Cockpit { id: cockpit; anchors.centerIn: parent; }

            //     IpcHandler {
            //         target: "cockpit"
            //         function toggle() { cockpit.expand = !cockpit.expand; }
            //     }

            //     Text { 
            //         text: modelData.name 
            //         color: "red" 
            //         font.pixelSize: 40 
            //     }
            // }

            // Loader {
            //     active: scope.sidePanelOpen
            //     sourceComponent: SidePanel { 
            //         implicitWidth: 350
            //     }
            // }
        }
    }
}
