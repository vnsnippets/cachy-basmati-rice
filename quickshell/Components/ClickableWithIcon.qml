import QtQuick
import QtQuick.Controls

import qs.Types
import qs.Utilities

Button {
    id: root

    readonly property int animduration: 200
    required property string iconname
    required property int size

    property bool active: false

    property int radius: 0

    property StateStyle iconstyle: StateStyle {
        idle: "#5A5A5A"
        active: "#000000"
    }

    property bool enablebackground: false
    property StateStyle backgroundstyle: StateStyle {
        idle: "#FAFAFA"
        active: "#FFFFFF"
    }

    padding: 0
    antialiasing: true
    smooth: true

    width: size + padding * 2
    height: size + padding * 2

    // Directly define the background item and toggle its visibility instead
    background: Rectangle {
        visible: root.enablebackground
        radius: root.radius
        color: (enabled && (hovered || active)) ? backgroundstyle.active : backgroundstyle.idle

        Behavior on radius { NumberAnimation { duration: root.animduration } }
        Behavior on color { ColorAnimation { duration: root.animduration } }
        Behavior on border.color { ColorAnimation { duration: root.animduration } }
    }

    icon.width: size
    icon.height: size
    icon.color:  (enabled && (hovered || active)) ? iconstyle.active : iconstyle.idle
    icon.source: Qt.resolvedUrl("../Assets/" + iconname)

    HoverHandler {
        id: hoverhandle
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
    }

    onPressed: scale = 0.94
    onReleased: scale = 1.00

    Behavior on scale { NumberAnimation { duration: root.animduration } }
    Behavior on icon.color { ColorAnimation { duration: root.animduration } }
}