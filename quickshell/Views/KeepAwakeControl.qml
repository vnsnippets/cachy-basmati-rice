import QtQuick

import Quickshell.Wayland

import qs.Utilities
import qs.Components

ClickableWithIcon {
    IdleInhibitor { id: inhibitor; }

    property color defaultbackground: Qt.alpha(Styles.colors.surface, 0.4) 

    id: keepawake
    size: Styles.size - Styles.padding * 2
    padding: Styles.padding
    enablebackground: true

    iconname: "toggle.svg"
    iconstyle.idle: (inhibitor.enabled) ? Styles.colors.base : Styles.colors.text
    iconstyle.active: Styles.colors.base

    backgroundstyle.idle: (inhibitor.enabled) ? Styles.colors.peach : defaultbackground
    backgroundstyle.active: Styles.colors.peach

    onClicked: inhibitor.enabled = !inhibitor.enabled

    // Rotate the whole component
    rotation: inhibitor.enabled ? 270 : 0
    transformOrigin: Item.Center

    Behavior on rotation { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }

    // scale: (this.hovered) ? 0.96 : 1
    // Behavior on scale { NumberAnimation {  duration: root.animduration } }
}