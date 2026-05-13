import QtQuick
import QtQuick.Layouts

import Quickshell

import NetworkMonitorPlugin

import qs
import qs.Styles
import qs.Controls
import qs.Utilities

ColumnLayout {
    id: root
    Layout.fillWidth: true
    
    readonly property int global_offline_index: 40
    readonly property int recency_threshold : 2592000 // 15 days

    property real scanTimestamp: NaN

    ListModel { id: networkModel }
    
    // Component for the network item to be used inside the scan loop
    Component {
        id: networkItemDelegate
        Rectangle {
            width: networkList.width
            height: 60
            color: Style.clickable.background.idle
            radius: 4
            
            // This property is set during object creation
            required property var networkData 

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    StyledText { 
                        text: networkData.Ssid || "Unknown SSID"
                        font.bold: true 
                    }
                    StyledText { 
                        text: "Strength: " + networkData.Strength + "%"
                        style.idle: Style.colors.subtext
                    }
                }
                Clickable {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    implicitWidth: 80
                    implicitHeight: 30
                    StyledText { anchors.centerIn: parent; text: "Connect" }
                    onClicked: NetworkMonitor.ConnectToAccessPoint(networkData.Ssid)
                }
            }
        }
    }

    // 1. Scan Button
    Clickable {
        colors.background.idle: Style.colors.surface
        Layout.bottomMargin: 10
        
        StyledText {
            anchors.centerIn: parent
            id: scanIcon
            text: ""
            
            // Smoothly return to 0 when not running
            Behavior on rotation { NumberAnimation { duration: 200 } }

            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
                running: Context.stopwatch?.scan_networks?.running ?? false
            }

            // Explicitly reset rotation to 0 when running becomes false
            onRotationChanged: {
                if (!Context.stopwatch?.scan_networks?.running && rotation !== 0) {
                    rotation = 0;
                }
            }
        }

        onClicked: {
            if (Context.stopwatch?.scan_networks?.running) return;

            networkModel.clear(); // Clear to restart animations
            Context.stopwatch.scan_networks = Stopwatch.create(container, false, true);

            const devices = NetworkControl.GetAllDevices();
            const networkDevice = devices.find((e) => e.DeviceType === 2) ?? devices.find((e) => e.DeviceType === 30);

            Context.stopwatch.scan_networks.begin(2000, () => {
                const results = NetworkControl.GetKnownNetworksInRange(networkDevice.DevicePath);
                results.sort((a, b) => {
                    // 1. Primary: Always prioritize Saved networks over guest/random ones
                    if (a.Saved !== b.Saved) return b.Saved - a.Saved;
                    
                    // 2. Prioritize recent connections (86400 for a full day) 
                    const now = Math.floor(Date.now() / 1000); // Current Unix time
                    
                    const aIsRecent = a.Saved && (now - a.LastConnected) < recency_threshold;
                    const bIsRecent = b.Saved && (now - b.LastConnected) < recency_threshold;

                    // If one is recent and the other isn't, the recent one wins
                    if (aIsRecent !== bIsRecent) return bIsRecent ? 1 : -1;

                    // 3. Tie-breaker for Recency
                    // If both are recent, or both are old/unsaved, look at signal strength. 
                    // If strengths are within 5% of each other, choose the most recent connection.
                    const strengthDiff = Math.abs(a.Strength - b.Strength);
                    if (strengthDiff > 5) {
                        return b.Strength - a.Strength;
                    }

                    // 4. Final Fallback: If strengths are nearly equal, most recent connection wins
                    return b.LastConnected - a.LastConnected;
                });

                root.scanTimestamp = Date.now()

                // Appending one-by-one ensures the ListView 'add' transition fires for each
                for (let i = 0; i < results.length; i++) {
                    const network = results[i];
                    networkModel.append(results[i]);
                }
            });
            NetworkControl.RequestScan(networkDevice.DevicePath);
        }
    }

    ListView {
        id: networkList
        Layout.fillWidth: true
        model: networkModel
        spacing: 8
        clip: true

        implicitHeight: Math.min(model.count * 60, 300)

        remove: Transition {
            ParallelAnimation {
                NumberAnimation { 
                    property: "opacity"; 
                    to: 0; 
                    duration: 300 
                }
                NumberAnimation { 
                    property: "x"; 
                    to: 100; // Slide out to the right
                    duration: 300; 
                    easing.type: Easing.InBack 
                }
            }
        }

        delegate: Rectangle {
            id: delegateRoot

            readonly property bool isConnected: (NetworkMonitor.GlobalState > 30) && (NetworkMonitor.ActiveAccessPoint?.Ssid === model.Ssid)

            anchors.left: parent.left
            anchors.right: parent.right

            height: 60
            color: "transparent"
            radius: 4
            
            opacity: 0
            x: 50

            GridLayout {           
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                
                rowSpacing: 2
                columnSpacing: Style.panel.padding/2
                
                StyledText { 
                    Layout.row: 0; Layout.column: 0; Layout.fillWidth: true; 
                    horizontalAlignment: Text.AlignLeft;
                    text: model.Ssid || "Unknown SSID";
                    font.bold: true ;
                }

                StyledText { 
                    Layout.row: 1; Layout.column: 0; Layout.fillWidth: true;
                    horizontalAlignment: Text.AlignLeft;
                    text: "Strength: " + model.Strength + "%"; 
                    style.idle: Style.colors.subtext;
                }

                Clickable {
                    Layout.row: 0; Layout.column: 1; Layout.fillWidth: false; Layout.rowSpan: 2;
                    visible: !delegateRoot.isConnected

                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    implicitWidth: 80; implicitHeight: 30
                    StyledText { anchors.centerIn: parent; text: "Connect" }

                    onClicked: {
                        const networkDevices = NetworkControl.GetAllDevices();
                        const wifiDevice = networkDevices.find((e) => e.DeviceType === 2) ?? networkDevices.find((e) => e.DeviceType === 30);
                        NetworkControl.ActivateConnection(wifiDevice.DevicePath, model.SettingsPath, model.AccessPointPath);
                    }
                }

                StyledText {            
                    Layout.row: 0; Layout.column: 1; Layout.fillWidth: false; Layout.rowSpan: 2;        
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    rightPadding: 4
                    visible: delegateRoot.isConnected

                    color: Style.colors.subtext
                    text: "Connected"
                }
            }

            SequentialAnimation {
                id: animateIn
                PauseAnimation { duration: Math.abs(Math.min(index * 50, 500)) }
                ParallelAnimation {
                    NumberAnimation { target: delegateRoot; property: "opacity"; from: 0; to: 1; duration: 400; }
                    NumberAnimation { target: delegateRoot; property: "x"; from: 50; to: 0; duration: 500; easing.type: Easing.OutCubic; }
                }
            }

            Component.onCompleted: animateIn.start();
        }
    }
}