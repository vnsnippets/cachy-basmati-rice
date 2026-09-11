import QtQuick
import QtQuick.Controls

import qs

Slider {
    id: control            
    property alias progressWidth: progress.width

    component CustomColors: QtObject {
        property color track: "#FAFAFA"
        property color accent: "#0A0A0A"
    }

    property int size: 16
    property CustomColors colors: CustomColors {}

    readonly property int _trackYPosition: control.topPadding + control.availableHeight / 2 - height / 2
    readonly property int _animationDuration: Constants.animation_duration

    // Custom Handle
    handle: Rectangle {
        x: control.progressWidth - width
        y: control._trackYPosition

        implicitWidth: control.size
        implicitHeight: control.size

        radius: control.availableHeight/4
        border.width: 0
        color: control.colors.accent
        scale: control.pressed ? 0.8 : 1

        Behavior on scale { NumberAnimation { duration: 100; easing: Easing.InOutQuad; } }
    }

    // Custom Background (Progress bar)
    background: Rectangle {
        x: control.leftPadding
        y: control._trackYPosition

        implicitHeight: control.size

        width: control.availableWidth
        height: control.availableHeight

        radius: control.availableHeight/4
        color: control.colors.track

        Rectangle {
            id: progress

            readonly property real targetWidth: (control.visualPosition * (parent.width - control.handle.width)) + (control.handle.width)
            
            width: targetWidth
            height: parent.height
            color: control.colors.accent
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