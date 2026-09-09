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

            // OSD Overlay Lifecycle
            Connections {
                target: EventOrchestrator
                
                function onOsdTriggerEvent(key) {
                    scope._osdActive = true
                }

                function onOsdDismissEvent() {
                    scope._osdActive = false;
                    gc();
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

    Scope {
        Connections {
            target: Quickshell
            function onScreensChanged() {
                DisplayService.diff((previous, current) => {
                    EventOrchestrator.osdTriggerEvent(EventOrchestrator._SCREEN_OSD_EVENT_KEY, { previous, current });
                });
            }
        }

        // Audio change listeners
        Connections {
            target: PipewireService.defaultSink?.audio ?? null
            
            function onVolumeChanged() {
                EventOrchestrator.osdTriggerEvent(EventOrchestrator._AUDIO_OSD_EVENT_KEY, null);
            }

            function onMutedChanged() {
                EventOrchestrator.osdTriggerEvent(EventOrchestrator._AUDIO_OSD_EVENT_KEY, null);
            }
        }

        Component.onCompleted: DisplayService.init();
    }
}