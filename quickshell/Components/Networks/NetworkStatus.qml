import QtQuick
import QtQuick.Layouts

import qs
import qs.Assets
import qs.Utilities
import qs.Components

import Quickshell.Networking


Clickable {
    id: root
    radius: Style.radius - 4
    
    colors.background.idle: Qt.alpha(Style.colors.surface, 0.60)
    colors.background.active: Qt.alpha(Style.colors.surface, 0.75)

    colors.border.idle: "transparent"
    colors.border.active: "transparent"

    clip: true

    readonly property var connectedWifiDevice: Networking.devices.values.find((dev) => dev.type === DeviceType.Wifi && dev.state === ConnectionState.Connected) ?? null;
    readonly property var activeWifiNetwork: connectedWifiDevice?.networks.values.find((nw) => nw.connected) ?? null;


    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.spacing * 2

        Clickable {
            Layout.margins: Style.padding
            Layout.rightMargin: 0

            borderWidth: 0
            colors.background.idle: (Networking.wifiEnabled) ? Style.colors.green : Style.colors.surface
            colors.background.active: colors.background.idle

            StyledText {
                anchors.centerIn: parent
                color: (Networking.wifiEnabled) ? Style.colors.base : Qt.alpha(Style.colors.text, 0.60)
                text:  "" 
            }

            onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.margins: Style.padding
            Layout.leftMargin: 0
            
            spacing: Style.spacing
            
            BarStrength {
                Layout.preferredWidth: implicitWidth
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                Layout.preferredHeight: 16

                strength: (connectedWifiDevice === null) ? 0 : activeWifiNetwork?.signalStrength * 100 ?? 0
                dimensions: Qt.size(10,10)
                // colors.active: (Networking.connectivity !== ConnectivityState.) ?
                //                 Style.colors.subtext : (NetworkMonitor.GlobalState < 70 || NetworkMonitor.ActiveAccessPoint.Strength < Context.networks.warningLimit) ?
                //                     Style.colors.yellow : (NetworkMonitor.ActiveAccessPoint.Strength < Context.networks.criticalLimit) ?
                //                         Style.colors.red : Style.colors.green
                length: 4
            }

            StyledText {
                Layout.fillWidth: true

                horizontalAlignment: Text.AlignLeft
                color: Style.colors.text
                text: (Networking.connectivity === NetworkConnectivity.Full) ? (activeWifiNetwork) ? root.activeWifiNetwork.name : "Ethernet" : "Disconnected"

                elide: Text.ElideRight
            }
        }
    }
}