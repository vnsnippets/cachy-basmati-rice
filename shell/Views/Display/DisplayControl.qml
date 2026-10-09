pragma ComponentBehavior: Bound

import QtQuick

import qs
import qs.Components

ClickableWithIcon {
    size: Constants.icon_size
    padding: Constants.padding
    radius: Constants.icon_size

    iconname: "desktop.svg"

    styles.background_color_idle: Constants.control_color_background_default
    styles.background_color_active: Constants.display_control_color_active

    styles.border_width: 1
    styles.border_color_idle: Constants.control_color_border_default
    styles.border_color_active: Constants.display_control_color_active

    styles.icon_color_idle: Constants.display_control_color_ink_default
    styles.icon_color_active: Constants.display_control_color_ink_active
}