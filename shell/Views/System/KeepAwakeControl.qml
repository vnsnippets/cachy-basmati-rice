import QtQuick

import Quickshell.Wayland

import qs
import qs.Components

ClickableWithIcon {
    required property IdleInhibitor inhibitor
    active: inhibitor.enabled

    id: keepawake
    size: Constants.icon_size
    padding: Constants.padding
    radius: (inhibitor.enabled) ? Constants.icon_size : Constants.radius

    iconname: "toggle.svg"

    styles.background_color_idle: Constants.keep_awake_control_color_background
    styles.background_color_active: Constants.keep_awake_control_color_background_active
    styles.icon_color_idle: Constants.keep_awake_control_color_text
    styles.icon_color_active: Constants.keep_awake_control_color_text_active

    styles.border_width: 1
    styles.border_color_idle: Constants.keep_awake_color_border
    styles.border_color_active: Constants.keep_awake_control_color_background_active

    onClicked: inhibitor.enabled = !inhibitor.enabled

    // Rotate the whole component
    rotation: inhibitor.enabled ? 270 : 0
    transformOrigin: Item.Center

    Behavior on rotation { NumberAnimation { duration: Constants.animation_duration; easing.type: Easing.InOutQuad } }
    Behavior on radius { NumberAnimation { duration: Constants.animation_duration/4; easing.type: Easing.OutCubic } }
}