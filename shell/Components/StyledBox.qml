pragma ComponentBehavior: Bound

import QtQuick

Rectangle {
    component ColorStyles: QtObject {
        property color background: "#313244"
        property color border: "#a6adc8"
    }
    
    property ColorStyles colors: ColorStyles {}

    color: colors.background
    border.color: colors.border
    border.width: 1
    radius: 0
    antialiasing: true
    clip: true

    Behavior on color { ColorAnimation { duration: 250 }}
    Behavior on border.color { ColorAnimation { duration: 250 }}
    Behavior on radius { NumberAnimation { duration: 250 } }
}