pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import qs
import qs.Services
import qs.Utilities
import "../Views/Audio"
import "../Components"

ColumnLayout {
    id: container

    required property ShellScreen screen
    readonly property int _animationDuration: Constants.animation_duration

    implicitWidth: Constants.osd_width
    spacing: 8

    // Active toast tracking model
    ListModel {
        id: toastModel
    }

    function removeToast(key) {
        for (let i = 0; i < toastModel.count; i++) {
            if (toastModel.get(i).key === key) {
                toastModel.remove(i);
                break;
            }
        }

        // Notify shell when all OSD toasts are cleared
        if (toastModel.count === 0) {
            EventOrchestrator.osdDismissEvent(container.screen);
        }
    }

    Connections {
        target: EventOrchestrator
        function onOsdTriggerEvent(_screen, key) {
            if (_screen === container.screen) {
                for (let i = 0; i < toastModel.count; i++) {
                    if (toastModel.get(i).key === key) {
                        toastModel.setProperty(i, "timestamp", Date.now());
                        return;
                    }
                }

                toastModel.append({ key: key, timestamp: Date.now() });
                Debug.log(container.screen.name, "[OSD]", "-", "Open", `(${key.toUpperCase()})`)
            }
        }
    }

    Repeater {
        model: toastModel

        delegate: Clickable {
            id: item
            
            required property string key
            required property real timestamp
            property bool dismiss_ongoing: false

            Layout.preferredWidth: Constants.osd_width
            Layout.preferredHeight: contentLoader.implicitHeight

            // Per-toast timer
            Timer {
                id: itemTimer
                interval: Constants.osd_timeout
                running: true
                onTriggered: () => {
                    dismiss_ongoing = true;
                    item.state = "hidden";
                }
            }

            // Reset timer when trigger event fires again for this key
            onTimestampChanged: {
                if (dismiss_ongoing) return;
                itemTimer.restart();
            }

            // Pause individual timer on mouse hover
            onContainsMouseChanged: {
                if (dismiss_ongoing) return;
                if (containsMouse) itemTimer.stop();
                else itemTimer.restart();
            }

            onClicked: {
                if (dismiss_ongoing) return;
                itemTimer.stop();
                dismiss_ongoing = true;
                item.state = "hidden";
            }

            // Load the appropriate self-contained OSD component based on key
            Loader {
                id: contentLoader
                anchors.centerIn: parent

                sourceComponent: {
                    switch (item.key) {
                        case EventOrchestrator._AUDIO_OSD_EVENT_KEY:
                            return audio_osd_component;
                        // case "brightness":
                        //     return brightnessOsdComponent;
                        default:
                            return null;
                    }
                }
            }

            // --- Independent Animations ---
            // Start item hidden by default
            state: "hidden"

            // Trigger entry transition as soon as item is mounted
            Component.onCompleted: state = "visible"

            transform: Translate { id: offset; y: Constants.osd_offset_y }

            states: [
                State {
                    name: "visible"
                    PropertyChanges { item.opacity: 1 }
                    PropertyChanges { offset.y: 0 }
                },
                State {
                    name: "hidden"
                    PropertyChanges { item.opacity: 0 }
                    PropertyChanges { offset.y: Constants.osd_offset_y }
                }
            ]

            transitions: [
                Transition {
                    from: "hidden"
                    to: "visible"
                    ParallelAnimation {
                        NumberAnimation {
                            target: item
                            property: "opacity"
                            duration: container._animationDuration
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: offset
                            property: "y"
                            duration: container._animationDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                },
                Transition {
                    from: "visible"
                    to: "hidden"
                    ParallelAnimation {
                        NumberAnimation {
                            target: item
                            property: "opacity"
                            duration: container._animationDuration
                            easing.type: Easing.InCubic
                        }
                        NumberAnimation {
                            target: offset
                            property: "y"
                            duration: container._animationDuration
                            easing.type: Easing.InCubic
                        }
                    }
                    onRunningChanged: {
                        if (!running && item.state === "hidden") {
                            container.removeToast(item.key);
                        }
                    }
                }
            ]
        }
    }

    // Component templates for keys
    Component {
        id: audio_osd_component

        AudioVolumeControl {
            color: Constants.color_base
            radius: Constants.radius
            border.width: 1
            border.color: Constants.color_overlay
        }
    }
}