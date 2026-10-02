pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs
import qs.Utilities

Item {
    id: container

    // Public API
    property Component content: null

    // Pass through implicit dimensions from the loaded item to the outer container
    implicitWidth: loader.item ? loader.implicitWidth : 0
    implicitHeight: loader.implicitHeight ?? 0

    // Internal state tracking
    // property Component _next_content: content
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
                PropertyChanges { loader.opacity: 1; loader.scale: 1.0 }
            },
            State {
                name: "HIDDEN"
                when: container._active_source !== container.content
                PropertyChanges { loader.opacity: 0; loader.scale: 0.99 }
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
                    ScriptAction { script: container._active_source = container.content; }
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
}