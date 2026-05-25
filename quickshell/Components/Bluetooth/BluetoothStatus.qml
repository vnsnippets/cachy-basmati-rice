import QtQuick
import QtQuick.Layouts

import Quickshell.Bluetooth

import qs
import qs.Assets
import qs.Components

Clickable {
    id: root
    radius: Style.radius - 4
    
    colors.background.idle: Qt.alpha(Style.colors.surface, 0.60)
    colors.background.active: Qt.alpha(Style.colors.surface, 0.75)

    colors.border.idle: "transparent"
    colors.border.active: "transparent"

    clip: true

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.spacing * 2

        Clickable {
            Layout.margins: Style.padding
            Layout.rightMargin: 0

            borderWidth: 0
            colors.background.idle: (Bluetooth.defaultAdapter?.enabled) ? Style.colors.green : Style.colors.surface
            colors.background.active: colors.background.idle

            StyledText {
                anchors.centerIn: parent
                color: (Bluetooth.defaultAdapter?.enabled) ? Style.colors.base : Style.colors.text
                text: "󰂯"
            }

            onClicked: {
                if (Bluetooth.defaultAdapter) {
                    Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
                }
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.margins: Style.padding
            Layout.leftMargin: 0
            
            spacing: Style.spacing/2
            
            RowLayout {
                Layout.fillWidth: true
                
                StyledText {
                    Layout.fillWidth: true
                    Layout.preferredWidth: implicitWidth
                    Layout.alignment: Qt.AlignVCenter
                    
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    
                    color: Style.colors.subtext
                    text: (Bluetooth.defaultAdapter?.enabled) ? "Online" : "Offline"
                }
            }

            StyledText {
                Layout.fillWidth: true

                horizontalAlignment: Text.AlignLeft
                color: Style.colors.text
                text: "Connected: " +  Bluetooth.devices.values.filter((dev) => dev.connected).length

                elide: Text.ElideRight
            }
        }
    }
}