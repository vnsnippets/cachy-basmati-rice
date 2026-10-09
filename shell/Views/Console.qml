pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell.Wayland

import qs
import qs.Layouts
import qs.Utilities
import qs.Components
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
    readonly property Component default_content: Launchpad { page_size: 8 }

    property Component content: navigation_stack[root.navigation_stack.length - 1] ?? default_content
    property list<Component> navigation_stack: [ default_content ]

    colors.background: Constants.console_color_background
    colors.border: Constants.console_color_border

    radius: Constants.radius * 2
    
    implicitWidth: content_layout.implicitWidth
    implicitHeight: content_layout.implicitHeight + (root._padding * 2)

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Constants.animation_duration
            easing.type: Easing.OutCubic
        }
    }

    function navigate(_content) {
        // Toggling back to default if re-selecting current content
        if (_content === root.content) {
            root.navigation_stack = [ root.default_content ];
            root.content = root.default_content;
            return;
        }

        if (Constants.console_disable_navigation) {
            root.navigation_stack = [ _content ];
            return;
        }

        // Filter out existing instances of _content to avoid duplicate entries
        const filteredStack = root.navigation_stack.filter(item => item !== _content);
        filteredStack.push(_content);

        // Reassign array to trigger QML property binding updates
        root.navigation_stack = filteredStack;
        root.content = _content;
    }

    ColumnLayout {
        id: content_layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        spacing: root._gap * 2
        visible: root.opacity > 0.1
        
        // --- Header Row ---
        RowLayout {
            Layout.fillWidth: true

            Layout.leftMargin: root._padding
            Layout.rightMargin: root._padding
            spacing: root._gap

            ClockControl { Layout.alignment: Qt.AlignTop; }

            Item { Layout.fillWidth: true; }

            BluetoothControl {
                Layout.maximumWidth: Constants.bluetooth_control_max_width
                active: root.content === bluetooth_devices
                onClicked: root.navigate(bluetooth_devices)
                Component { id: bluetooth_devices; BluetoothDevices { } }
            }

            NetworkControl {
                Layout.maximumWidth: Constants.network_control_max_width
                active: root.content === network_devices
                onClicked: root.navigate(network_devices)
                Component { id: network_devices; NetworkDevices { } }
            }

            BatteryControl {
                active: root.content === battery_profiles
                onClicked: root.navigate(battery_profiles)
                Component { id: battery_profiles; BatteryProfiles { max_height: 160 } }
            }

            PowerControl {
                active: root.content === power_options
                onClicked: root.navigate(power_options)
                Component { id: power_options; PowerOptions { max_height: 160; } }
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

                readonly property bool active: root.content === audio_devices

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

                onClicked: root.navigate(audio_devices)
                Component { id: audio_devices; AudioDevices { } }
            }

            BrightnessControl {
                Layout.fillWidth: true
                radius: Constants.radius

                styles.background_color: Constants.control_color_background_default
                styles.border_color: Constants.control_color_border_default

                styles.track_color: Constants.display_control_color_track
                styles.accent_color: Constants.display_control_color_active

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
            Layout.leftMargin: root._padding
            Layout.rightMargin: root._padding
            
            content: root.navigation_stack.length > 0 ? root.navigation_stack[root.navigation_stack.length - 1] : root.default_content
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: root._padding
            Layout.rightMargin: root._padding
            Layout.topMargin: root._padding / 2

            spacing: root._gap

            ClickableWithIcon {
                visible: (opacity) > 0
                opacity: (root.navigation_stack.length > 1) ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                size: Constants.icon_size
                padding: Constants.padding
                radius: Constants.icon_size

                iconname: "arrow-left.svg"

                styles.background_color_idle: Constants.control_color_background_default

                styles.border_width: 1
                styles.border_color_idle: Constants.control_color_border_default
                styles.border_color_active: Constants.control_color_ink_active

                styles.icon_color_idle: Constants.control_color_ink_default
                styles.icon_color_active: Constants.control_color_ink_active

                onClicked: {
                    if (root.navigation_stack.length > 1) {
                        const newStack = root.navigation_stack.slice(0, -1);
                        root.navigation_stack = newStack;
                        root.content = newStack[newStack.length - 1];
                    }
                }
            }

            Item { Layout.fillWidth: true }

            DisplayControl {
                onClicked: Debug.log("Display Control Clicked")
            }
        }
    }
}