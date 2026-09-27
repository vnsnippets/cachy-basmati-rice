pragma ComponentBehavior: Bound

import QtQuick

import qs

Text {
    id: control

    property list<color> colors: [ "#505050", "#000000" ]
    property bool active: false

    readonly property int _animationDuration: Constants.animation_duration

    color: (active) ? colors[1] : colors[0]
    font.pixelSize: Constants.font_size
    font.family: Constants.font_family
    font.letterSpacing: Constants.font_spacing

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    visible: text.trim() !== ""

    antialiasing: true
    
    Behavior on color { ColorAnimation { duration: control._animationDuration } }
}