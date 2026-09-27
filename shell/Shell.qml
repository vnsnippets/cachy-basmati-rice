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
            id: scope

            required property ShellScreen modelData
            readonly property ShellScreen screen: modelData

            property bool osd_active: false
            property bool console_open: false

            // OSD Overlay Lifecycle
            Connections {
                target: EventOrchestrator
                
                function onOsdTriggerEvent(key) { scope.osd_active = true; }
                function onOsdDismissEvent() { scope.osd_active = false; gc(); }

                // --- Console Events ---
                function onConsoleToggleEvent(targetscreen) {
                    if (scope.console_open) {
                        Debug.log(`[${targetscreen.name}] -> [${scope.screen.name}]`, "Scope ::", "Console Toggle Event : Closing");
                        EventOrchestrator.consoleCloseEvent(scope.screen);
                        return;
                    }

                    if (targetscreen === scope.screen) {
                        Debug.log(`[${targetscreen.name}] -> [${scope.screen.name}]`, "Scope ::", "Console Toggle Event : Opening");
                        scope.console_open = true;
                    }
                }

                function onConsoleCloseCompleted(targetscreen) {
                    if (targetscreen === scope.screen) {
                        Debug.log(`[${targetscreen.name}] -> [${scope.screen.name}]`, "Scope ::", "Console Toggle Event : Closed");
                        scope.console_open = false;
                        gc();
                    }
                }
            }

            OnScreenDisplayContainer { screen: scope.screen; visible: scope.osd_active; }
            NotificationContainer { screen: scope.screen; }
            // PolkitControl { screen: scope.screen; }

            // --- Central Console Loader ---
            LazyLoader {
                activeAsync: scope.console_open
                ConsoleContainer {
                    screen: scope.modelData
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

        // Native Quickshell Polkit Agent backend
        // PolkitAgent {
        //     id: agent
        //     onIsActiveChanged: {
        //         if (agent.isActive)
        //             EventOrchestrator.polkitRequestEvent(agent);
        //     }
        // }
    }
}