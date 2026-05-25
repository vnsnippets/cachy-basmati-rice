import QtQuick

import qs.Types
import qs.Assets

Text {
    id: root

    property StateStyle style: StateStyle {
        idle: Style.clickable.text.idle
        active: Style.clickable.text.active
    }

    property bool active: false

    color: (active) ? style.active : style.idle
    font.pixelSize: Style.fonts.size
    font.family: Style.fonts.family
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    visible: text !== ""

    Behavior on color { ColorAnimation { duration: Style.animations.duration; } }

    antialiasing: true
}