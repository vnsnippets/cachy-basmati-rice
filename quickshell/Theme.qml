pragma Singleton

import QtQuick

QtObject {
    readonly property QtObject background: QtObject {
        readonly property color idle: "#232634"
        readonly property color hover: '#151721'
        readonly property color active: "#151721"
    }

    readonly property QtObject foreground: QtObject {
        readonly property color idle: "#c6d0f5"
        readonly property color hover: '#dde4fb'
        readonly property color active: "#dde4fb"
    }

    readonly property QtObject border: QtObject {
        readonly property color idle: "#405060"
        readonly property color hover: '#556a80'
        readonly property color active: "#556a80"
    }


    readonly property QtObject fonts: QtObject {
        readonly property int size: 14
        readonly property string family: "Noto Sans Nerd Font"
    }


    readonly property color light: "#c6d0f5"
    readonly property color blue: "#3498db"
    readonly property color green: "#a6d189"
    readonly property color yellow: "#f1c40f"
    readonly property color red: "#e78284"


    readonly property string fontfamily: "Noto Sans Nerd Font"
    readonly property int fontsize: 14
}