pragma ComponentBehavior: Bound

import QtQuick

import Quickshell

import qs
import qs.Services
import qs.Utilities
import "../Components"
import "../Views/Audio"
import "../Views/Display"

Item {
    id: _Container

    required property ShellScreen screen
    readonly property int _animationDuration: Constants.animation_duration

    // Active state properties
    property string activeKey: ""
    property string pendingKey: ""

    // Payload properties
    property var activePayload: null
    property var pendingPayload: null

    property bool isDismissing: false

    implicitWidth: _ToastItem.implicitWidth
    implicitHeight: _ToastItem.implicitHeight

    Connections {
        target: EventOrchestrator
        function onOsdTriggerEvent(key, payload) {
            // Guard: Only handle event if targeted at this screen
            // if (targetScreen !== null && targetScreen !== _Container.screen) return;

            if (_ToastItem.state === "visible" && _Container.activeKey === key) {
                // Same active toast: update payload and refresh timer
                _Container.activePayload = payload;
                _ToastTimeout.restart();
                return;
            }

            // New key and payload incoming
            _Container.pendingKey = key;
            _Container.pendingPayload = payload;

            if (_ToastItem.state === "visible") {
                // Animate out existing toast first
                _ToastTimeout.stop();
                _ToastItem.state = "hidden";
            } else if (_ToastItem.state === "hidden" && !_ExitTransition.running) {
                // Display immediately if idle
                _Container.showPendingToast();
            }
        }
    }

    function showPendingToast() {
        if (!_Container.pendingKey) return;

        _Container.activeKey = _Container.pendingKey;
        _Container.activePayload = _Container.pendingPayload;

        _Container.pendingKey = "";
        _Container.pendingPayload = null;

        _ToastComponentLoader.sourceComponent = _Container.getComponentForKey(_Container.activeKey);
        _ToastItem.state = "visible";
        _ToastTimeout.restart();

        Debug.log(_Container.screen.name, "[OSD]", "-", "Open", `(${_Container.activeKey.toUpperCase()})`);
    }

    function getComponentForKey(key) {
        switch (key) {
            case EventOrchestrator._AUDIO_OSD_EVENT_KEY:
                return _AudioOSD;
            case EventOrchestrator._SCREEN_OSD_EVENT_KEY:
                return _DisplayOSD;
            default:
                return null;
        }
    }

    Timer {
        id: _ToastTimeout
        interval: Constants.osd_timeout
        onTriggered: {
            _ToastItem.state = "hidden";
        }
    }

    Clickable {
        id: _ToastItem

        implicitWidth: _ToastComponentLoader.implicitWidth
        implicitHeight: _ToastComponentLoader.implicitHeight

        anchors.fill: parent
        opacity: 0

        onContainsMouseChanged: {
            if (_ToastItem.state !== "visible") return;
            if (containsMouse) _ToastTimeout.stop();
            else _ToastTimeout.restart();
        }

        onClicked: {
            _ToastTimeout.stop();
            _ToastItem.state = "hidden";
        }

        Loader {
            id: _ToastComponentLoader
            anchors.centerIn: parent
            // Removed active: _ToastTimeout.running
        }

        transform: Translate { id: _ToastOffset; y: Constants.osd_offset_y }

        state: "hidden"

        states: [
            State {
                name: "visible"
                PropertyChanges { _ToastItem.opacity: 1 }
                PropertyChanges { _ToastOffset.y: 0 }
            },
            State {
                name: "hidden"
                PropertyChanges { _ToastItem.opacity: 0 }
                PropertyChanges { _ToastOffset.y: Constants.osd_offset_y }
            }
        ]

        transitions: [
            Transition {
                from: "hidden"
                to: "visible"
                ParallelAnimation {
                    NumberAnimation {
                        target: _ToastItem
                        property: "opacity"
                        duration: _Container._animationDuration
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: _ToastOffset
                        property: "y"
                        duration: _Container._animationDuration
                        easing.type: Easing.OutCubic
                    }
                }
            },
            Transition {
                id: _ExitTransition
                from: "visible"
                to: "hidden"
                ParallelAnimation {
                    NumberAnimation {
                        target: _ToastItem
                        property: "opacity"
                        duration: _Container._animationDuration
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        target: _ToastOffset
                        property: "y"
                        duration: _Container._animationDuration
                        easing.type: Easing.InCubic
                    }
                }
                onRunningChanged: {
                    if (!running && _ToastItem.state === "hidden") {
                        _Container.activeKey = "";
                        _Container.activePayload = null;
                        
                        if (_Container.pendingKey !== "") {
                            // Immediately animate in the newly queued toast
                            _Container.showPendingToast();
                        } else {
                            // Safely unload component AFTER the exit animation completes
                            _ToastComponentLoader.sourceComponent = null;

                            // Signal completion when completely cleared
                            EventOrchestrator.osdDismissEvent();
                            Debug.log(_Container.screen.name, "[OSD]", "-", "Closed");
                        }
                    }
                }
            }
        ]
    }

    Component {
        id: _AudioOSD

        AudioVolumeControl {
            color: Constants.color_base
            radius: Constants.radius
            border.width: 1
            border.color: Constants.color_overlay

            implicitWidth: Constants.osd_width
        }
    }

    Component {
        id: _DisplayOSD

        DisplayOSDControl {
            id: _DisplayControl
            border.width: 1
            border.color: Constants.color_overlay
            color: Constants.color_base
            radius: Constants.radius

            Binding {
                target: _DisplayControl
                property: "payload"
                value: _Container.activePayload
            }
        }
    }
}