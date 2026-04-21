
// Timer {
//     interval: 2000; running: true; repeat: true
//     onTriggered: {
//         if (typeof Statistics !== "undefined") {
//             Statistics.cpuUsageProc.running = true
//             Statistics.memoryUsageProc.running = true
//             Statistics.diskUsageProc.running = true
//         }
//     }
// }

// Repeater {
//     // Filter workspaces for current monitor [10]
//     model: Hyprland.workspaces.values.filter(ws => ws.monitor === taskbar.modelData)

//     Rectangle {
//         id: dot
//         height: 12
//         // Active is a pill (wider), others are dots [10, 11]
//         width: modelData.active ? 30 : 12
//         radius: 6
//         color: modelData.urgent ? Colors.urgent : (modelData.active ? Colors.active : Colors.foreground)
    
//         Behavior on width { NumberAnimation { duration: 200 } }

//         WrapperMouseArea {
//             anchors.fill: parent
//             cursorShape: Qt.PointingHandCursor
//             onClicked: modelData.activate()
//             onContainsMouseChanged: dot.opacity = containsMouse ? 0.9 : 1.0
//         }
//     }
// }

// NMCLI Access Point
// {
//     "objectName": "",
//     "lastIpcObject": {
//         "active": false,
//         "strength": 62,
//         "frequency": 2417,
//         "ssid": "Le Petit Poucet",
//         "bssid": "00:01:02:00:03:F3",
//         "security": "WPA2"
//     },
//     "ssid": "Le Petit Poucet",
//     "bssid": "00:01:02:00:03:F3",
//     "strength": 62,
//     "frequency": 2417,
//     "active": false,
//     "security": "WPA2",
//     "isSecure": true
// }