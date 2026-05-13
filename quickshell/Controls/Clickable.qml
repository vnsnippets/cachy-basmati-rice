pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets

import qs
import qs.Types
import qs.Styles
import qs.Utilities

WrapperMouseArea {
    id: root

    default property alias contentData: container.data

    property int radius: Style.clickable.radius

    property QtObject locks: QtObject {
        property bool hover: false
        property bool pressed: false
    }

    property ClickableStyle colors: ClickableStyle {
        background.idle: Style.clickable.background.idle
        border.idle: Style.clickable.border.idle

        background.active: Style.clickable.background.idle
        border.active: Style.clickable.border.active
    }

    implicitWidth: Math.max(container.childrenRect.width, Style.clickable.dimensions.width)
    height: Math.max(container.childrenRect.height, Style.clickable.dimensions.height)

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onPressed: container.scale = 0.94
    onReleased: container.scale = 1.0

    Rectangle {
        id: container
        anchors.left: parent.left
        anchors.right: parent.right
        scale: 1.0

        color: root.containsMouse ? root.colors.background.active : root.colors.background.idle
        border.color: root.containsMouse ? root.colors.border.active : root.colors.border.idle
        border.width: Style.borderWidth

        // Full rounding on hover
        // radius: root.containsMouse ? root.height/2 : root.radius

        // Partial rounding on hover
        radius: root.containsMouse ? root.radius * 1.5 : root.radius
        
        clip: true

        Behavior on scale { NumberAnimation { duration: Style.animations.duration/2; } }
        Behavior on radius { NumberAnimation { duration: Style.animations.duration/2; } }
        Behavior on color { ColorAnimation { duration: Style.animations.duration/2; } }
        Behavior on border.color { ColorAnimation { duration: Style.animations.duration/2; } }
    }
}