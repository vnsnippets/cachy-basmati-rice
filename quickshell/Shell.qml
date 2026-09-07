import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

import qs
import qs.Views
import qs.Layouts
import qs.Services
import qs.Utilities
import qs.Views.Audio

ShellRoot {
    id: shell
    readonly property bool _DEBUG_MODE_: Quickshell.env("DEBUG") === "1"

    IpcHandler {
        target: "console"
        function toggle() {
            MangoIPCService.getcurrentmonitor((e) => {
                const targetscreen = Quickshell.screens.find((s) => s.name === e);
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
            property bool consoleopen: false
            property bool osdopen: false

            function showaudioosd() {
                if (scope.consoleopen) return;
                if (scope.osdopen) {
                    EventOrchestrator.osdTimeoutEvent(scope.screen);
                    return;
                }
                
                MangoIPCService.getcurrentmonitor((e) => {
                    if (e === scope.screen.name) {
                        Debug.log(`[${e}] -> [${scope.screen.name}]`, "Scope ::", "OSD : Open - Volume Changed");
                        scope.osdopen = true;
                        EventOrchestrator.osdTimeoutEvent(scope.screen);
                    }
                });
            }

            Connections {
                target: PipewireService.defaultSink?.audio ?? null
                function onVolumeChanged() { showaudioosd(); }
                function onMutedChanged() { showaudioosd(); }
            }

            Connections {
                target: EventOrchestrator

                // --- Console Events ---
                function onConsoleToggleEvent(targetscreen) {
                    if (scope.consoleopen) {
                        Debug.log(`[${targetscreen.name}] -> [${scope.screen.name}]`, "Scope ::", "Console Toggle Event : Closing");
                        EventOrchestrator.consoleCloseEvent(scope.screen);
                        return;
                    }

                    if (targetscreen === scope.screen) {
                        Debug.log(`[${targetscreen.name}] -> [${scope.screen.name}]`, "Scope ::", "Console Toggle Event : Opening");
                        scope.consoleopen = true;
                    }
                }

                function onConsoleCloseCompleted(targetscreen) {
                    if (targetscreen === scope.screen) {
                        Debug.log(`[${targetscreen.name}] -> [${scope.screen.name}]`, "Scope ::", "Console Toggle Event : Closed");
                        scope.consoleopen = false;
                        gc();
                    }
                }

                // --- Audio OSD Events ---
                function onOsdCloseEvent(targetscreen) {
                    if (targetscreen === scope.screen) {
                        Debug.log(`[${targetscreen.name}] -> [${scope.screen.name}]`, "Scope ::", "OSD Toggle Event : Closed");
                        scope.osdopen = false;
                        gc();
                    }
                }
            }

            // --- Central Console Loader ---
            LazyLoader {
                activeAsync: scope.consoleopen

                PanelWindow {
                    id: canvas
                    screen: modelData
                    property bool expanded: true
                    function dismiss() { canvas.expanded = false; }

                    Connections {
                        target: EventOrchestrator
                        function onConsoleCloseEvent(targetscreen) {
                            if (targetscreen === canvas.screen) {
                                Debug.log(`[${targetscreen.name}] -> [${canvas.screen.name}]`, "PanelWindow ::", "Console Toggle Event : Closing");
                                canvas.dismiss();
                            }
                        }
                    }

                    anchors { top: true; left: true; right: true; bottom: true; }
                    exclusionMode: ExclusionMode.Ignore
                    
                    WlrLayershell.namespace: Styles.namespace
                    WlrLayershell.layer: WlrLayer.Top
                    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

                    color: (expanded) ? Qt.alpha(Styles.colors.mantle, 0.6) : Qt.alpha(Styles.colors.crust, 0)
                    Behavior on color { ColorAnimation { duration: 200 } }

                    surfaceFormat.opaque: false
                    focusable: true

                    TapHandler {
                        enabled: canvas.expanded
                        onTapped: canvas.dismiss()
                    }

                    Console {
                        id: centerconsole
                        anchors.centerIn: parent
                        implicitWidth: Styles.dashboard.width
                        Keys.onEscapePressed: canvas.dismiss()

                        opacity: (canvas.expanded) ? 1 : 0
                        height: (canvas.expanded) ? implicitHeight : 0
                        scale: (canvas.expanded) ? 1 : 0.95

                        visible: opacity > 0
                        onVisibleChanged: if (!visible) EventOrchestrator.consoleCloseCompleted(canvas.screen)

                        Behavior on opacity { NumberAnimation { duration: Styles.dashboard.animduration; easing.type: Easing.OutCubic } }
                        Behavior on scale { NumberAnimation { duration: Styles.dashboard.animduration; easing.type: Easing.Linear } }
                        Behavior on height { NumberAnimation { duration: Styles.dashboard.animduration; easing.type: Easing.Linear } }

                        // Prevent clicks inside the console from closing it
                        TapHandler {
                            gesturePolicy: TapHandler.WithinBounds
                            onTapped: (event) => event.accepted = true
                        }
                    }
                }
            }

            // --- Audio OSD Loader ---
            LazyLoader {
                activeAsync: scope.osdopen

                PanelWindow {
                    id: osdCanvas
                    screen: scope.screen

                    anchors { bottom: true; left: true; right: true; }
                    exclusionMode: ExclusionMode.Ignore

                    WlrLayershell.namespace: Styles.namespace
                    WlrLayershell.layer: WlrLayer.Overlay
                    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                    focusable: false
                    color: "transparent"

                    mask: Region { item: audioosd }

                    AudioOSDControl {
                        id: audioosd
                        screen: osdCanvas.screen       
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}