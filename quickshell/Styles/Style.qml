pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

import qs.Types

Singleton {
    FontLoader {
        id: _UbuntuSansMonoFluent
        source: "../Assets/UbuntuSansMonoFluent-Regular.ttf"
    }

    readonly property QtObject colors: QtObject {
        readonly property color rosewater: "#f5e0dc"
        readonly property color flamingo: "#f2cdcd"
        readonly property color pink: "#f5c2e7"
        readonly property color mauve: "#cba6f7"
        readonly property color red: "#f38ba8"
        readonly property color maroon: "#eba0ac"
        readonly property color peach: "#fab387"
        readonly property color yellow: "#f9e2af"
        readonly property color green: "#a6e3a1"
        readonly property color teal: "#94e2d5"
        readonly property color sky: "#89dceb"
        readonly property color sapphire: "#74c7ec"
        readonly property color blue: "#89b4fa"
        readonly property color lavender: "#b4befe"

        readonly property color text: "#cdd6f4"
        // readonly property color subtext1: "#bac2de"
        readonly property color subtext: "#a6adc8"
        // readonly property color overlay2: "#9399b2"
        // readonly property color overlay1: "#7f849c"
        readonly property color overlay: "#6c7086"
        // readonly property color surface2: "#585b70"
        // readonly property color surface1: "#45475a"
        readonly property color surface: "#313244"
        readonly property color base: "#1e1e2e"
        readonly property color mantle: "#181825"
        readonly property color crust: "#11111b"

        readonly property color slate: "#232634"
        // readonly property color wayborder: "#394250"
        readonly property color wayborder: "#737994"
    }

    readonly property int spacing: 4
    readonly property int margin: 8
    readonly property int borderWidth: 1

    readonly property QtObject clickable: QtObject {
        readonly property QtObject background: QtObject {
            readonly property color idle: Style.colors.base
            readonly property color active: Style.colors.base
        }
        readonly property QtObject border: QtObject {
            readonly property color idle: Style.colors.subtext
            readonly property color active: Style.colors.text
        }
        readonly property QtObject text: QtObject {
            readonly property color idle: Style.colors.green
            readonly property color active: Style.colors.text
        }

        readonly property size dimensions: Qt.size(40, 40)
        readonly property int radius: 8
        readonly property int padding: 12
        readonly property int spacing: 4
    }

    readonly property QtObject panel: QtObject {
        readonly property int radius: 12
        readonly property int padding: 12
        readonly property int width: 1920/3

        readonly property QtObject colors: QtObject {
            readonly property color background: Style.colors.base
            readonly property color border: Style.colors.wayborder
        }

        readonly property QtObject widget: QtObject {
            readonly property int height: 68
            readonly property color background: Qt.alpha(Style.colors.surface, 1)
        }
    }

    readonly property QtObject animations: QtObject {
        readonly property int duration: 250
    }

    readonly property QtObject fonts: QtObject {
        readonly property int size: 16
        readonly property string family: "Noto Sans"
        readonly property string icon: _UbuntuSansMonoFluent.name
    }

    readonly property QtObject icons: QtObject {
        readonly property QtObject network: QtObject {
            readonly property string wifi: ""
            readonly property string offline: ""
        }
        readonly property QtObject battery: QtObject {
            readonly property string plugged: ""
            readonly property string unplugged: ""
        }
    }
}