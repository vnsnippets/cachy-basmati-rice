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
    readonly property Component default_content: Launchpad {
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
                active: root.active_content === component_bluetooth_devices
                onClicked: root.active_content = (active) ? root.default_content : component_bluetooth_devices
                Component { id: component_bluetooth_devices; BluetoothDevices { } }
            }

            NetworkControl {
                Layout.maximumWidth: Constants.network_control_max_width
                active: root.active_content === component_network_devices
                onClicked: root.active_content = (active) ? root.default_content : component_network_devices
                Component { id: component_network_devices; NetworkDevices { } }
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

            MuteControl {}

            Clickable {
                id: volume_wrapper
                Layout.fillWidth: true
                implicitHeight: volume_control.implicitHeight

                readonly property bool active: root.active_content === audio_devices

                VolumeControl {
                    id: volume_control
                    radius: Constants.radius

                    readonly property bool hovered: volume_wrapper.containsMouse

                    styles.background_color: Constants.control_color_background_default
                    styles.border_color: (hovered || volume_wrapper.active) ? 
                        Qt.alpha(Constants.volume_control_color_ink_default, 0.20) : 
                            Constants.control_color_border_default

                    styles.track_color: Constants.volume_control_color_track
                    styles.accent_color: Constants.volume_control_color_ink_active

                    border.width: 1

                    Behavior on styles.border_color { ColorAnimation { duration: Constants.animation_duration }}
                }

                onClicked: root.active_content = (active) ? root.default_content : audio_devices
                Component { id: audio_devices; AudioDevices { } }
            }

            BrightnessControl {
                Layout.fillWidth: true
                radius: Constants.radius

                styles.background_color: Constants.control_color_background_default
                styles.border_color: Constants.control_color_border_default

                styles.track_color: Constants.display_control_color_track
                styles.accent_color: Constants.display_control_color_ink_active

                border.width: 1
            }

            KeepAwakeControl {
                inhibitor: IdleInhibitor { id: component_idle_inhibitor }
            }
        }

        // --- Main Container ---
        ContentContainer {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            Layout.margins: root._padding
            Layout.topMargin: 0
            
            content: root.active_content
        }
    }
}