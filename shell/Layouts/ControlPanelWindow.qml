pragma ComponentBehavior: Bound

import QtQuick

import Quickshell
import Quickshell.Wayland

import qs
import qs.Services
import qs.Views

// qmllint disable
PanelWindow {
// qmllint enable
    id: container

    property bool expanded: true
    function dismiss() { container.expanded = false; }

    Connections {
        target: EventOrchestrator
        function onConsoleCloseEvent() {
            container.dismiss();
        }
    }

    anchors { top: true; left: true; right: true; bottom: true; }
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: Constants.namespace
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    readonly property color backdrop_color: (expanded) ? Constants.console_color_backdrop_active : Constants.console_color_backdrop_inactive

    color: (Constants.console_backdrop_enabled) ? backdrop_color : Constants.color_transparent
    Behavior on color { ColorAnimation { duration: Constants.animation_duration } }

    surfaceFormat.opaque: false
    focusable: true

    TapHandler {
        enabled: container.expanded
        onTapped: EventOrchestrator.consoleDismissContentEvent();
    }

    Console {
        id: centerconsole
        anchors.centerIn: parent
        implicitWidth: Constants.console_width
        
        Keys.onEscapePressed: EventOrchestrator.consoleDismissContentEvent();

        opacity: container.expanded ? 1.0 : 0.0

        Behavior on opacity {
            SequentialAnimation {
                NumberAnimation {
                    duration: Constants.animation_duration
                    easing.type: Easing.Linear
                }
                
                ScriptAction {
                    script: {
                        if (!container.expanded && centerconsole.opacity === 0.0) {
                            EventOrchestrator.consoleCloseCompleted(container.screen);
                        }
                    }
                }
            }
        }

        TapHandler {
            gesturePolicy: TapHandler.WithinBounds
            onTapped: (event) => event.accepted = true
        }
    }
}