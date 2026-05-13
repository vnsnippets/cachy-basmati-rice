import QtQuick

import qs.Types
import qs.Styles

Text {
    id: root

    property StateStyle style: StateStyle {
        idle: Style.clickable.text.idle
        active: Style.clickable.text.active
    }

    property bool active: false

    color: (active) ? style.active : style.idle
    font.pixelSize: Style.fonts.size
    font.family: Style.fonts.icon
    horizontalAlignment: Text.AlignHCenter
    visible: text !== ""

    Behavior on color { ColorAnimation { duration: Style.animations.duration; } }
}