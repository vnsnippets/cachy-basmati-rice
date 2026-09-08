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

    component CustomStyles: QtObject {
        property Types.ClickableStyle icon: Types.ClickableStyle {}
        property Types.ClickableStyle background: Types.ClickableStyle {}
    }

    readonly property int _animationDuration: Constants.animation_duration
    property CustomStyles colors: CustomStyles {}

    padding: 0
    antialiasing: true
    smooth: true

    width: size + padding * 2
    height: size + padding * 2

    // Directly define the background item and toggle its visibility instead
    background: Rectangle {
        visible: clickable.colors.background !== null
        radius: clickable.radius
        color: (enabled && (clickable.hovered || clickable.active)) ? clickable.colors.background.active : clickable.colors.background.idle

        Behavior on radius { NumberAnimation { duration: clickable._animationDuration } }
        Behavior on color { ColorAnimation { duration: clickable._animationDuration } }
        Behavior on border.color { ColorAnimation { duration: clickable._animationDuration } }
    }

    icon.width: size
    icon.height: size
    icon.color:  (enabled && (hovered || active)) ? clickable.colors.icon.active : clickable.colors.icon.idle
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