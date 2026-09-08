pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Wayland

import qs
import qs.Layouts
import qs.Services
import qs.Utilities

ShellRoot {
    id: shell
    readonly property bool _DEBUG_MODE_: Quickshell.env("DEBUG") === "1"

    Variants {
        model: Quickshell.screens
        delegate: Scope {
            id: scope
            required property ShellScreen modelData
            readonly property ShellScreen screen: modelData

            property bool _osdActive: false

            Connections {
                target: PipewireService.defaultSink?.audio ?? null

                function onVolumeChanged() { 
                    EventOrchestrator.osdTriggerEvent(scope.screen, EventOrchestrator._AUDIO_OSD_EVENT_KEY)
                }
                function onMutedChanged() { 
                    EventOrchestrator.osdTriggerEvent(scope.screen, EventOrchestrator._AUDIO_OSD_EVENT_KEY)
                }
            }

            Connections {
                target: EventOrchestrator
                
                function onOsdTriggerEvent(screen, key) {
                    if (screen === scope.screen) {
                        scope._osdActive = true
                    }
                }

                function onOsdDismissEvent(screen) {
                    if (screen === scope.screen) {
                        Debug.log(screen.name, "[OSD]", "-", "Closed");
                        scope._osdActive = false;
                        gc();
                    }
                }
            }

            Loader {
                active: scope._osdActive

                PanelWindow {
                    screen: scope.screen
                    
                    anchors.bottom: true
                    anchors.left: true
                    anchors.right: true

                    exclusionMode: ExclusionMode.Ignore

                    WlrLayershell.namespace: Constants.namespace
                    WlrLayershell.layer: WlrLayer.Overlay
                    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                    focusable: false
                    color: "transparent"

                    mask: Region { item: osd }

                    ToastContainer {
                        id: osd
                        screen: scope.screen
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }
}