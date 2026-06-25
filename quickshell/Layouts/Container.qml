import QtQuick
import QtQuick.Layouts

import qs.Utilities

Item {
    id: root

    signal componentOffloaded;
    
    // --- Configuration ---
    property Component sourceComponent: null 
    required property bool active
    property int duration: Styles.dashboard.animduration

    // Animated state for Loader
    property bool _managedActive: false

    clip: true

    implicitWidth: content.item ? content.item.implicitWidth : 0
    implicitHeight: content.height

    property alias _internalSource: content.sourceComponent
    property bool _switchingSource: false
    
    onSourceComponentChanged: _switchingSource = (_managedActive && _internalSource)

    Loader {
        id: content

        sourceComponent: (root._switchingSource) ? sourceComponent : root.sourceComponent
        active: root._managedActive
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        opacity: 0 //1
        scale: 0.95 //1
        height: item?.implicitHeight ?? 0
        width: parent.width

        onActiveChanged: {
            if (!active) root.componentOffloaded();
        }

        states: [
            State {
                name: "active"
                when: root.active && !_switchingSource && root._managedActive
                PropertyChanges { target: content; opacity: 1; scale: 1.0; }
            },
            State {
                name: "active-no-content"
                when: root.active && _switchingSource
                PropertyChanges { target: content; opacity: 0; scale: 1.0; }
            },
            State {
                name: "inactive"
                when: !root.active || !root._managedActive
                PropertyChanges { target: content; opacity: 0; scale: 0.95; }
            }
        ]

        transitions: [
            Transition {
                to: "active"
                NumberAnimation { properties: "opacity,scale"; duration: root.duration; easing.type: Easing.OutCubic; }
            },
            Transition {
                to: "inactive"
                SequentialAnimation {
                    NumberAnimation { properties: "opacity,scale"; duration: root.duration; easing.type: Easing.InCubic; }
                    PropertyAction { target: root; property: "_managedActive"; value: false; }
                }
            },
            Transition {
                to: "active-no-content"
                SequentialAnimation {
                    NumberAnimation { properties: "opacity,scale"; duration: root.duration; easing.type: Easing.InCubic; }
                    PropertyAction { target: root; property: "_switchingSource"; value: false; }
                    PropertyAction { target: root; property: "_internalSource"; value: root.sourceComponent; }
                }
            }
        ]
    }

    onActiveChanged: if (active) { _managedActive = true; }

    Component.onCompleted: if (active) { _managedActive = true; }
}