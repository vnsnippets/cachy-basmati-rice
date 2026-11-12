pragma ComponentBehavior: Bound

import QtQuick

import Quickshell
import Quickshell.Wayland

import qs
import qs.Services
import qs.Utilities
import qs.Components
import qs.Views.Toasts

PanelWindow {
    id: container

    anchors.top: true

    focusable: true
    color: "transparent"

    implicitWidth: toast_item.implicitWidth
    implicitHeight: toast_item.implicitHeight + (_padding * 2)

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    readonly property int _animationDuration: Constants.animation_duration
    readonly property int _padding: Constants.toast_offset / 2

    property var activeAgent: null
    property var pendingAgent: null
    property bool dismissRequested: false

    visible: activeAgent !== null

    Connections {
        target: EventOrchestrator

        function onPolkitEvent(agent) {
            if (!agent) return;

            if (toast_item.state === "visible" && container.activeAgent !== null) {
                container.pendingAgent = agent;
                return;
            }

            container.dismissRequested = false;
            container.activeAgent = agent;
            toast_component.sourceComponent = component_polkit_toast;
            toast_item.state = "visible";
        }
    }

    function dismiss_current_toast() {
        if (toast_item.state === "visible") {
            toast_item.state = "hidden";
        }
    }

    function show_next_toast() {
        if (!container.pendingAgent) return;

        container.dismissRequested = false;
        container.activeAgent = container.pendingAgent;
        container.pendingAgent = null;

        toast_component.sourceComponent = component_polkit_toast;
        toast_item.state = "visible";
    }

    Item {
        id: toast_item

        implicitWidth: toast_component.implicitWidth
        implicitHeight: toast_component.implicitHeight

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: container._padding
        opacity: 0

        Loader {
            id: toast_component
            anchors.fill: parent
        }

        transform: Translate { id: animation_toast_offset; y: -(Constants.toast_offset * 1.5) }

        state: "hidden"

        states: [
            State {
                name: "visible"
                PropertyChanges { toast_item.opacity: 1 }
                PropertyChanges { animation_toast_offset.y: 0 }
            },
            State {
                name: "hidden"
                PropertyChanges { toast_item.opacity: 0 }
                PropertyChanges { animation_toast_offset.y: -(Constants.toast_offset * 1.5) }
            }
        ]

        transitions: [
            Transition {
                from: "hidden"
                to: "visible"
                ParallelAnimation {
                    NumberAnimation {
                        target: toast_item
                        property: "opacity"
                        duration: container._animationDuration
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: animation_toast_offset
                        property: "y"
                        duration: container._animationDuration
                        easing.type: Easing.OutCubic
                    }
                }
            },
            Transition {
                id: transition_exit
                from: "visible"
                to: "hidden"
                ParallelAnimation {
                    NumberAnimation {
                        target: toast_item
                        property: "opacity"
                        duration: container._animationDuration
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        target: animation_toast_offset
                        property: "y"
                        duration: container._animationDuration
                        easing.type: Easing.InCubic
                    }
                }
                onRunningChanged: {
                    if (!running && toast_item.state === "hidden") {
                        // Cancel the auth request *after* the exit animation finishes
                        if (container.dismissRequested && container.activeAgent?.flow) {
                            container.activeAgent.flow.cancelAuthenticationRequest();
                        }

                        container.activeAgent = null;
                        container.dismissRequested = false;
                        toast_component.sourceComponent = null;
                        
                        if (container.pendingAgent !== null) {
                            container.show_next_toast();
                        }
                    }
                }
            }
        ]
    }

    Component {
        id: component_polkit_toast

        PolkitRequestToast {
            colors.border: Constants.toast_color_border
            colors.background: Constants.toast_color_background
            radius: Constants.radius
            implicitWidth: Constants.toast_width

            agent: container.activeAgent

            onDismiss: {
                container.dismissRequested = true;
                container.dismiss_current_toast();
            }

            Connections {
                target: container.activeAgent
                function onIsActiveChanged() {
                    if (container.activeAgent && !container.activeAgent.isActive) {
                        container.dismiss_current_toast();
                    }
                }
            }
        }
    }
}