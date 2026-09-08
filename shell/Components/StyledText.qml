import QtQuick

import qs
import "../Types" as Types

Text {
    id: control

    property Types.ClickableStyle colors: Types.ClickableStyle {}
    property bool active: false

    readonly property int _animationDuration: Constants.animation_duration

    color: (active) ? colors.active : colors.idle
    font.pixelSize: Constants.font_size
    font.family: Constants.font_family

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    visible: text.trim() !== ""

    antialiasing: true
    
    Behavior on color { ColorAnimation { duration: control._animationDuration } }
}