import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs
import qs.Assets
import qs.Utilities
import qs.Components
import qs.Components.Power
import qs.Components.Audio
import qs.Components.Battery
import qs.Components.Networks
import qs.Components.Bluetooth
import qs.Components.Brightness

Rectangle {
    id: root
    required property var tabs
    property Component activeContent: (tabs.length > 0) ? tabs[0].content : null

    radius: Style.radius + 4
    color: Style.panel.colors.background
    border.color: Style.colors.subtext
    border.width: 1
    antialiasing: true
    clip: true

    implicitWidth: Style.panel.width
    implicitHeight: Math.min(consoleLayout.implicitHeight, Style.panel.width)

    ColumnLayout {
        id: consoleLayout
        anchors.fill: parent
        
        // To prevent layout flickering during size animation
        visible: root.opacity > 0.1

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Style.padding
            Layout.topMargin: Style.padding * 1.5
            Layout.leftMargin: Style.padding * 1.5
            Layout.rightMargin: Style.padding * 1.5
            Layout.alignment: Qt.AlignVCenter

            StyledText {
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: Style.colors.text
                text: Qt.formatDateTime(Context.clock.date, "yyyy-MM-dd")
            }

            Item { Layout.fillWidth: true }

            StyledText {
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: Style.colors.text
                text: Qt.formatDateTime(Context.clock.date, "HH:mm")
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Style.padding
            Layout.bottomMargin: 0
            Layout.topMargin: 0

            VolumeSlider {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                radius: Style.radius - 4
                color: Qt.alpha(Style.colors.surface, 0.60)

                onSettingsClicked: root.activeContent = _AudioSettings
            }

            BrightnessSlider {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Style.radius - 4
                color: Qt.alpha(Style.colors.surface, 0.60)
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 0

                Clickable {
                    id: awakeOpt
                    radius: Style.radius - 4
                    colors.background.idle: Qt.alpha(Style.colors.surface, 0.60)
                    colors.background.active: Style.colors.red
                    
                    borderWidth: 0

                    readonly property bool active: Context.keepAwakeProcess !== null
                    
                    onClicked: () => {
                        if (active) {
                            Context.keepAwakeProcess.running = false;
                            Context.keepAwakeProcess = null;
                        } else {
                            // Start and save the reference
                            var cmd = ["systemd-inhibit", "--what=idle", "sleep", "infinity"]
                            Context.keepAwakeProcess = Daemon.execute(cmd);

                            // Process dies unexpectedly (crashes), reset our state
                            Context.keepAwakeProcess.runningChanged.connect(() => {
                                if (Context.keepAwakeProcess && !Context.keepAwakeProcess.running) {
                                    Context.keepAwakeProcess.running = false;
                                    Context.keepAwakeProcess = null;
                                }
                            });
                        }
                    }

                    StyledText {
                        anchors.centerIn: parent
                        text: (awakeOpt.active) ? "󱂟" : ""
                        style.idle: (awakeOpt.active) ? awakeOpt.Style.colors.red : awakeOpt.Style.colors.blue
                        active: awakeOpt.containsMouse
                    }
                }
                
                Clickable {
                    id: powerWidget
                    radius: Style.radius - 4

                    colors.background.idle: Qt.alpha(Style.colors.surface, 0.60)
                    colors.background.active: Style.colors.red
                    
                    borderWidth: 0

                    // onClicked: Context.process.shutdown = Daemon.execute(["poweroff"]);
                    StyledText {
                        anchors.centerIn: parent
                        text: ""
                        active: powerWidget.containsMouse
                        style.idle: Style.colors.red
                        style.active: Style.colors.base
                        font.pixelSize: 18
                        
                    }
                    onClicked: root.activeContent = _PowerMenu;
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Style.padding
            Layout.topMargin: 0

            NetworkStatus { 
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                onClicked: root.activeContent = _NetworkSettings
            }
            
            BluetoothStatus {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                onClicked: root.activeContent = _BluetoothSettings
            }
            
            BatteryStatus {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                onClicked: root.activeContent = _PowerProfiles
            }
        }

        AnimatedLoader {
            id: tabContent
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: Style.padding
            Layout.rightMargin: Style.padding

            active: true
            sourceComponent: root.activeContent
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Layout.margins: Style.padding
            spacing: Style.spacing
            visible: root.tabs.length > 0

            Repeater {
                model: root.tabs
                delegate: Clickable {
                    id: tab                        
                    property bool isActive: root.tabs[index].content === root.activeContent

                    colors.background.idle: tab.isActive ? Style.colors.surface : Qt.alpha(Style.colors.surface, 0.60)
                    colors.background.active: Style.colors.surface

                    borderWidth: 0

                    StyledText {
                        anchors.centerIn: parent
                        text: modelData.icon
                        font.pixelSize: 18
                        style.idle: tab.isActive ? Style.colors.text : Style.colors.subtext
                    }

                    onClicked: root.activeContent = root.tabs[index].content
                }
            }
        }
    }

    Component {
        id: _AudioSettings
        AudioSettings { }
    }

    Component {
        id: _BluetoothSettings
        BluetoothSettings { }
    }
    
    Component {
        id: _NetworkSettings
        NetworkSettings { }
    }

    Component {
        id: _PowerProfiles
        PowerProfiles { }
    }

    Component {
        id: _PowerMenu
        PowerMenu { }
    }
}
