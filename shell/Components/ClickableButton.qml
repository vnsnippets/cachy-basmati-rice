pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import qs

Button {
    id: clickable

    property bool active: false
    property int radius: 0

    // Grouped color definitions eliminate array out-of-bounds risks
    readonly property color background_color: (enabled && (hovered || active)) ? styles.background_color_active : styles.background_color_idle
    readonly property color icon_color: (enabled && (hovered || active)) ? styles.icon_color_active : styles.icon_color_idle

    // Simple custom style container
    component Styles: QtObject {
        property color icon_color_idle: "transparent"
        property color icon_color_active: icon_color_idle

        property color background_color_idle: "transparent"
        property color background_color_active: background_color_idle

        property int border_width: 0
        property color border_color_idle: "transparent"
        property color border_color_active: border_color_idle
    }

    property Styles styles: Styles {}

    readonly property int _animationDuration: Constants.animation_duration

    padding: 0
    hoverEnabled: true
    antialiasing: true
    smooth: true

    // Set pointing hand cursor via MouseArea or background cursor shape
    background: Rectangle {
        radius: clickable.radius
        color: clickable.background_color

        border.width: clickable.styles.border_width
        border.color: (enabled && (clickable.hovered || clickable.active)) ? clickable.styles.border_color_active : clickable.styles.border_color_idle

        Behavior on radius { NumberAnimation { duration: clickable._animationDuration } }
        Behavior on color { ColorAnimation { duration: clickable._animationDuration } }
        Behavior on border.color { ColorAnimation { duration: clickable._animationDuration } }
    }

    // Press scale animation via states or direct signal handlers
    onPressed: scale = 0.94
    onReleased: scale = 1.00
    
    font.pixelSize: Constants.font_size
    font.family: Constants.font_family
    font.letterSpacing: Constants.font_spacing

    Behavior on scale { NumberAnimation { duration: clickable._animationDuration } }

    // Change cursor shape when hovering
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        enabled: false // Let mouse events pass through to Button
    }
}