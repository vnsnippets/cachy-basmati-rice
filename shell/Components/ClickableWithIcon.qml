pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import qs

Button {
    id: clickable

    property string iconname: ""
    property int size: 0

    property bool active: false
    property int radius: 0

    property color background_color: (hovered || active) ? styles.background_color_active : styles.background_color_idle
    property color icon_color: (hovered || active) ? styles.icon_color_active : styles.icon_color_idle

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
    readonly property string _icon_path: (`../${Constants.icons_directory}/${iconname}`).replace("//", "/")

    padding: 0
    hoverEnabled: true
    antialiasing: true
    smooth: true

    width: (size > 0) ? size + padding * 2 : implicitWidth
    height: (size > 0) ? size + padding * 2 : implicitHeight

    background: Rectangle {
        radius: clickable.radius
        color: clickable.background_color

        border.width: clickable.styles.border_width
        border.color: (enabled && (clickable.hovered || clickable.active)) ? clickable.styles.border_color_active : clickable.styles.border_color_idle

        Behavior on radius { NumberAnimation { duration: clickable._animationDuration } }
        Behavior on color { ColorAnimation { duration: clickable._animationDuration } }
        Behavior on border.color { ColorAnimation { duration: clickable._animationDuration } }
    }

    icon.width: (iconname.length > 0) ? size : 0
    icon.height: (iconname.length > 0) ? size : 0
    icon.color: clickable.icon_color
    icon.source: (iconname.length > 0) ? Qt.resolvedUrl(_icon_path) : ""

    onPressed: scale = 0.94
    onReleased: scale = 1.00
    
    font.pixelSize: Constants.font_size
    font.family: Constants.font_family
    font.letterSpacing: Constants.font_spacing

    Behavior on scale { NumberAnimation { duration: clickable._animationDuration } }
    Behavior on icon.color { ColorAnimation { duration: clickable._animationDuration } }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        enabled: false
    }
}