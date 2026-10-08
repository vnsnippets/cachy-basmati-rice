import QtQuick

import Quickshell.Wayland

import qs
import qs.Components

ClickableWithIcon {
    required property IdleInhibitor inhibitor
    active: inhibitor.enabled || anim_rotation.running

    id: keepawake
    size: Constants.icon_size
    padding: Constants.padding
    radius: (inhibitor.enabled) ? Constants.icon_size : Constants.radius

    iconname: "toggle.svg"

    styles.background_color_idle: Constants.control_color_background_default
    styles.background_color_active: Constants.keepawake_color_active
    styles.icon_color_idle: Constants.keepawake_color_ink_default
    styles.icon_color_active: Constants.keepawake_color_ink_active

    styles.border_width: 1
    styles.border_color_idle: Constants.control_color_border_default
    styles.border_color_active: Constants.keepawake_color_active

    onClicked: inhibitor.enabled = !inhibitor.enabled

    // Rotate the whole component
    rotation: inhibitor.enabled ? 270 : 0
    transformOrigin: Item.Center

    Behavior on rotation { NumberAnimation { id: anim_rotation; duration: Constants.animation_duration; easing.type: Easing.InOutQuad } }
    Behavior on radius { NumberAnimation { duration: Constants.animation_duration/4; easing.type: Easing.OutCubic } }
}