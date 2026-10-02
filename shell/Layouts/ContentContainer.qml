pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs
import qs.Utilities

Loader {
    id: container
    
    required property Component content

    property bool _managedActive: false
    property bool _switchingSource: false

    opacity: 0
    scale: 0.95

    sourceComponent: content

    states: [
        State {
            name: "active"
            when: container.item && container.active
            PropertyChanges { container.opacity: 1; container.scale: 1 }
        }
    ]

    // states: [
    //     State {
    //         name: "active"
    //         when: root.active && !root._switchingSource && root._managedActive
    //         PropertyChanges { content.opacity: 1; content.scale: 1.0; }
    //     },
    //     State {
    //         name: "active-no-content"
    //         when: root.active && root._switchingSource
    //         PropertyChanges { content.opacity: 0; content.scale: 1.0; }
    //     },
    //     State {
    //         name: "inactive"
    //         when: !root.active || !root._managedActive
    //         PropertyChanges { content.opacity: 0; content.scale: 0.95; }
    //     }
    // ]

    // transitions: [
    //     Transition {
    //         to: "active"
    //         NumberAnimation { properties: "opacity,scale"; duration: Constants.animation_duration; easing.type: Easing.OutCubic; }
    //     },
    //     Transition {
    //         to: "inactive"
    //         SequentialAnimation {
    //             NumberAnimation { properties: "opacity,scale"; duration: Constants.animation_duration; easing.type: Easing.InCubic; }
    //             PropertyAction { target: root; property: "_managedActive"; value: false; }
    //         }
    //     },
    //     Transition {
    //         to: "active-no-content"
    //         SequentialAnimation {
    //             NumberAnimation { properties: "opacity,scale"; duration: Constants.animation_duration; easing.type: Easing.InCubic; }
    //             PropertyAction { target: root; property: "_switchingSource"; value: false; }
    //             PropertyAction { target: root; property: "_internalSource"; value: root.sourceComponent; }
    //         }
    //     }
    // ]
}

// Item {
//     id: root

//     signal componentOffloaded;
    
//     property Component sourceComponent: null 
//     required property bool active
//     property int duration: Constants.animation_duration

//     property bool _managedActive: false

//     clip: true

//     implicitWidth: parent.implicitWidth
//     implicitHeight: content.height

//     property alias _internalSource: content.sourceComponent
//     property bool _switchingSource: false
    
//     onSourceComponentChanged: _switchingSource = (_managedActive && _internalSource)

//     Loader {
//         id: content

//         sourceComponent: (root._switchingSource) ? sourceComponent : root.sourceComponent
//         active: root._managedActive
//         anchors.horizontalCenter: parent.horizontalCenter
//         anchors.verticalCenter: parent.verticalCenter

//         opacity: 0 //1
//         scale: 0.95 //1
//         width: parent.width

//         onActiveChanged: {
//             if (!active) root.componentOffloaded();
//         }

//         states: [
//             State {
//                 name: "active"
//                 when: root.active && !root._switchingSource && root._managedActive
//                 PropertyChanges { content.opacity: 1; content.scale: 1.0; }
//             },
//             State {
//                 name: "active-no-content"
//                 when: root.active && root._switchingSource
//                 PropertyChanges { content.opacity: 0; content.scale: 1.0; }
//             },
//             State {
//                 name: "inactive"
//                 when: !root.active || !root._managedActive
//                 PropertyChanges { content.opacity: 0; content.scale: 0.95; }
//             }
//         ]

//         transitions: [
//             Transition {
//                 to: "active"
//                 NumberAnimation { properties: "opacity,scale"; duration: root.duration; easing.type: Easing.OutCubic; }
//             },
//             Transition {
//                 to: "inactive"
//                 SequentialAnimation {
//                     NumberAnimation { properties: "opacity,scale"; duration: root.duration; easing.type: Easing.InCubic; }
//                     PropertyAction { target: root; property: "_managedActive"; value: false; }
//                 }
//             },
//             Transition {
//                 to: "active-no-content"
//                 SequentialAnimation {
//                     NumberAnimation { properties: "opacity,scale"; duration: root.duration; easing.type: Easing.InCubic; }
//                     PropertyAction { target: root; property: "_switchingSource"; value: false; }
//                     PropertyAction { target: root; property: "_internalSource"; value: root.sourceComponent; }
//                 }
//             }
//         ]
//     }

//     onActiveChanged: if (active) { _managedActive = true; }

//     Component.onCompleted: if (active) { _managedActive = true; }
// }