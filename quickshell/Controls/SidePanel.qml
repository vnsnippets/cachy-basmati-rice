import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import qs.Styles

PanelWindow {
    id: panel
    
    anchors { top: true; right: true; bottom: true; }
    margins { top: Style.margin; left: Style.margin; right: Style.margin; bottom: Style.margin; } 
    
    // This property pushes other windows out of the way
    exclusiveZone: implicitWidth
    WlrLayershell.namespace: "qs-basmati-canvas"

    // Layer options: Overlay stays on top, Bottom stays behind
    WlrLayershell.layer: WlrLayer.Top
    // visible: root.active
    color: "transparent"
    

    Rectangle {
        anchors.fill: parent
        color: Style.panel.colors.background
        radius: Style.panel.radius

        border.width: Style.borderWidth
        border.color: Style.panel.colors.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20

            // Time and Date
            Column {
                Layout.fillWidth: true
                Text {
                    text: "18:13"
                    color: "white"
                    font.pixelSize: 56
                    font.weight: Font.Bold
                }
                Text {
                    text: "SUNDAY, 3 MAY"
                    color: "#aaaaaa"
                    font.pixelSize: 14
                    font.letterSpacing: 2
                }
            }

            // System Buttons Grid
            GridLayout {
                columns: 4
                rowSpacing: 10
                columnSpacing: 10

                // Creating 8 dummy buttons
                Repeater {
                    model: 8
                    Rectangle {
                        width: 60; height: 60
                        color: Qt.alpha(Style.colors.slate, 0.25)
                        radius: 10
                        Text { 
                            anchors.centerIn: parent
                            text: "󰄲" // Placeholder icon
                            color: "white"
                        }
                    }
                }
            }

            // Music Player Widget
            Rectangle {
                Layout.fillWidth: true
                height: 120
                color: "#252525"
                radius: 15
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15
                    
                    Rectangle {
                        width: 80; height: 80
                        radius: 8
                        color: "#444" // Album art placeholder
                    }
                    
                    Column {
                        Text { text: "Sample"; color: "white"; font.bold: true }
                        Text { text: "Testin"; color: "#888" }
                    }
                }
            }

            Item { Layout.fillHeight: true } // Spacer
        }
    }
}