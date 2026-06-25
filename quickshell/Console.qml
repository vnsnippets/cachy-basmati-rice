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
import qs.Views.Bluetooth

Rectangle {
    id: root
    property Component defaultcontent: Applications {
        maxheight: 400
    }

    property Component activecontent: defaultcontent

    property int contentradius: Styles.radius
    property color contentbackground: Qt.alpha(Styles.colors.surface, 0.4)
    property int contentpadding: Styles.padding * 3
    property int contentgap: Styles.spacing / 1.5

    radius: Styles.radius * 3
    color: Styles.controlcenter.background
    border.color: Styles.controlcenter.border
    border.width: 1
    antialiasing: true
    clip: true

    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: contentgap * 2

        visible: root.opacity > 0.1
        
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
                size: Styles.battery.pill.size
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
                color: contentbackground

                onSettingsClicked: activecontent = (active) ? defaultcontent : audiosettings

                Component { id: audiosettings; AudioDevices {} }
            }

            BrightnessControl {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                radius: contentradius
                color: contentbackground
            }

            KeepAwakeControl {
                defaultbackground: contentbackground
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
                backgroundstyle.idle: (isloaded) ? Styles.colors.red : contentbackground
                backgroundstyle.active: Styles.colors.red
                onClicked: activecontent = (isloaded) ? defaultcontent : powermenu

                Component { id: powermenu; PowerMenu { itemheight: 160; } }
            }
        }

        Container {
            id: content
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: contentpadding
            Layout.topMargin: 0
            sourceComponent: activecontent
            active: true
        }
    }
}