pragma Singleton

import QtQuick

QtObject {
    readonly property color color_background_idle: "#232634"
    readonly property color color_background_hover: '#151721'
    readonly property color color_background_active: "#151721"

    readonly property color color_foreground_idle: "#C6D0F5"
    readonly property color color_foreground_hover: '#DDE4FB'
    readonly property color color_foreground_active: "#DDE4FB"

    readonly property color color_border_idle: "#394250"
    readonly property color color_border_hover: '#627386'
    readonly property color color_border_active: "#627386"

    readonly property int font_size: 14
    readonly property string font_family: "Noto Sans Nerd Font"

    readonly property color color_dark: "#232634"
    readonly property color color_light: "#c6d0f5"
    readonly property color color_blue: "#3498db"
    readonly property color gcolor_reen: "#a6d189"
    readonly property color color_yellow: "#f1c40f"
    readonly property color color_red: "#e78284"
}