import QtQuick
import QtQuick.Layouts

import qs.Types
import qs.Utilities

RowLayout {
    id: root
    spacing: 2

    required property real value
    property int length: 5

    // Width is now dynamic, so dimensions only handles height (or fallback)
    property size dimensions: Qt.size(12, 16)
    
    property StateStyle styles: StateStyle { 
        idle: Styles.styles.subtext 
        active: Styles.styles.green 
    }

    property bool blinkLastActive: false
    property int animduration: 200
    
    readonly property int lastActiveIndex: Math.ceil(value * length) - 1

    Repeater {
        id: repeater
        model: root.length
        
        delegate: Rectangle {
            id: bar
            
            // FIX: Allow the RowLayout to size the width equally
            Layout.fillWidth: true
            implicitHeight: root.dimensions.height
            radius: 2
            
            readonly property bool isBarActive: root.value > (index / root.length)
            readonly property bool isLastActive: index === root.lastActiveIndex && root.blinkLastActive

            color: isBarActive ? root.styles.active : root.styles.idle
            scale: 0

            Component.onCompleted: stagger.start()

            Timer {
                id: stagger
                interval: index * 50 
                onTriggered: animateIn.start()
            }

            NumberAnimation { 
                id: animateIn
                target: bar; property: "scale"; from: 0; to: 1;
                duration: root.animduration / 2
            }

            Behavior on color { ColorAnimation { duration: root.animduration } }
            
            Behavior on opacity { 
                enabled: !bar.isLastActive
                NumberAnimation { duration: root.animduration } 
            }

            SequentialAnimation {
                id: blinkAnim
                running: bar.isLastActive && bar.isBarActive
                loops: Animation.Infinite
                
                NumberAnimation { target: bar; property: "opacity"; to: 0.2; duration: root.animduration * 2; easing.type: Easing.InOutQuad }
                NumberAnimation { target: bar; property: "opacity"; to: 1.0; duration: root.animduration * 2; easing.type: Easing.InOutQuad }
                
                onRunningChanged: {
                    if (!running) {
                        bar.opacity = bar.isBarActive ? 1.0 : 0.3
                    }
                }
            }
        }
    }
}
