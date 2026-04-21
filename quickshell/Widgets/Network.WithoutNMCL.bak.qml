// import QtQuick
// import Quickshell
// import Quickshell.Io

// import qs
// import qs.Utilities
// import qs.Style
// import qs.Services

// WidgetBase {
//     id: widget

//     readonly property int _StateDisconnected: -1
//     readonly property int _StateConnecting: 0
//     readonly property int _StateConnected: 1

//     readonly property int _TypeNone: -1
//     readonly property int _TypeWireless: 1
//     readonly property int _TypeEthernet: 2

//     property int state: _StateDisconnected
//     property int type: _TypeNone


//     // property string connectionState: "none"
//     // property bool isConnected: false

//     property string ssid: "None"
//     property int strength: 0

//     // Monitoring process for state changes
//     Process {
//         id: nm_monitor
//         command: ["nmcli", "monitor"]
//         running: true

//         stdout: SplitParser {
//             onRead: (e) => {
//                 console.log(`[nm_monitor][${Date.now()}] ${e}`)
//                 if (e.includes("connected") || e.includes("disconnected") || e.includes("using connection") || e.includes("connecting")) {
//                     nm_current_state.running = true
//                     nm_signal_monitor.running = true
//                 }
//             }
//         }
//     }

//     // Polling signal strength
//     Process {
//         id: nm_signal_monitor
//         command: ["nmcli", "-t", "-f", "IN-USE, SIGNAL, SSID", "device", "wifi"]
//         stdout: SplitParser {
//             onRead: (e) => {
//                 if (e.startsWith("*")) {
//                     state = _StateConnected
//                     type = _TypeWireless

//                     let parts = e.split(":")
//                     strength = parseInt(parts[1])
//                     ssid = parts[2]
//                 }
//             }
//         }
//     }

//     // Fetch current network connection
//     Process {
//         id: nm_current_state
//         running: false
//         command: ["nmcli", "-t", "-f", "TYPE, STATE", "dev"]
//         stdout: SplitParser {
//             onRead: (e) => {
//                 console.log(`[nm_current_state][${Date.now()}] ${e}`)

//                 if (e.includes("connecting")) {
//                     state = _StateConnecting
//                 }

//                 if ((e.includes("wifi") || e.includes("ethernet")) && e.includes(":connected")) {
//                     state = _StateConnected

//                     let type = e.split(":")[0]
//                     type = (type === "wifi" || type === "802-11-wireless") ? "wifi" : "ethernet"
//                 }
//             }
//         }
//     }

//     Timer {
//         interval: 5000
//         running: type === _TypeWireless
//         repeat: true
//         triggeredOnStart: true
//         onTriggered: nm_signal_monitor.running = true
//     }

//     icon: {
//         switch (state) {
//             case _StateDisconnected: return ""
//             case _StateConnected: 
//                 return (type === _TypeWireless) ? "" : ""
//             case _StateConnecting: return "X"
//             default: return "!!"
//         }
//     }    
//     // (state === _StateDisconnected) ? "" : (connectionType === "wifi") ? "" : ""

//     label: {
//         switch (state) {
//             case _StateDisconnected: return "Disconnected"
//             case _StateConnected: 
//                 return (type === _TypeWireless) ? ssid : "Ethernet"
//             case _StateConnecting: return "Connecting"
//             default: return "Error"
//         }
//     }
//     //!isConnected ? "Disconnected" : (connectionType === "wifi") ? `${ssid} (${strength}%)` : "Ethernet"

//     style.foreground.idle: {
//         switch (state) {
//             case _StateDisconnected: return Theme.color_red
//             case _StateConnected: 
//                 return (type === _TypeWireless) ? 
//                     (strength <=25) ? Theme.color_red : (strength <= 50) ? Theme.color_yellow : Theme.color_green :
//                     Theme.color_green
//             case _StateConnecting: return Theme.color_yellow
//             default: return Theme.color_red
//         }
//     }
    
//     // !isConnected ? Theme.color_red :(connectionType === "wifi") ?
//     //     ((strength <= 25) ? Theme.color_red : (strength <= 50) ? Theme.color_yellow : Theme.color_green) 
//     //     : Theme.color_green

//     Component.onCompleted: nm_current_state.running = true
// }