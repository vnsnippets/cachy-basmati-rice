pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string namespace: "basmati-shell"

    readonly property SystemClock clock: SystemClock {
        precision: SystemClock.Minutes
    }

    readonly property int font_size: 14
    readonly property string font_family: "Noto Sans"

    readonly property color color_transparent: "transparent"

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
    // readonly property color color_subtext1: "#bac2de"
    // readonly property color color_subtext0: "#a6adc8"
    readonly property color color_subtext: "#9399b2"
    // readonly property color color_overlay2: "#9399b2"
    // readonly property color color_overlay1: "#7f849c"
    readonly property color color_overlay: "#6c7086"
    // readonly property color color_surface2: "#585b70"
    // readonly property color color_surface1: "#45475a"
    readonly property color color_surface: "#313244"
    readonly property color color_base: "#1e1e2e"
    readonly property color color_mantle: "#181825"
    readonly property color color_crust: "#11111b"

    readonly property color color_accent: color_yellow

    readonly property real roundness: 0.5
    readonly property int radius: roundness * 24
    readonly property int padding: 10

    readonly property int spacing: 8
    readonly property int gap: 8
 
    // Default size
    // Height in most cases, but also used for width
    // in Clickable Icon Buttons
    readonly property int size: 40
    readonly property int icon_size: 20
    readonly property int animation_duration: 250

    // On Screen Displays    
    readonly property int osd_width: 320
    readonly property int osd_timeout: 2000
    readonly property int osd_offset: 48
    readonly property int osd_icon_size: 20
    readonly property color osd_color_background: color_mantle
    readonly property color osd_color_border: color_surface

    // Notifications
    readonly property int notification_width: 320
    readonly property int notification_offset: 16
    readonly property int notification_timeout: 15000
    readonly property color notification_color_background: color_mantle
    readonly property color notification_color_border: color_surface
    readonly property color notification_color_border_active: color_overlay
    readonly property color notification_color_text: color_text
    readonly property color notification_color_subtext: color_subtext
    readonly property color notification_color_ticker_background: color_mantle
    readonly property color notification_color_ticker_foreground: color_surface

    //  Center Console
    readonly property int console_width: 720
    readonly property color console_color_backdrop: color_crust
    readonly property color console_color_background: color_crust
    readonly property color console_color_border: color_surface

    // Applications
    readonly property string spotlight_search_text: "Search..."
    readonly property string spotlight_search_icon: "search.svg"
    readonly property color spotlight_search_color_background: color_surface
    readonly property color spotlight_search_color_border: color_overlay
    readonly property color spotlight_search_color_active: color_accent
    readonly property color spotlight_search_color_text: color_text

    readonly property color spotlight_app_color_background: color_transparent
    readonly property color spotlight_app_color_text: color_subtext
    readonly property color spotlight_app_color_border_active: color_surface
    readonly property color spotlight_app_color_background_active: color_base
    readonly property color spotlight_app_color_text_active: color_text

    // System : Clock
    readonly property color clock_color_text: color_text
    readonly property color clock_color_subtext: color_overlay

    // System : Battery
    readonly property real battery_threshold_warning: 0.40
    readonly property real battery_threshold_critical: 0.20
    readonly property color battery_color_background: color_base
    readonly property color battery_color_text_active: color_base
    readonly property color battery_color_default: color_text
    readonly property color battery_color_warning: color_yellow
    readonly property color battery_color_critical: color_red
    readonly property color battery_color_charging: color_yellow


    // Network
    readonly property real network_threshold_warning: 0.50
    readonly property real network_threshold_critical: 0.25
    readonly property real network_pill_max_width: 160
    readonly property color network_color_background: color_base
    readonly property color network_color_text_active: color_base
    readonly property color network_color_default: color_green
    readonly property color network_color_warning: color_yellow
    readonly property color network_color_critical: color_red

    // Bluetooth
    readonly property real bluetooth_pill_max_width: 160
    readonly property color bluetooth_color_background: color_base
    readonly property color bluetooth_color_text_active: color_base
    readonly property color bluetooth_color_enabled: color_sapphire
    readonly property color bluetooth_color_disabled: color_overlay
    readonly property color bluetooth_color_blocked: color_red
    readonly property color bluetooth_color_busy: color_yellow
    readonly property color bluetooth_color_default: color_text

}