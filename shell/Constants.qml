pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string namespace: "basmati-shell"

    readonly property int font_size: 14
    readonly property string font_family: "Noto Sans"

    readonly property color color_rosewater: "#f5e0dc"
    readonly property color color_flamingo: "#f2cdcd"
    readonly property color color_pink: "#f5c2e7"
    readonly property color color_mauve: "#cba6f7"
    readonly property color color_red: "#f38ba8"
    readonly property color color_maroon: "#eba0ac"
    readonly property color color_peach: "#fab387"
    readonly property color color_yellow: "#f9e2af"
    readonly property color color_green: "#a6e3a1"
    readonly property color color_teal: "#94e2d5"
    readonly property color color_sky: "#89dceb"
    readonly property color color_sapphire: "#74c7ec"
    readonly property color color_blue: "#89b4fa"
    readonly property color color_lavender: "#b4befe"
    
    readonly property color color_text: "#cdd6f4"
    readonly property color color_subtext: "#a6adc8"
    readonly property color color_accent: color_yellow
    readonly property color color_muted: "#6c7086"
    readonly property color color_overlay: "#313244"
    readonly property color color_surface: "#181825"
    readonly property color color_base: "#11111b"

    readonly property real roundness: 0.5
    readonly property int radius: roundness * 24
    readonly property int padding: 10

    readonly property int spacing: 8
    readonly property int gap: 8
 
    // Default size
    // Height in most cases, but also used for width
    // in Clickable Icon Buttons
    readonly property int size: 40
    readonly property int animation_duration: 250
    
    readonly property int osd_width: 320
    readonly property int osd_timeout: 2000
    readonly property int osd_offset_y: 48
}