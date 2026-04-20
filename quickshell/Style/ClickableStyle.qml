import QtQuick

import qs

QtObject {
    property ClickableColorStyle background: ClickableColorStyle {
        idle: Theme.color_dark
        active: Theme.color_dark
    }

    property ClickableColorStyle foreground: ClickableColorStyle {
        idle: Theme.color_light
        active: Theme.color_light
    }

    property ClickableColorStyle border: ClickableColorStyle {
        idle: Theme.color_slate
        active: Theme.color_light
    }
}