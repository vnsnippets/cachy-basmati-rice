pragma ComponentBehavior: Bound

import QtQuick

import Quickshell
import Quickshell.Wayland

import qs
import qs.Services
import qs.Utilities
import qs.Views

// qmllint disable
PanelWindow {
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

    color: (expanded) ? Qt.alpha(Constants.console_color_backdrop, 0.6) : Qt.alpha(Constants.console_color_backdrop, 0)
    Behavior on color { ColorAnimation { duration: 200 } }

    surfaceFormat.opaque: false
    focusable: true

    TapHandler {
        enabled: container.expanded
        onTapped: container.dismiss()
    }

    Console {
        id: centerconsole
        anchors.centerIn: parent
        implicitWidth: Constants.console_width
        Keys.onEscapePressed: container.dismiss()

        opacity: (container.expanded) ? 1 : 0
        // height: (container.expanded) ? implicitHeight : 0
        // scale: (container.expanded) ? 1 : 0.95

        visible: opacity > 0
        onVisibleChanged: if (!visible) EventOrchestrator.consoleCloseCompleted(container.screen)

        Behavior on opacity { NumberAnimation { duration: Constants.animation_duration/2; easing.type: Easing.OutCubic } }
        // Behavior on scale { NumberAnimation { duration: Constants.animation_duration; easing.type: Easing.Linear } }
        Behavior on implicitHeight { NumberAnimation { duration: Constants.animation_duration/2; easing.type: Easing.Linear } }

        // Prevent clicks inside the console from closing it
        TapHandler {
            gesturePolicy: TapHandler.WithinBounds
            onTapped: (event) => event.accepted = true
        }
    }
}