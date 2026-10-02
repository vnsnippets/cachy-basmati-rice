pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell.Wayland

import qs
import qs.Components
import qs.Layouts
import qs.Views.Power
import qs.Views.Audio
import qs.Views.System
import qs.Views.Display
import qs.Views.Network
import qs.Views.Battery
import qs.Views.Bluetooth
import qs.Views.Applications

StyledBox {
    id: root
    readonly property int _gap: Constants.spacing / 1.5
    readonly property int _padding: Constants.padding * 3
    readonly property Component default_content: ApplicationSpotlight {
        page_size: 8
    }
    property Component active_content: default_content

    colors.background: Constants.console_color_background
    colors.border: Constants.console_color_border

    radius: Constants.radius * 2
    
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Constants.animation_duration
            easing.type: Easing.OutCubic
        }
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        spacing: root._gap * 2
        visible: root.opacity > 0.1
        
        // --- Header Row ---
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: root._padding
            Layout.leftMargin: root._padding
            Layout.rightMargin: root._padding
            spacing: root._gap

            ClockControl { Layout.alignment: Qt.AlignTop; }

            Item { Layout.fillWidth: true; }

            BluetoothControl {
                Layout.maximumWidth: Constants.bluetooth_control_max_width
            }

            NetworkControl {
                Layout.maximumWidth: Constants.network_control_max_width
            }

            BatteryControl {
                active: root.active_content === component_battery_profiles
                onClicked: root.active_content = (active) ? root.default_content : component_battery_profiles
                Component { id: component_battery_profiles; BatteryProfiles { max_height: 160 } }
            }

            PowerControl {
                active: root.active_content === component_power_menu
                onClicked: root.active_content = (active) ? root.default_content : component_power_menu
                Component { id: component_power_menu; PowerOptions { max_height: 160; } }
            }
        }

        // --- Widgets Row ---
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: root._padding
            Layout.rightMargin: root._padding
            spacing: root._gap

            AudioVolumeControl {
                Layout.fillWidth: true
                radius: Constants.radius

                styles.background_color: Constants.audio_control_color_background
                styles.track_color: Constants.audio_control_color_track
                styles.accent_color: Constants.default_color_accent

                border.width: 1
                styles.border_color: Constants.audio_control_color_border
            }

            BrightnessControl {
                Layout.fillWidth: true
                radius: Constants.radius

                styles.background_color: Constants.display_control_color_background
                styles.track_color: Constants.display_control_color_track
                styles.accent_color: Constants.default_color_accent

                border.width: 1
                styles.border_color: Constants.display_control_color_border
            }

            KeepAwakeControl {
                inhibitor: IdleInhibitor { id: component_idle_inhibitor }
            }
        }

        // --- Main Container ---
        ContentContainer {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            Layout.leftMargin: root._padding
            Layout.rightMargin: root._padding
            Layout.bottomMargin: root._padding
            Layout.topMargin: root._padding / 2
            content: root.active_content
        }
    }
}