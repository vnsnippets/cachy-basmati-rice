import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Styles
import qs.Utilities

RowLayout {
    id: root
    spacing: 12

    readonly property var device: UPower.displayDevice
    readonly property real batteryPercentage: device.percentage * 100

    Rectangle {
        id: arcRoot
        
        width: 72
        height: 72
        radius: width/2

        // Smaller radius brings the arc inside the circle
        readonly property var arc_center: radius
        readonly property var arc_radius: radius - radius/5        
        readonly property var arc_stroke: radius/8


        // Faint background color for the entire container circle
        color: Qt.rgba(1, 1, 1, 0.05) 
        
        // Optional border for a visible outer ring
        border.color: Qt.rgba(1, 1, 1, 0.1)
        border.width: 1

        property real animatedValue: 0
        readonly property color arcColor: {
            if (root.device.state === UPowerDeviceState.Charging) {
                return Style.color_yellow
            } else if (root.batteryPercentage <= Context.battery.criticalLimit) {
                return Style.color_red
            } else if (root.batteryPercentage <= Context.battery.warningLimit) {
                return Style.color_yellow
            } else {
                return Style.color_green
            }
        }

        NumberAnimation on animatedValue {
            from: 0
            to: root.batteryPercentage.toFixed(0) // Uses the batteryPercentage property (0-100)
            duration: 800
            easing.type: Easing.OutCubic 
        }

        NumberAnimation on scale {
            from: 0.8; to: 1; duration: 1000;
            easing.type: Easing.OutCubic 
        }

        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 6 // High samples for smooth rounded edges on CachyOS

            scale: 1 / arcRoot.scale 
            
            // 1. THE TRACK (Faint background)
            ShapePath {
                fillColor: "transparent"
                strokeColor: Qt.rgba(1, 1, 1, 0.1) // White with 10% opacity
                strokeWidth: arcRoot.arc_stroke/2

                PathAngleArc {
                    centerX: arcRoot.arc_center; centerY: arcRoot.arc_center;
                    radiusX: arcRoot.arc_radius; radiusY: arcRoot.arc_radius;
                    startAngle: 0
                    sweepAngle: 360 // Full circle track
                }
            }

            // 2. THE ANIMATED ARC
            ShapePath {
                fillColor: "transparent"
                strokeColor: arcRoot.arcColor
                strokeWidth: arcRoot.arc_stroke
                
                // This property rounds the start and end of the arc
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: arcRoot.arc_center; centerY: arcRoot.arc_center;
                    radiusX: arcRoot.arc_radius; radiusY: arcRoot.arc_radius;
                    startAngle: -90
                    sweepAngle: 360 * (arcRoot.animatedValue / 100)
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: arcRoot.animatedValue.toFixed(0) + "%"
            font.pixelSize: 16
            font.bold: true
            color: arcRoot.arcColor
        }
    }

    Column {
        Text {
            readonly property bool isCharging: root.device.state === UPowerDeviceState.Charging || root.device.state === UPowerDeviceState.PendingCharge
            text: `AC: ${(isCharging) ? "Connected" : "Disconnected"}`
            font.pixelSize: 16
            color: Style.color_light
        }

        Text {
            text: {
                if (root.device.state === UPowerDeviceState.Charging) return "Full in: " + secondsToHoursAndMinutesString(device.timeToFull);
                if (root.device.state === UPowerDeviceState.Discharging) return secondsToHoursAndMinutesString(device.timeToEmpty);
                return "Not Charging";
            }
            
            visible: text !== ""

            font.pixelSize: 14
            color: Style.color_light
            opacity: 0.6

            function secondsToHoursAndMinutesString(totalSeconds) {
                const total = Math.floor(totalSeconds);
                const hours = Math.floor(total / 3600);
                const minutes = Math.floor((total % 3600) / 60);

                return `${hours} ${hours > 1 ? "Hours" : "Hour"} ${minutes} ${minutes > 1 ? "Minutes" : "Minute"}`
            }
        }
    }
}