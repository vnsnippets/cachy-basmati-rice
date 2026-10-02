pragma ComponentBehavior: Bound

import qs
import qs.Components

ClickableWithIcon {    
    size: Constants.icon_size 
    padding: Constants.padding
    radius: Constants.radius

    iconname: "power.svg"
    
    styles.background_color_idle: Constants.power_control_color_background
    styles.background_color_active: Constants.power_control_color_background_active
    styles.icon_color_idle: Constants.power_control_color_text
    styles.icon_color_active: Constants.power_control_color_text_active
}