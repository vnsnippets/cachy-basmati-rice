pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell.Networking

import qs
import qs.Components

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: Constants.padding

    required property WiredDevice device

    StyledText {
        text: "Connection Details"
        font.bold: true
        color: Constants.spotlight_app_color_text
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: details_col.implicitHeight + (Constants.padding * 2)
        radius: Constants.radius
        color: Constants.spotlight_app_background_color
        border.color: Constants.spotlight_app_border_color

        ColumnLayout {
            id: details_col
            anchors.fill: parent
            anchors.margins: Constants.padding
            spacing: Constants.padding / 2

            RowLayout {
                Layout.fillWidth: true
                StyledText { text: "Network Name:"; color: Constants.spotlight_app_color_text }
                Item { Layout.fillWidth: true }
                StyledText { 
                    text: root.device?.name ?? (root.device?.state === ConnectionState.Connected ? "Ethernet Connection" : "N/A") 
                    color: Constants.color_surface
                }
            }

            RowLayout {
                Layout.fillWidth: true
                StyledText { text: "State:"; color: Constants.spotlight_app_color_text }
                Item { Layout.fillWidth: true }
                StyledText { 
                    text: root.device ? "Active" : "No Active Cable / Link"
                    color: root.device ? Constants.network_device_status_connected : Constants.spotlight_app_color_text
                }
            }
        }
    }
}