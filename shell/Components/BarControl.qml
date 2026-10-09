pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property real value
    property int length: 5
    property bool blink: false
    property int radius: 2
    property int spacing: 2
    
    component Styles: QtObject { 
        property color color_idle: "grey"
        property color color_active: "green"
        property color color_border_idle: "transparent"
        property color color_border_active: "transparent"
        property int border_width: 0
    }

    property Styles styles: Styles { }

    property int animation_duration: 200
    
    readonly property int active_index: Math.ceil(value * length) - 1

    RowLayout {
        spacing: root.spacing
        anchors.fill: parent

        Repeater {
            id: repeater
            model: root.length

            delegate: Rectangle {
                id: bar            
                required property int index

                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: root.radius
                
                readonly property bool is_bar_active: root.value > (index / root.length)
                readonly property bool is_last_active: index === root.active_index && root.blink

                color: (is_bar_active) ? root.styles.color_active : root.styles.color_idle
                scale: 0

                border.width: root.styles.border_width
                border.color: (is_bar_active) ? root.styles.color_border_active : root.styles.color_border_idle

                Component.onCompleted: stagger.start()

                Timer {
                    id: stagger
                    interval: bar.index * 50 
                    onTriggered: animateIn.start()
                }

                NumberAnimation { 
                    id: animateIn
                    target: bar; property: "scale"; from: 0; to: 1;
                    duration: root.animation_duration / root.length
                }

                Behavior on color { ColorAnimation { duration: root.animation_duration } }
                
                Behavior on opacity { 
                    enabled: !bar.is_last_active
                    NumberAnimation { duration: root.animation_duration } 
                }

                SequentialAnimation {
                    id: blinkAnim
                    running: bar.is_last_active && bar.is_bar_active
                    loops: Animation.Infinite
                    
                    NumberAnimation { target: bar; property: "opacity"; to: 0.2; duration: root.animation_duration * 2; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: bar; property: "opacity"; to: 1.0; duration: root.animation_duration * 2; easing.type: Easing.InOutQuad }
                    
                    onRunningChanged: if (!running) {
                        bar.opacity = bar.is_bar_active ? 1.0 : 0.3
                    }
                }
            }
        }
    }
}