import QtQuick

import qs.Types
import qs.Utilities

Text {
    id: root

    property StateStyle style: StateStyle {
        idle: Styles.colors.text
        active: Styles.colors.text
    }

    property bool active: false
    property int animduration: 250

    color: (active) ? style.active : style.idle
    font.pixelSize: Styles.font.size
    font.family: Styles.font.family
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    visible: text !== ""

    Behavior on color { ColorAnimation { duration: root.animduration; } }

    antialiasing: true
}