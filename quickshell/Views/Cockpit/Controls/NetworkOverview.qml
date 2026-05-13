import QtQuick
import QtQuick.Layouts

import qs
import qs.Styles
import qs.Controls

import NetworkMonitorPlugin

Clickable {
    id: root
    radius: Style.panel.radius - 4
    
    colors.background.idle: Qt.alpha(Style.colors.surface, 0.5)
    colors.background.active: Qt.alpha(Style.colors.surface, 0.75)

    colors.border.idle: "transparent"
    colors.border.active: "transparent"

    clip: true

    ColumnLayout {
        id: layout
        spacing: Style.spacing/2
        anchors.left: parent.left
        anchors.right: parent.right

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.margins: Style.panel.padding
            Layout.bottomMargin: 0

            StyledText {
                Layout.fillWidth: false
                Layout.fillHeight: true
                Layout.preferredWidth: implicitWidth
                Layout.alignment: Qt.AlignVCenter
                
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                
                color: Style.colors.subtext
                text: {
                    if (Context.stopwatch.scan_networks?.running) return "";

                    if (NetworkMonitor.GlobalState < 20) return "\uEE59";
                    if (NetworkMonitor.GlobalState < 30) return "";

                    const s = NetworkMonitor.ActiveAccessPoint?.Strength ?? 0;

                    if (s < Context.network.criticalLimit) return "\uF8C8";
                    if (s < Context.network.degradedLimit) return "\uF8C6";

                    return "\uF8C5";
                }
            }
            
            StyledText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: implicitWidth
                Layout.alignment: Qt.AlignVCenter
                
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                
                color: Style.colors.subtext
                text: (NetworkMonitor.GlobalState >= 70) ? 
                        "Connected" : (NetworkMonitor.GlobalState >= 50) ?
                            "Limited Connection" : (NetworkMonitor.GlobalState >= 30) ?
                                "Connecting..." : "Disconnected"
            }
            
            BarStrength {
                // visible: NetworkMonitor.GlobalState >= 50
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: implicitWidth
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

                strength: NetworkMonitor.ActiveAccessPoint?.Strength ?? 0
                dimensions: Qt.size(12, 12)
                colors.active: (NetworkMonitor.GlobalState < 30) ?
                                Style.colors.subtext : (NetworkMonitor.GlobalState < 70 || NetworkMonitor.ActiveAccessPoint.Strength < Context.network.warningLimit) ?
                                    Style.colors.yellow : (NetworkMonitor.ActiveAccessPoint.Strength < Context.network.criticalLimit) ?
                                        Style.colors.red : Style.colors.green
                length: 4
            }

            // StyledText {
            //     visible: NetworkMonitor.GlobalState >= 50
            //     Layout.fillWidth: false
            //     Layout.fillHeight: true
            //     Layout.preferredWidth: implicitWidth
            //     Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                
            //     color: Style.colors.text
            //     text: (NetworkMonitor.ActiveAccessPoint?.Strength ?? 0) + "%"
            // }
        }

        StyledText {
            Layout.margins: Style.panel.padding
            Layout.topMargin: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter

            horizontalAlignment: Text.AlignLeft
            color: Style.colors.text
            text: NetworkMonitor.ActiveAccessPoint?.Ssid ?? "Offline"

            elide: Text.ElideRight
        }
    }
}