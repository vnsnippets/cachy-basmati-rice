pragma ComponentBehavior: Bound

import QtQuick

import qs
import qs.Components

ClickableWithIcon {    
    size: Constants.icon_size 
    padding: Constants.padding
    radius: (active) ? Constants.icon_size : Constants.radius

    iconname: "power.svg"
    
    styles.background_color_idle: Constants.control_color_background_default
    styles.background_color_active: Constants.power_color_active
    styles.icon_color_idle: Constants.power_color_active
    styles.icon_color_active: Constants.power_color_ink_active

    styles.border_width: 1
    styles.border_color_idle: Constants.control_color_border_default
    styles.border_color_active: Constants.power_color_active

    Behavior on radius { NumberAnimation { duration: Constants.animation_duration/4; easing.type: Easing.OutCubic } }
}