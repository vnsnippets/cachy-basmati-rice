pragma ComponentBehavior: Bound

import QtQuick

import qs

Text {
    id: control

    component Styles: QtObject {
        property color color_idle: "#000000"
        property color color_active: idle
    }

    property Styles styles: Styles { }
    property bool active: false

    readonly property int _animationDuration: Constants.animation_duration

    color: (active) ? styles.color_active : styles.color_idle
    font.pixelSize: Constants.font_size
    font.family: Constants.font_family
    font.letterSpacing: Constants.font_spacing

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    visible: text.trim() !== ""

    antialiasing: true
    
    Behavior on color { ColorAnimation { duration: control._animationDuration } }
}