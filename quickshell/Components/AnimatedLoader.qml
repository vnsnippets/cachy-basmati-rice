import QtQuick
import QtQuick.Layouts

import qs.Utilities

Item {
    id: root
    
    // --- Configuration ---
    property Component sourceComponent: null 
    property bool active: false
    property int duration: 300

    // Animated state for Loader
    property bool _managedActive: false

    clip: true

    implicitWidth: loader.item ? loader.item.implicitWidth : 0
    implicitHeight: loader.height

    property alias _internalSource: loader.sourceComponent
    property bool _switchingSource: false
    
    onSourceComponentChanged: _switchingSource = (_managedActive && _internalSource)

    Loader {
        id: loader
        width: parent.width
        sourceComponent: (root._switchingSource) ? sourceComponent : root.sourceComponent
        active: root._managedActive
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        // opacity: 1
        // scale: 1
        height: item?.implicitHeight ?? 0

        onActiveChanged: {
            Debug.log(
                "Animated Loader ::",
                "Managed Active:", _managedActive,
                "\tActive:", root.active,
                "\tLoader::WxH:", loader.width, loader.height,
                "\tLoader::IWxIH", loader.implicitWidth, loader.implicitHeight,
                "\tRoot::WxH:", root.width, root.height,
                "\tRoot::IWxIH", root.implicitWidth, root.implicitHeight
            )
        }

        states: [
            State {
                name: "active"
                when: root.active && loader.status == Loader.Ready && !_switchingSource
                PropertyChanges { target: loader; opacity: 1; scale: 1.0; height: implicitHeight; }
            },
            State {
                name: "active-no-content"
                when: root.active && loader.status == Loader.Ready && _switchingSource
                PropertyChanges { target: loader; opacity: 0; scale: 1.0; height: 0; }
            },
            State {
                name: "inactive"
                when: !root.active
                PropertyChanges { target: loader; opacity: 0; scale: 0.95; height: 0; }
            }
        ]

        transitions: [
            Transition {
                from: "*"; to: "active"
                NumberAnimation { properties: "opacity,scale,height"; duration: root.duration; easing.type: Easing.OutCubic; }
            },
            Transition {
                from: "active"; to: "inactive"
                SequentialAnimation {
                    NumberAnimation { properties: "opacity,scale,height"; duration: root.duration; easing.type: Easing.InCubic; }
                    PropertyAction { target: root; property: "_managedActive"; value: false; }
                }
            },
            Transition {
                from: "active"; to: "active-no-content"
                SequentialAnimation {
                    NumberAnimation { properties: "opacity,scale,height"; duration: root.duration; easing.type: Easing.InCubic; }
                    PropertyAction { target: root; property: "_switchingSource"; value: false; }
                    PropertyAction { target: root; property: "_internalSource"; value: root.sourceComponent; }
                }
            }
        ]
    }

    onActiveChanged: if (active) { _managedActive = true; }
}