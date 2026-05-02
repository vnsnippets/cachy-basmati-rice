pragma Singleton

import QtQuick

Item {
    readonly property color color_dark: "#EA181825"
    readonly property color color_slate: "#313244"
    readonly property color color_muted: "#B1B2C4"
    readonly property color color_light: "#cdd6f4"
    
    readonly property color color_blue: "#89b4fa"
    readonly property color color_teal: "#94e2d5"
    readonly property color color_green: "#a6e3a1"
    readonly property color color_yellow: "#f9e2af"
    readonly property color color_red: "#f38ba8"

    readonly property int border_width: 1
    readonly property int border_radius: 12

    readonly property QtObject dock: QtObject {
        readonly property int spacing: 4
        readonly property int margin: 10
        readonly property int height: 40
    }

    readonly property QtObject widgets: QtObject {
        readonly property int width: 40
        readonly property int height: 40
        readonly property int spacing: 4
        readonly property int padding: 24
    }

    readonly property QtObject popup: QtObject {
        readonly property real border_radius: 12
        readonly property real spacing: 20
        readonly property color background: color_dark
        readonly property QtObject button: QtObject {
            readonly property QtObject background: QtObject {
                readonly property color idle: color_slate
                readonly property color active: color_dark
            }
        }
        readonly property QtObject animations: QtObject {
            readonly property int duration: 300
        }
    }

    readonly property QtObject animations: QtObject {
        readonly property int duration: 250
    }

    readonly property QtObject fonts: QtObject {
        readonly property int size: 14
        readonly property string family: "Noto Sans"
        readonly property string icon: "Symbols Nerd Font"
    }
}