import QtQuick
import QtQuick.Controls

import qs.Assets

Slider {
    id: root            
    property alias progressWidth: progress.width

    required property color activeColor

    required property color handleColor
    required property color handleBorderColor

    required property color trackColor
    required property int trackHeight

    readonly property int trackYPosition: root.topPadding + root.availableHeight / 2 - height / 2

    Behavior on implicitWidth {
        NumberAnimation { 
            duration: Style.animations.duration
            easing.type: Easing.InOutQuad // Smoother transition
        } 
    }

    // Custom Handle
    handle: Rectangle {
        x: root.progressWidth - width
        y: root.trackYPosition

        implicitWidth: root.trackHeight
        implicitHeight: root.trackHeight

        radius: root.availableHeight/2.5
        border.width: 1
        border.color: root.handleBorderColor
        color: root.handleColor
        scale: root.pressed ? 0.8 : 1

        Behavior on scale { NumberAnimation { duration: 100; easing: Easing.InOutQuad; } }
    }

    // Custom Background (Progress bar)
    background: Rectangle {
        x: root.leftPadding
        y: root.trackYPosition

        implicitHeight: root.trackHeight

        width: root.availableWidth
        height: root.availableHeight

        radius: root.availableHeight/2.5
        color: root.trackColor

        Rectangle {
            id: progress

            readonly property real targetWidth: (root.visualPosition * (parent.width - root.handle.width)) + (root.handle.width)
            
            width: targetWidth
            height: parent.height
            color: root.activeColor
            radius: parent.radius

            Behavior on width {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic // Fast to slow looks better for loading
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPressed: (mouse) => mouse.accepted = false
    }
}