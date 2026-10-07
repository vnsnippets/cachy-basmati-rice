pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string namespace: "shell.basmati.rice"

    readonly property SystemClock clock: SystemClock {
        precision: SystemClock.Minutes
    }

    // FontLoader {
    //     id: custom_font
    //     source: "./Assets/Fonts/Lato-Regular.ttf"
    // }

    readonly property string icons_directory: "./Assets"

    readonly property int    font_size: 14
    readonly property int    font_size_lg: font_size + 2
    readonly property int    font_size_sm: font_size - 2
    readonly property real   font_spacing: 0
    readonly property string font_family: "Noto Sans"
    // readonly property string font_family: custom_font.name

    readonly property color  color_transparent: "transparent"

    readonly property color  color_rosewater: "#f5e0dc"
    readonly property color  color_flamingo: "#f2cdcd"
    readonly property color  color_pink: "#f5c2e7"
    readonly property color  color_mauve: "#cba6f7"
    readonly property color  color_red: "#f38ba8"
    readonly property color  color_maroon: "#eba0ac"
    readonly property color  color_peach: "#fab387"
    readonly property color  color_yellow: "#f9e2af"
    readonly property color  color_green: "#a6e3a1"
    readonly property color  color_teal: "#94e2d5"
    readonly property color  color_sky: "#89dceb"
    readonly property color  color_sapphire: "#74c7ec"
    readonly property color  color_blue: "#89b4fa"
    readonly property color  color_lavender: "#b4befe"

    readonly property color  color_text: "#cdd6f4"
    // readonly property color color_subtext1: "#bac2de"
    // readonly property color color_subtext0: "#a6adc8"
    readonly property color  color_subtext: "#9399b2"
    // readonly property color color_overlay2: "#9399b2"
    // readonly property color color_overlay1: "#7f849c"
    readonly property color  color_overlay: "#6c7086"
    // readonly property color color_surface2: "#585b70"
    // readonly property color color_surface1: "#45475a"
    readonly property color  color_surface: "#313244"
    readonly property color  color_base: "#1e1e2e"
    readonly property color  color_mantle: "#181825"
    readonly property color  color_crust: "#11111b"

    readonly property color  default_color_accent: color_yellow
    readonly property color  default_background: color_base
    readonly property color  default_border: Qt.alpha(color_surface, 0.50)

    readonly property real   roundness: 0.25
    readonly property int    radius: roundness * 24
    readonly property int    padding: 10

    readonly property int    spacing: 8
    readonly property int    gap: 8
 
    readonly property int    size: 40
    readonly property int    icon_size: 20
    readonly property int    animation_duration: 250

    // On Screen Displays    
    readonly property int    osd_width: 320
    readonly property int    osd_timeout: 2000
    readonly property int    osd_offset: 48
    readonly property int    osd_icon_size: 20
    readonly property color  osd_color_background: default_background
    readonly property color  osd_color_border: color_surface

    // Notifications
    readonly property int    notification_width: 320
    readonly property int    notification_offset: 16
    readonly property int    notification_timeout: 15000
    readonly property color  notification_color_background: default_background
    readonly property color  notification_color_border: default_border
    readonly property color  notification_color_border_active: color_overlay
    readonly property color  notification_color_text: color_text
    readonly property color  notification_color_subtext: color_subtext
    readonly property color  notification_color_ticker_background: default_background
    readonly property color  notification_color_ticker_foreground: color_surface
    readonly property color  notification_color_dismiss: color_red

    //  Center Console
    readonly property int    console_width: 720
    readonly property color  console_color_backdrop_active: Qt.alpha(color_crust, 0.6)
    readonly property color  console_color_backdrop_inactive: Qt.alpha(color_crust, 0)
    readonly property color  console_color_background: color_mantle
    readonly property color  console_color_border: default_border
    readonly property bool   console_backdrop_enabled: true

    readonly property color  console_tab_color_text_inactive: color_overlay
    readonly property color  console_tab_color_text_active: color_text

    // System : Clock
    readonly property color  clock_color_text: color_text
    readonly property color  clock_color_subtext: color_subtext

    // System : Battery
    readonly property real   battery_threshold_warning: 0.40
    readonly property real   battery_threshold_critical: 0.20

    readonly property color  battery_control_color_background: default_background
    readonly property color  battery_control_color_border: default_border
    readonly property color  battery_control_color_text_active: color_base
    readonly property color  battery_control_color_default: color_text
    readonly property color  battery_control_color_warning: color_yellow
    readonly property color  battery_control_color_critical: color_red
    readonly property color  battery_control_color_charging: color_yellow

    readonly property color  battery_profile_color_border: Qt.alpha(Constants.color_surface, 0.60)
    readonly property color  battery_profile_color_background: Qt.alpha(Constants.color_surface, 0.25)
    readonly property color  battery_profile_color_background_active: Qt.alpha(Constants.color_surface, 0.50)
    readonly property color  battery_profile_color_text: color_subtext
    readonly property color  battery_profile_color_subtext: color_overlay
    readonly property color  battery_profile_color_subtext_active: color_text
    readonly property color  battery_profile_color_powersaver: color_green
    readonly property color  battery_profile_color_balanced: color_blue
    readonly property color  battery_profile_color_performance: color_red

    // System : Power Button
    readonly property color  power_control_color_background: default_background
    readonly property color  power_control_color_border: default_border
    readonly property color  power_control_color_text: color_red
    readonly property color  power_control_color_background_active: color_red
    readonly property color  power_control_color_text_active: color_base

    readonly property color  power_option_color_shutdown: color_red
    readonly property color  power_option_color_reboot: color_peach
    readonly property color  power_option_color_suspend: color_mauve
    readonly property color  power_option_color_logout: color_sapphire
    readonly property color  power_option_color_background: Qt.alpha(Constants.color_surface, 0.25)
    readonly property color  power_option_color_background_active: Qt.alpha(Constants.color_surface, 0.50)
    readonly property color  power_option_color_border: Qt.alpha(Constants.color_surface, 0.60)
    readonly property color  power_option_color_text: color_subtext
    readonly property color  power_option_color_subtext: color_overlay
    readonly property color  power_option_color_subtext_active: color_text
    readonly property bool   power_option_show_description: false

    // System : Keep Awake Control
    readonly property color  keep_awake_control_color_background: default_background
    readonly property color  keep_awake_color_border: default_border
    readonly property color  keep_awake_control_color_background_active: color_peach
    readonly property color  keep_awake_control_color_text: color_text
    readonly property color  keep_awake_control_color_text_active: color_base

    // Widgets : Audio
    readonly property color  audio_control_color_background: default_background
    readonly property color  audio_control_color_border: default_border
    readonly property color  audio_control_color_track: color_surface
    readonly property color  audio_control_color_text: color_text
    readonly property color  audio_control_color_icon: color_text
    readonly property color  audio_control_color_icon_active: default_color_accent

    // Widgets: Brightness
    readonly property color  display_control_color_background: default_background
    readonly property color  display_control_color_border: default_border
    readonly property color  display_control_color_track: color_surface
    readonly property color  display_control_color_text: color_text
    readonly property color  display_control_color_icon: color_text
    readonly property color  display_control_color_icon_muted: color_overlay
    readonly property color  display_control_color_icon_active: default_color_accent

    // Network
    readonly property real   network_threshold_warning: 0.50
    readonly property real   network_threshold_critical: 0.25

    readonly property real   network_control_max_width: 160
    readonly property color  network_control_color_background: default_background
    readonly property color  network_control_color_border: default_border
    readonly property color  network_control_color_text_active: color_base

    readonly property color  network_color_default: color_green
    readonly property color  network_color_warning: color_yellow
    readonly property color  network_color_critical: color_red

    readonly property color  network_device_color_text: color_text
    readonly property color  network_device_color_subtext: color_subtext
    readonly property color  network_device_color_background: Qt.alpha(Constants.color_surface, 0.2)
    readonly property color  network_device_color_border: Qt.alpha(Constants.color_surface, 0.75)
    readonly property color  network_device_color_connected: color_green
    readonly property color  network_device_color_disconnected: color_surface


    readonly property color  network_device_color_action_connect: color_green
    readonly property color  network_device_color_action_disconnect: color_red
    readonly property color  network_device_color_action_busy: color_peach
    readonly property color  network_device_color_action_text_active: color_base

    readonly property color  network_device_color_nonetwork_text: color_subtext
    readonly property color  network_device_color_nonetwork_background: color_surface

    // Bluetooth
    readonly property real   bluetooth_control_max_width: 160
    readonly property color  bluetooth_color_background: default_background
    readonly property color  bluetooth_color_border: default_border
    readonly property color  bluetooth_color_text_active: color_base
    readonly property color  bluetooth_color_enabled: color_sapphire
    readonly property color  bluetooth_color_disabled: color_overlay
    readonly property color  bluetooth_color_blocked: color_red
    readonly property color  bluetooth_color_busy: color_yellow
    readonly property color  bluetooth_color_default: color_text

    // Application Launchpad / Spotlight
    readonly property string spotlight_search_placeholder: "Search..."
    readonly property string spotlight_search_icon: "search.svg"
    readonly property int    spotlight_search_height: 40 + padding

    readonly property color  spotlight_search_color_background: Qt.alpha(color_base, 0.10)
    readonly property color  spotlight_search_color_background_active: Qt.alpha(color_base, 0.25)
    readonly property color  spotlight_search_color_border: Qt.alpha(color_subtext, 0.10)
    readonly property color  spotlight_search_color_border_active: Qt.alpha(color_subtext, 0.25)
    readonly property color  spotlight_search_color_icon: Qt.alpha(color_subtext, 0.40)
    readonly property color  spotlight_search_color_text: color_text

    readonly property int    spotlight_app_height: 40 + padding
    readonly property color  spotlight_app_background_color: Qt.alpha(Constants.color_surface, 0)
    readonly property color  spotlight_app_background_color_active: Qt.alpha(Constants.color_surface, 0.2)
    readonly property color  spotlight_app_border_color: Qt.alpha(Constants.color_surface, 0)
    readonly property color  spotlight_app_border_color_active: Qt.alpha(Constants.color_surface, 0.75)
    readonly property color  spotlight_app_color_text: color_subtext
    readonly property color  spotlight_app_color_text_active: color_text
    readonly property bool   spotlight_app_show_appid: true
}