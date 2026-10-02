pragma ComponentBehavior: Bound

import QtQuick

import Quickshell
import Quickshell.Wayland

import qs
import qs.Services
import qs.Utilities
import qs.Components
import qs.Views.Audio
import qs.Views.Display

PanelWindow {
    id: container

    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    focusable: false
    color: "transparent"

    implicitWidth: toast_item.implicitWidth
    implicitHeight: toast_item.implicitHeight + (_padding * 2)

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: Constants.namespace
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    readonly property int _animationDuration: Constants.animation_duration
    readonly property int _padding: Constants.osd_offset / 2

    property string activeKey: ""
    property string pendingKey: ""

    property var activePayload: null
    property var pendingPayload: null

    property bool isDismissing: false

    Connections {
        target: EventOrchestrator
        function onOsdTriggerEvent(key, payload) {
            if (toast_item.state === "visible" && container.activeKey === key) {
                container.activePayload = payload;
                timeout_toast.restart();
                return;
            }

            container.pendingKey = key;
            container.pendingPayload = payload;

            if (toast_item.state === "visible") {
                timeout_toast.stop();
                toast_item.state = "hidden";
            } else if (toast_item.state === "hidden" && !transition_exit.running) {
                container.showPendingToast();
            }
        }
    }

    function showPendingToast() {
        if (!container.pendingKey) return;

        container.activeKey = container.pendingKey;
        container.activePayload = container.pendingPayload;

        container.pendingKey = "";
        container.pendingPayload = null;

        toast_component.sourceComponent = container.getComponentForKey(container.activeKey);
        toast_item.state = "visible";
        timeout_toast.restart();

        Debug.log(container.screen.name, "[OSD]", "-", "Open", `(${container.activeKey.toUpperCase()})`);
    }

    function getComponentForKey(key) {
        switch (key) {
            case EventOrchestrator._AUDIO_OSD_EVENT_KEY:
                return component_audio_osd;
            case EventOrchestrator._BACKLIGHT_OSD_EVENT_KEY:
                return component_backlight_osd
            case EventOrchestrator._SCREEN_OSD_EVENT_KEY:
                return component_display_osd
            default:
                return null;
        }
    }

    Timer {
        id: timeout_toast
        interval: Constants.osd_timeout
        onTriggered: {
            toast_item.state = "hidden";
        }
    }

    Clickable {
        id: toast_item

        implicitWidth: toast_component.implicitWidth
        implicitHeight: toast_component.implicitHeight

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: container._padding
        opacity: 0

        onContainsMouseChanged: {
            if (toast_item.state !== "visible") return;
            if (containsMouse) timeout_toast.stop();
            else timeout_toast.restart();
        }

        onClicked: {
            timeout_toast.stop();
            toast_item.state = "hidden";
        }

        Loader {
            id: toast_component
            anchors.fill: parent
        }

        transform: Translate { id: animation_toast_offset; y: Constants.osd_offset * 1.5 }

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
                PropertyChanges { animation_toast_offset.y: Constants.osd_offset * 1.5 }
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
                        container.activeKey = "";
                        container.activePayload = null;
                        
                        if (container.pendingKey !== "") {
                            container.showPendingToast();
                        } else {
                            toast_component.sourceComponent = null;
                            EventOrchestrator.osdDismissEvent();
                            Debug.log(container.screen.name, "[OSD]", "-", "Closed");
                        }
                    }
                }
            }
        ]
    }

    Component {
        id: component_audio_osd

        AudioVolumeControl {
            radius: Constants.radius
            border.width: 1

            styles.background_color: Constants.osd_color_background
            styles.border_color: Constants.osd_color_border
            styles.track_color: Constants.audio_control_color_track
            styles.accent_color: Constants.default_color_accent
            
            implicitWidth: Constants.osd_width
        }
    }

    Component {
        id: component_backlight_osd

        BrightnessControl {
            radius: Constants.radius
            border.width: 1

            styles.background_color: Constants.osd_color_background
            styles.border_color: Constants.osd_color_border
            styles.track_color: Constants.display_control_color_track
            styles.accent_color: Constants.default_color_accent
            
            implicitWidth: Constants.osd_width
        }
    }

    Component {
        id: component_display_osd

        DisplayOSDControl {
            id: display_osd
            border.width: 1
            border.color: Constants.osd_color_border
            color: Constants.osd_color_background
            radius: Constants.radius

            Binding {
                target: display_osd
                property: "payload"
                value: container.activePayload
            }
        }
    }
}