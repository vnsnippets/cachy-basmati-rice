import QtQuick

QtObject {
    property ClickableStyle background: ClickableStyle {
        idle: Style.color_dark
        active: Style.color_dark
    }

    property ClickableStyle text: ClickableStyle {
        idle: Style.color_light
        active: Style.color_light
    }

    property ClickableStyle icon: ClickableStyle {
        idle: text.idle
        active: text.active
    }

    property ClickableStyle border: ClickableStyle {
        idle: Style.color_light
        active: Style.color_light
    }
}