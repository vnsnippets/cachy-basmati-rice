import QtQuick

import qs

QtObject {
    property ClickableColorStyle background: ClickableColorStyle {
        idle: Theme.color_background_idle
        hover: Theme.color_background_hover
        active: Theme.color_background_active
    }

    property ClickableColorStyle foreground: ClickableColorStyle {
        idle: Theme.color_foreground_idle
        hover: Theme.color_foreground_hover
        active: Theme.color_foreground_active
    }

    property ClickableColorStyle border: ClickableColorStyle {
        idle: Theme.color_border_idle
        hover: Theme.color_border_hover
        active: Theme.color_border_active
    }
}