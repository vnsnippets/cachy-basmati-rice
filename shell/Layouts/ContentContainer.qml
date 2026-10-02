pragma ComponentBehavior: Bound

import QtQuick

import qs
import qs.Services

Item {
    id: container

    property Component content: null
    implicitHeight: (content) ? loader.implicitHeight ?? 0 : 0

    // Behavior on implicitHeight { NumberAnimation { duration: Constants.animation_duration; easing.type: Easing.Linear } }

    property alias _active_source: loader.sourceComponent

    Loader {
        id: loader
        anchors.fill: parent
        
        opacity: 0
        scale: 0.95

        states: [
            State {
                name: "VISIBLE"
                when: container._active_source === container.content
                PropertyChanges { loader.opacity: 1; loader.scale: 1.0; }
            },
            State {
                name: "HIDDEN"
                when: container._active_source !== container.content
                PropertyChanges { loader.opacity: 0.5; loader.scale: 0.99; }
            }
        ]

        transitions: [
            Transition {
                from: "HIDDEN"
                to: "VISIBLE"
                NumberAnimation { 
                    properties: "opacity,scale"
                    duration: Constants.animation_duration
                    easing.type: Easing.OutCubic 
                }
            },
            Transition {
                from: "VISIBLE"
                to: "HIDDEN"
                SequentialAnimation {
                    NumberAnimation { 
                        properties: "opacity,scale"
                        duration: Constants.animation_duration
                        easing.type: Easing.InCubic 
                    }
                    ScriptAction { 
                        script: {
                            if (container.content) container._active_source = container.content;
                            else EventOrchestrator.consoleCloseEvent()
                        }
                    }
                }
            }
        ]
    }

    Component.onCompleted: container._active_source = container.content;

    onContentChanged: {
        if (container._active_source === null) {
            container._active_source = content;
        }
    }

    Connections {
        target: EventOrchestrator
        function onConsoleDismissContentEvent() {
            container.content = null;
        }
    }
}