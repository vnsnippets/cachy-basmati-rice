pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: 2

    required property real value
    property int length: 5
    property bool blink: false
    property int radius: Constants.radius
    property int progress_height: 16
    
    component Styles: QtObject { 
        property color color_idle: "grey"
        property color color_active: "green"
    }

    property Styles styles: Styles { }

    property int _animation_duration: 200
    
    readonly property int active_index: Math.ceil(value * length) - 1

    Repeater {
        id: repeater
        model: root.length

        delegate: Rectangle {
            id: bar            
            required property int index

            Layout.fillWidth: true
            Layout.preferredHeight: root.progress_height
            radius: root.radius
            
            readonly property bool isBarActive: root.value > (index / root.length)
            readonly property bool isLastActive: index === root.active_index && root.blink

            color: isBarActive ? root.styles.color_active : root.styles.color_idle
            scale: 0

            Component.onCompleted: stagger.start()

            Timer {
                id: stagger
                interval: bar.index * 50 
                onTriggered: animateIn.start()
            }

            NumberAnimation { 
                id: animateIn
                target: bar; property: "scale"; from: 0; to: 1;
                duration: root._animation_duration / 2
            }

            Behavior on color { ColorAnimation { duration: root._animation_duration } }
            
            Behavior on opacity { 
                enabled: !bar.isLastActive
                NumberAnimation { duration: root._animation_duration } 
            }

            SequentialAnimation {
                id: blinkAnim
                running: bar.isLastActive && bar.isBarActive
                loops: Animation.Infinite
                
                NumberAnimation { target: bar; property: "opacity"; to: 0.2; duration: root._animation_duration * 2; easing.type: Easing.InOutQuad }
                NumberAnimation { target: bar; property: "opacity"; to: 1.0; duration: root._animation_duration * 2; easing.type: Easing.InOutQuad }
                
                onRunningChanged: {
                    if (!running) {
                        bar.opacity = bar.isBarActive ? 1.0 : 0.3
                    }
                }
            }
        }
    }
}