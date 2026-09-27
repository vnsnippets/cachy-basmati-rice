pragma ComponentBehavior: Bound

import QtQuick

import Quickshell
import Quickshell.Io

import qs.Layouts
import qs.Services
import qs.Utilities

ShellRoot {
    id: shell

    IpcHandler {
        target: "console"
        function toggle() {
            MangoIPCService.current_monitor((e) => {
                const targetscreen = Quickshell.screens.find((s) => s.name === e.monitor);
                if (!targetscreen) return false;
                Debug.log("-----");
                EventOrchestrator.consoleToggleEvent(targetscreen);
            });
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: _Scope

            required property ShellScreen modelData
            readonly property ShellScreen screen: modelData

            property bool osd_active: false
            property bool console_open: false

            // OSD Overlay Lifecycle
            Connections {
                target: EventOrchestrator
                
                function onOsdTriggerEvent(key) { _Scope.osd_active = true; }
                function onOsdDismissEvent() { _Scope.osd_active = false; gc(); }

                // --- Console Events ---
                function onConsoleToggleEvent(targetscreen) {
                    if (_Scope.console_open) {
                        Debug.log(`[${targetscreen.name}] -> [${_Scope.screen.name}]`, "Scope ::", "Console Toggle Event : Closing");
                        EventOrchestrator.consoleCloseEvent(_Scope.screen);
                        return;
                    }

                    if (targetscreen === _Scope.screen) {
                        Debug.log(`[${targetscreen.name}] -> [${_Scope.screen.name}]`, "Scope ::", "Console Toggle Event : Opening");
                        _Scope.console_open = true;
                    }
                }

                function onConsoleCloseCompleted(targetscreen) {
                    if (targetscreen === _Scope.screen) {
                        Debug.log(`[${targetscreen.name}] -> [${_Scope.screen.name}]`, "Scope ::", "Console Toggle Event : Closed");
                        _Scope.console_open = false;
                        gc();
                    }
                }
            }

            OnScreenDisplayContainer { screen: _Scope.screen; visible: _Scope.osd_active; }
            NotificationContainer { screen: _Scope.screen; }

            // --- Central Console Loader ---
            LazyLoader {
                activeAsync: _Scope.console_open
                ConsoleContainer {
                    screen: _Scope.modelData
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