import QtQuick
import QtQuick.Layouts

import qs.Types
import qs.Styles
import qs.Utilities

RowLayout {
    id: root
    spacing: 2

    // activeDevice.Strength comes from your backend (0-100)
    required property int strength
    property int length: 5

    property size dimensions: Qt.size(12, 16)
    property StateStyle colors: StateStyle { idle: Style.colors.subtext; active: Style.colors.green; }

    property bool blinkLastActive: false
    property int animationDelay: 0
    
    Repeater {
        id: repeater
        model: root.length // We want 5 bars
        delegate: Rectangle {
            id: bar
            implicitWidth: root.dimensions.width
            implicitHeight: root.dimensions.height
            
            radius: 2
            
            // Logic: 
            // 0-20: 1 bar, 21-40: 2 bars, 41-60: 3 bars, 61-80: 4 bars, 81-100: 5 bars
            readonly property bool isBarActive: root.strength > (index * 100/root.length)
            readonly property bool isLastActive: index === root.lastActiveIndex && root.blinkLastActive

            color: isBarActive ? root.colors.active : root.colors.idle
            opacity: isBarActive ? 1.0 : 0.3
            scale: 0

            Component.onCompleted: stagger.start()

            Timer {
                id: stagger
                interval: index * 50 // 50ms delay per bar index
                onTriggered: animateIn.start()
            }

            NumberAnimation{ id: animateIn; target: bar; property: "scale"; from: 0; to: 1; duration: 300; easing.type: Easing.OutBack; }

            // Smoothly animate the color change when strength fluctuates
            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on opacity { enabled: !bar.isLastActive; NumberAnimation { duration: 800; } }

            SequentialAnimation on opacity {
                running: bar.isLastActive && bar.isBarActive
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.2; duration: 500; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 0.2; to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
            }
        }
    }
}