import QtQuick
import QtQuick.Controls

import qs
import "../Types" as Types

Button {
    id: clickable

    required property string iconname
    required property int size

    property bool active: false
    property int radius: 0

    component CustomBorderStyle: QtObject {
        property int width: 0
        property color color: "transparent"
    }

    component CustomColorStyle: QtObject {
        property Types.ClickableStyle color: Types.ClickableStyle {}
    }

    component CustomStyles: QtObject {
        property CustomColorStyle icon: CustomColorStyle {}
        property CustomColorStyle background: CustomColorStyle {}
        property CustomBorderStyle border: CustomBorderStyle {}
    }

    readonly property int _animationDuration: Constants.animation_duration
    property CustomStyles styles: CustomStyles {}

    padding: 0
    antialiasing: true
    smooth: true

    width: size + padding * 2
    height: size + padding * 2

    // Directly define the background item and toggle its visibility instead
    background: Rectangle {
        radius: clickable.radius
        color: (enabled && (clickable.hovered || clickable.active)) ? clickable.styles.background.color.active : clickable.styles.background.color.idle

        border.width: clickable.styles.border.width
        border.color: clickable.styles.border.color

        Behavior on radius { NumberAnimation { duration: clickable._animationDuration } }
        Behavior on color { ColorAnimation { duration: clickable._animationDuration } }
        Behavior on border.color { ColorAnimation { duration: clickable._animationDuration } }
    }

    icon.width: size
    icon.height: size
    icon.color:  (enabled && (hovered || active)) ? styles.icon.color.active : styles.icon.color.idle
    icon.source: Qt.resolvedUrl("../Assets/" + iconname)

    HoverHandler {
        id: hoverhandle
        enabled: clickable.enabled
        cursorShape: Qt.PointingHandCursor
    }

    onPressed: scale = 0.94
    onReleased: scale = 1.00

    Behavior on scale { NumberAnimation { duration: clickable._animationDuration } }
    Behavior on icon.color { ColorAnimation { duration: clickable._animationDuration } }
}