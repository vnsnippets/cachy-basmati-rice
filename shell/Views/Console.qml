pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs
import qs.Components
import qs.Layouts
import qs.Views.System
import qs.Views.Network
import qs.Views.Bluetooth
import qs.Views.Applications

StyledBox {
    id: root
    readonly property int _gap: Constants.spacing / 1.5
    readonly property Component default_content: PowerProfileSelection { }
    property Component active_content: default_content

    colors.background: Constants.console_color_background
    colors.border: Constants.console_color_border

    radius: Constants.radius * 2
    
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    ColumnLayout {
        id: content
        anchors.fill: parent
        spacing: root._gap * 2
        visible: root.opacity > 0.1
        
        // // Use margins within Layout instead of bottomMargin anchor
        // Layout.bottomMargin: root._padding
        
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
                radius: Constants.radius
                Layout.maximumWidth: Constants.bluetooth_pill_max_width
                // active: activecontent === bluetoothmanager
                // onClicked: activecontent = (active) ? defaultcontent : bluetoothmanager

                // Component {
                //     id: bluetoothmanager
                //     BluetoothDevices {}
                // }
            }

            NetworkWidget {
                radius: Constants.radius
                Layout.maximumWidth: Constants.network_pill_max_width
                // active: activecontent === networkmanagement
                // onClicked: activecontent = (active) ? defaultcontent : networkmanagement

                // Component {
                //     id: networkmanagement
                //     NetworkDevices {}
                // }
            }

            BatteryWidget {
                radius: Constants.radius
                // active: activecontent === powerprofiles
                // onClicked: activecontent = (active) ? defaultcontent : powerprofiles

                // Component {
                //     id: powerprofiles
                //     PowerProfiles { itemheight: 200; }
                // }
            }
        }

        // --- Main Container ---
        ContentContainer {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: Constants.padding * 2
            Layout.rightMargin: Constants.padding * 2
            Layout.bottomMargin: Constants.padding * 2
            content: root.active_content
        }
    }
}