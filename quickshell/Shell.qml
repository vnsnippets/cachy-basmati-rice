import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.UPower

import qs
import qs.Views
import qs.Assets
import qs.Utilities
import qs.Components
import qs.Components.Launcher
import qs.Components.Networks

ShellRoot {
    id: shell
    Component.onCompleted: Hyprland.refreshMonitors();

    // Pre-initialize UPower service at startup so battery status is ready when CentralConsole is opened
    readonly property var _upowerDevice: UPower.displayDevice

    IpcHandler {
        target: "cockpit"
        function run() {
            Hyprland.refreshMonitors()
            shell.monitor = (shell.monitor === Hyprland.focusedMonitor) ? null : Hyprland.focusedMonitor;
            Debug.log("IPC :: ","Current Monitor:", Hyprland.focusedMonitor?.name, "\tRegistered Monitor: ", shell.monitor?.name);
        }
    }

    property var monitor: null

    Variants {
        model: Quickshell.screens
        delegate: Scope {
            id: scope
            required property var modelData

            PanelWindow {
                id: panel
                screen: scope.modelData
                anchors { top: true; left: true; right: true; bottom: true; }
                exclusionMode: ExclusionMode.Ignore
                
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                color: "transparent"
                surfaceFormat.opaque: false
                focusable: false

                mask: Region { item: (panel.isTargeted) ? content : null }

                HyprlandFocusGrab {
                    windows: [panel]
                    active: panel.isTargeted
                    onCleared: shell.monitor = null
                }

                readonly property bool isTargeted: shell.monitor?.name === screen.name ?? false
                readonly property int animationDuration: 300
                

                AnimatedLoader {
                    id: content
                    anchors.centerIn: parent
                    sourceComponent: CentralConsole {
                        tabs: [
                            { icon: "", label: "Apps", content: launcherComponent }
                        ]
                    }
                    active: panel.isTargeted
                }

                Component {
                    id: launcherComponent
                    Launcher { height: 300 }
                }
            }
        }
    }
}
