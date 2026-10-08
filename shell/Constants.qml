pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property SystemClock clock:                            SystemClock { precision: SystemClock.Minutes }

    readonly property string namespace:                             "shell.basmati.rice"
    readonly property string icons_directory:                       "./Assets"

    readonly property int    font_size:                             14
    readonly property int    font_size_lg:                          font_size + 2
    readonly property int    font_size_sm:                          font_size - 2
    readonly property real   font_spacing:                          0
    readonly property string font_family:                           "Noto Sans"

    readonly property color  color_transparent:                     "transparent"
    readonly property color  color_light:                           "#dce0e8"
    readonly property color  color_dark:                            "#11111b"

    // Catppuccin Mocha Base Palette
    readonly property color  color_rosewater:                       "#f5e0dc"
    readonly property color  color_flamingo:                        "#f2cdcd"
    readonly property color  color_pink:                            "#f5c2e7"
    readonly property color  color_mauve:                           "#cba6f7"
    readonly property color  color_red:                             "#f38ba8"
    readonly property color  color_maroon:                          "#eba0ac"
    readonly property color  color_peach:                           "#fab387"
    readonly property color  color_yellow:                          "#f9e2af"
    readonly property color  color_green:                           "#a6e3a1"
    readonly property color  color_teal:                            "#94e2d5"
    readonly property color  color_sky:                             "#89dceb"
    readonly property color  color_sapphire:                        "#74c7ec"
    readonly property color  color_blue:                            "#89b4fa"
    readonly property color  color_lavender:                        "#b4befe"

    readonly property color  color_text:                            "#cdd6f4"
    readonly property color  color_subtext:                         "#9399b2"
    readonly property color  color_overlay:                         "#6c7086"
    readonly property color  color_surface:                         "#313244"
    readonly property color  color_base:                            "#1e1e2e"
    readonly property color  color_mantle:                          "#181825"
    readonly property color  color_crust:                           "#11111b"

    // Catppuccin Latte Palette (Light Theme)
    // readonly property color  color_rosewater:                    "#dc8a78"
    // readonly property color  color_flamingo:                     "#dd7878"
    // readonly property color  color_pink:                         "#ea76cb"
    // readonly property color  color_mauve:                        "#8839ef"
    // readonly property color  color_red:                          "#d20f39"
    // readonly property color  color_maroon:                       "#e64553"
    // readonly property color  color_peach:                        "#fe640b"
    // readonly property color  color_yellow:                       "#df8e1d"
    // readonly property color  color_green:                        "#40a02b"
    // readonly property color  color_teal:                         "#179299"
    // readonly property color  color_sky:                          "#04a5e5"
    // readonly property color  color_sapphire:                     "#209fb5"
    // readonly property color  color_blue:                         "#1e66f5"
    // readonly property color  color_lavender:                     "#7287fd"

    // readonly property color  color_text:                         "#4c4f69"
    // readonly property color  color_subtext:                      "#6c6f85"
    // readonly property color  color_overlay:                      "#9ca0b0"
    // readonly property color  color_surface:                      "#ccd0da"
    // readonly property color  color_base:                         "#eff1f5"
    // readonly property color  color_mantle:                       "#e6e9ef"
    // readonly property color  color_crust:                        "#dce0e8"

    readonly property int    size:                                  40
    readonly property int    icon_size:                             20
    readonly property int    padding:                               10
    readonly property int    spacing:                               8
    readonly property int    gap:                                   8

    readonly property real   roundness:                             0.25
    readonly property int    radius:                                roundness * 24

    readonly property int    animation_duration:                    250

    readonly property color  default_background:                    color_base
    readonly property color  default_color_accent:                  color_yellow

    // On Screen Displays    
    readonly property int    toast_width:                           320
    readonly property int    toast_timeout:                         2000
    readonly property int    toast_offset:                          48
    readonly property int    toast_icon_size:                       20

    readonly property color  toast_color_background:                default_background
    readonly property color  toast_color_border:                    color_surface
    readonly property color  toast_color_ink_active:                color_yellow

    // Console Base Window
    readonly property int    console_width:                         720
    readonly property bool   console_disable_navigation:            false
    readonly property bool   console_backdrop_enabled:              true
    
    readonly property color  console_color_background:              color_mantle
    readonly property color  console_color_border:                  Qt.alpha(color_surface, 0.50)

    readonly property color  console_color_backdrop_active:         Qt.alpha(color_dark, 0.6)
    readonly property color  console_color_backdrop_inactive:       Qt.alpha(color_dark, 0)

    // Controls Generic Color Map
    readonly property color  control_color_background_default:      default_background
    readonly property color  control_color_border_default:          Qt.alpha(color_surface, 0.50)
    
    readonly property color  control_color_ink_default:             color_text
    readonly property color  control_color_ink_muted:               color_subtext
    readonly property color  control_color_ink_active:              color_yellow

    // Tab Container
    readonly property color  tab_color_ink_active:                  color_text
    readonly property color  tab_color_ink_inactive:                color_overlay
    readonly property color  tab_color_ink_muted:                   color_subtext

    // Clock Control
    readonly property color  clock_color_text:                      color_text
    readonly property color  clock_color_subtext:                   color_subtext

    // Notifications
    readonly property int    notification_width:                    320
    readonly property int    notification_offset:                   16
    readonly property int    notification_timeout:                  15000

    readonly property color  notification_color_background:         color_mantle
    readonly property color  notification_color_border:             color_overlay

    readonly property color  notification_color_ink_default:        color_text
    readonly property color  notification_color_ink_critical:       color_red
    readonly property color  notification_color_ink_muted:          color_subtext

    // System : Battery
    readonly property real   battery_threshold_warning:             0.40
    readonly property real   battery_threshold_critical:            0.20

    readonly property color  battery_color_warning:                 color_yellow
    readonly property color  battery_color_critical:                color_red
    readonly property color  battery_color_charging:                color_peach

    readonly property color  battery_color_border:                  Qt.alpha(Constants.color_surface, 0.75)
    readonly property color  battery_color_background:              Qt.alpha(Constants.color_surface, 0.25)
    
    readonly property color  battery_color_ink_default:             color_text
    readonly property color  battery_color_ink_active:              color_base
    readonly property color  battery_color_ink_muted:               color_text

    readonly property color  battery_color_powersaver:              color_green
    readonly property color  battery_color_balanced:                color_blue
    readonly property color  battery_color_performance:             color_red

    // System : Power Button

    readonly property color  power_color_shutdown:                  color_red
    readonly property color  power_color_reboot:                    color_peach
    readonly property color  power_color_suspend:                   color_mauve
    readonly property color  power_color_logout:                    color_sapphire

    readonly property color  power_color_background:                Qt.alpha(Constants.color_surface, 0.25)
    readonly property color  power_color_border:                    Qt.alpha(Constants.color_surface, 0.75)

    readonly property color  power_color_active:                    color_red

    readonly property color  power_color_ink_default:               color_text
    readonly property color  power_color_ink_active:                color_base
    readonly property color  power_color_ink_muted:                 color_subtext

    readonly property bool   power_show_description:                false

    // System : Keep Awake Control
    readonly property color  keepawake_color_active:                color_peach
    readonly property color  keepawake_color_ink_default:           color_text
    readonly property color  keepawake_color_ink_active:            color_base

    // Widgets : Audio
    readonly property color  volume_control_color_track:            color_surface
    readonly property color  volume_control_color_ink_default:      color_text
    readonly property color  volume_control_color_ink_active:       color_yellow
    readonly property color  volume_control_color_ink_muted:        color_subtext

    // Widgets: Brightness
    readonly property color  display_control_color_track:           color_surface
    readonly property color  display_control_color_ink_default:     color_text
    readonly property color  display_control_color_ink_active:      color_yellow
    readonly property color  display_control_color_ink_muted:       color_overlay

    // Network
    readonly property bool   network_hide_ssid:                     false
    readonly property real   network_threshold_warning:             0.50
    readonly property real   network_threshold_critical:            0.25

    readonly property real   network_control_max_width:             160

    readonly property color  network_color_background:              color_transparent
    readonly property color  network_color_border:                  color_surface

    readonly property color  network_color_ink_default:             color_text
    readonly property color  network_color_ink_active:              color_base
    readonly property color  network_color_ink_muted:               color_subtext

    readonly property color  network_color_active:                  color_green
    readonly property color  network_color_inactive:                color_surface
    readonly property color  network_color_warning:                 color_yellow
    readonly property color  network_color_critical:                color_red
    readonly property color  network_color_busy:                    color_yellow

    // Bluetooth
    readonly property real   bluetooth_control_max_width:           160

    readonly property color  bluetooth_color_background:            color_transparent
    readonly property color  bluetooth_color_border:                color_surface

    readonly property color  bluetooth_color_ink_default:           color_text
    readonly property color  bluetooth_color_ink_muted:             color_subtext
    readonly property color  bluetooth_color_ink_active:            color_base
    
    readonly property color  bluetooth_color_active:                color_sapphire
    readonly property color  bluetooth_color_inactive:              color_surface
    readonly property color  bluetooth_color_critical:              color_red
    readonly property color  bluetooth_color_busy:                  color_yellow

    // Application Launchpad / Spotlight
    readonly property string spotlight_search_placeholder:          "Search..."
    readonly property bool   spotlight_show_appid:                  true

    readonly property int    spotlight_item_height:                 40 + padding

    readonly property color  spotlight_color_border:                color_subtext
    readonly property color  spotlight_color_ink_active:            color_text
    readonly property color  spotlight_color_ink_muted:             color_subtext

    readonly property color  spotlight_color_background_default:    Qt.alpha(color_base, 0.10)
    readonly property color  spotlight_color_background_active:     Qt.alpha(color_base, 0.25)
}