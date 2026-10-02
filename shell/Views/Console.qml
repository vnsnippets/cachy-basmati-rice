pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs
import qs.Components
import qs.Layouts
import qs.Views.Power
import qs.Views.System
import qs.Views.Network
import qs.Views.Battery
import qs.Views.Bluetooth
import qs.Views.Applications

StyledBox {
    id: root
    readonly property int _gap: Constants.spacing / 1.5
    readonly property Component default_content: ApplicationSpotlight { max_height: 160 }
    property Component active_content: default_content

    colors.background: Constants.console_color_background
    colors.border: Constants.console_color_border

    radius: Constants.radius * 2
    
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    // Smoothly animate box container height adjustments
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
            Layout.topMargin: Constants.padding * 2
            Layout.leftMargin: Constants.padding * 2
            Layout.rightMargin: Constants.padding * 2
            spacing: root._gap

            ClockWidget { Layout.alignment: Qt.AlignTop; }

            Item { Layout.fillWidth: true; }

            BluetoothWidget {
                Layout.maximumWidth: Constants.bluetooth_pill_max_width
            }

            NetworkWidget {
                Layout.maximumWidth: Constants.network_pill_max_width
            }

            BatteryWidget {
                active: root.active_content === component_battery_profiles
                onClicked: root.active_content = (active) ? root.default_content : component_battery_profiles
                Component { id: component_battery_profiles; BatteryProfiles { max_height: 160 } }
            }

            PowerButton {
                active: root.active_content === component_power_menu
                onClicked: root.active_content = (active) ? root.default_content : component_power_menu
                Component { id: component_power_menu; PowerOptions { max_height: 160 } }
            }
        }

        // --- Main Container ---
        ContentContainer {
            Layout.fillWidth: true
            // Remove Layout.fillHeight so layout calculates preferred implicitHeight automatically
            Layout.preferredHeight: implicitHeight
            Layout.leftMargin: Constants.padding * 2
            Layout.rightMargin: Constants.padding * 2
            Layout.bottomMargin: Constants.padding * 2
            content: root.active_content
        }
    }
}