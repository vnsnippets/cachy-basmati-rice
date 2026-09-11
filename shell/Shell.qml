pragma ComponentBehavior: Bound

import QtQuick

import Quickshell

import qs.Layouts
import qs.Services
import qs.Utilities

ShellRoot {
    id: shell
    readonly property bool _DEBUG_MODE_: Quickshell.env("DEBUG") === "1"

    Variants {
        model: Quickshell.screens
        delegate: Scope {
            id: _Scope
            required property ShellScreen modelData
            readonly property ShellScreen screen: modelData

            property bool osdActive: false

            // OSD Overlay Lifecycle
            Connections {
                target: EventOrchestrator
                
                function onOsdTriggerEvent(key) {
                    _Scope.osdActive = true
                }

                function onOsdDismissEvent() {
                    _Scope.osdActive = false;
                    gc();
                }
            }

            OnScreenDisplayContainer {
                screen: _Scope.screen
                visible: _Scope.osdActive
            }

            NotificationContainer {
                screen: _Scope.screen
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

            Component.onCompleted: DisplayService.init();
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

        Connections {
            target: BacklightService

            function onBrightnessChanged() {
                EventOrchestrator.osdTriggerEvent(EventOrchestrator._BACKLIGHT_OSD_EVENT_KEY, null);
            }
        }
    }
}