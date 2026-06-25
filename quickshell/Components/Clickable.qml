import QtQuick
import QtQuick.Effects

import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets

import qs
import qs.Types
import qs.Utilities

WrapperMouseArea {
    id: root

    // This exposes whatever layout/items are placed inside Clickable
    default property alias contentData: container.data

    property bool active: containsMouse
    property int radius: Styles.radius
    property int borderWidth: 1

    property QtObject locks: QtObject {
        property bool hover: false
        property bool pressed: false
    }

    property ClickableStyle styles: ClickableStyle {
        background.idle: Styles.colors.mantle
        background.active: Styles.colors.mantle
        border.idle: Styles.colors.mantle
        border.active: Styles.colors.mantle
    }

    property int animduration: 250

    // --- THE DYNAMIC SIZE FIX ---
    // We look at the children inside the container (your ColumnLayout) 
    // to determine how big this component naturally wants to be.
    implicitWidth: container.childrenRect.width
    implicitHeight: container.childrenRect.height

    hoverEnabled: true
    cursorShape: this.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

    onPressed: container.scale = 0.98
    onReleased: container.scale = 1.0

    Behavior on radius { 
        NumberAnimation { duration: root.animduration; easing.type: Easing.OutCubic } 
    }

    Rectangle {
        id: container
        
        // This must use exact pixel dimensions driven by the root size
        // instead of anchors.fill, preventing the layout loop!
        width: root.width
        height: root.height
        scale: 1.0

        color: root.active ? root.styles.background.active : root.styles.background.idle
        border.color: root.active ? root.styles.border.active : root.styles.border.idle
        border.width: root.borderWidth

        antialiasing: true
        smooth: true
        radius: root.radius
        
        clip: true

        Behavior on scale { NumberAnimation { duration: root.animduration/2; } }
        Behavior on color { ColorAnimation { duration: root.animduration/2; } }
        Behavior on border.color { ColorAnimation { duration: root.animduration/2; } }
    }
}