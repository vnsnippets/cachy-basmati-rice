import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Widgets

import qs
import qs.Views
import qs.Layouts
import qs.Utilities
import qs.Components
import qs.Views.Audio
import qs.Views.Network
import qs.Views.Displays
import qs.Views.Bluetooth

Rectangle {
    id: root
    property Component defaultcontent: Applications { maxheight: 400 }

    property Component activecontent: defaultcontent

    property int contentradius: Styles.radius
    property int contentpadding: Styles.padding * 3
    property int contentgap: Styles.spacing / 1.5

    radius: Styles.radius * 3
    color: Styles.controlcenter.background
    border.color: Styles.controlcenter.border
    border.width: 1
    antialiasing: true
    clip: true

    // Set implicit dimensions based on child layout preferences
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        // DO NOT use anchors.fill: parent here when root.implicitHeight relies on layout.implicitHeight
        width: parent.width
        spacing: contentgap * 2

        visible: root.opacity > 0.1
        
        // Use margins within Layout instead of bottomMargin anchor
        Layout.bottomMargin: contentpadding
        
        // --- Header Row ---
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: contentpadding
            Layout.bottomMargin: 0
            Layout.alignment: Qt.AlignVCenter
            spacing: contentgap

            ColumnLayout {
                spacing: 1
                StyledText {
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: Qt.alpha(Styles.controlcenter.text, 0.75)
                    text: Qt.formatDateTime(Context.clock.date, "dddd")
                }
                StyledText {
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: Styles.controlcenter.text
                    font.pixelSize: 16
                    text: Qt.formatDateTime(Context.clock.date, "yyyy-MM-dd HH:mm")
                }
            }

            Item { Layout.fillWidth: true }

            NetworkControl {
                active: activecontent === networkmanagement
                radius: contentradius
                onClicked: activecontent = (active) ? defaultcontent : networkmanagement
                Layout.maximumWidth: Styles.network.pill.maxwidth

                Component {
                    id: networkmanagement
                    NetworkDevices {}
                }
            }
            
            BluetoothControl {
                active: activecontent === bluetoothmanager
                radius: contentradius
                onClicked: activecontent = (active) ? defaultcontent : bluetoothmanager
                Layout.maximumWidth: Styles.network.pill.maxwidth

                Component {
                    id: bluetoothmanager
                    BluetoothDevices {}
                }
            }
            
            BatteryControl {
                active: activecontent === powerprofiles
                radius: contentradius
                onClicked: activecontent = (active) ? defaultcontent : powerprofiles

                Component {
                    id: powerprofiles
                    PowerProfiles { itemheight: 200; }
                }
            }

            ClickableWithIcon {
                visible: Debug._DEBUG_MODE_
                size: Styles.size - Styles.padding * 2
                padding: Styles.padding / 1.5
                radius: contentradius
                iconname: "dismiss.svg"
                iconstyle.idle: Styles.colors.red
                iconstyle.active: Styles.colors.base
                enablebackground: true
                backgroundstyle.idle: Qt.alpha(Styles.colors.red, 0.1)
                backgroundstyle.active: Qt.alpha(Styles.colors.red, 1)
                onClicked: Quickshell.execDetached(["pkill", "-9", "quickshell"])
            }
        }

        // --- Controls Row ---
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: contentpadding
            Layout.rightMargin: contentpadding
            spacing: contentgap

            AudioVolumeControl {
                readonly property bool active: activecontent === audiosettings
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                radius: contentradius
                color: Styles.pill.background

                onSettingsClicked: activecontent = (active) ? defaultcontent : audiosettings

                Component { id: audiosettings; AudioDevices {} }
            }

            BrightnessControl {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                radius: contentradius
                color: Styles.pill.background
            }

            KeepAwakeControl {
                defaultbackground: Styles.pill.background
                radius: contentradius
            }

            ClickableWithIcon {
                id: powermenucontrol
                readonly property bool isloaded: activecontent === powermenu

                size: Styles.size - Styles.padding * 2
                padding: Styles.padding
                radius: contentradius
                iconname: "power.svg"
                iconstyle.idle: (isloaded) ? Styles.colors.base : Styles.colors.red
                iconstyle.active: Styles.colors.base
                enablebackground: true
                backgroundstyle.idle: (isloaded) ? Styles.colors.red : Styles.pill.background
                backgroundstyle.active: Styles.colors.red
                onClicked: activecontent = (isloaded) ? defaultcontent : powermenu

                Component { id: powermenu; PowerMenu { itemheight: 160; } }
            }
        }

        // --- Main Container ---
        Container {
            id: content
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: contentpadding
            Layout.rightMargin: contentpadding
            sourceComponent: activecontent
            active: true
        }

        // --- Bottom Controls Row ---
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: contentpadding
            Layout.rightMargin: contentpadding
            Layout.bottomMargin: contentpadding
            spacing: contentgap

            KeepAwakeControl {
                defaultbackground: Styles.pill.background
                radius: contentradius
            }
            
            Item { Layout.fillWidth: true }

            ClickableWithIcon {
                id: managedisplays
                readonly property bool isloaded: activecontent === displaymanager

                size: Styles.size - Styles.padding * 2
                padding: Styles.padding
                radius: contentradius
                iconname: "desktop.svg"
                iconstyle.idle: (isloaded) ? Styles.colors.base : Styles.colors.text
                iconstyle.active: Styles.colors.base
                enablebackground: true
                backgroundstyle.idle: (isloaded) ? Styles.colors.text : Styles.pill.background
                backgroundstyle.active: Styles.colors.text
                onClicked: activecontent = (isloaded) ? defaultcontent : displaymanager

                Component { id: displaymanager; DisplayManagement { title: "Monitors" } }
            }
        }
    }
}