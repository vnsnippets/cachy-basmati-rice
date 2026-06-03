import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Io
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

    readonly property var _upowerDevice: UPower.displayDevice
    property var activeMonitor: null

    IpcHandler {
        target: "cockpit"
        function run() {
            if (shell.activeMonitor !== null) {
                shell.activeMonitor = null;
            } else {
                shell.activeMonitor = Quickshell.focusedScreen ?? Quickshell.screens[0];
            }
            Debug.log("IPC :: ", "Registered Monitor: ", shell.activeMonitor?.name ?? "None");
        }
    }

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
                WlrLayershell.keyboardFocus: panel.isTargeted ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

                color: "transparent"
                surfaceFormat.opaque: false
                focusable: panel.isTargeted

                mask: Region { item: (panel.isTargeted) ? content : null }

                readonly property bool isTargeted: shell.activeMonitor === screen
                readonly property int animationDuration: 300

                // This background area catches clicks outside the central console to close it
                TapHandler {
                    enabled: panel.isTargeted
                    onTapped: shell.activeMonitor = null
                }

                AnimatedLoader {
                    id: content
                    anchors.centerIn: parent
                    sourceComponent: CentralConsole {
                        tabs: [
                            { icon: "", label: "Apps", content: launcherComponent }
                        ]
                    }
                    active: panel.isTargeted

                    // Prevent clicks inside the console from closing it
                    TapHandler {
                        gesturePolicy: TapHandler.WithinBounds
                        onTapped: (event) => event.accepted = true
                    }
                }

                Component {
                    id: launcherComponent
                    Launcher { height: 300 }
                }
            }
        }
    }
}