pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import qs

Slider {
    id: control            
    property alias progressWidth: progress.width

    component Styles: QtObject {
        property color track_color: "#FAFAFA"
        property color accent_color: "#0A0A0A"

        Behavior on accent_color { 
            ColorAnimation { 
                duration: 200
                easing.type: Easing.InOutQuad
            } 
        }
    }

    property int size: 16
    property Styles styles: Styles {}

    readonly property int _trackYPosition: control.topPadding + control.availableHeight / 2 - height / 2
    readonly property int _animationDuration: Constants.animation_duration

    handle: Rectangle {
        x: control.progressWidth - width
        y: control._trackYPosition

        implicitWidth: control.size
        implicitHeight: control.size

        radius: control.availableHeight/4
        border.width: 0
        color: "transparent"
        scale: control.pressed ? 0.8 : 1

        Behavior on scale { NumberAnimation { duration: 100; easing: Easing.InOutQuad; } }
    }

    background: Rectangle {
        x: control.leftPadding
        y: control._trackYPosition

        implicitHeight: control.size

        width: control.availableWidth
        height: control.availableHeight

        radius: control.availableHeight/4
        color: control.styles.track_color

        Rectangle {
            id: progress

            readonly property real targetWidth: (control.visualPosition * (parent.width - control.handle.width)) + (control.handle.width)
            
            width: targetWidth
            height: parent.height
            color: control.styles.accent_color
            radius: parent.radius

            Behavior on width {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
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