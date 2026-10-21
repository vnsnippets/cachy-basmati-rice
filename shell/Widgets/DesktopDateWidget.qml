pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import qs
import qs.Components

// qmllint disable
PanelWindow {
// qmllint enable

    id: root
    screen: root.screen

    anchors.top: true
    anchors.left: true

    implicitHeight: layout.height + (Constants.padding * 14)
    implicitWidth: layout.width + (Constants.padding * 16)

    // Place the window on the background layer (behind normal windows)
    WlrLayershell.layer: WlrLayer.Background
    
    // Ensure it doesn't reserve space or interfere with window managers
    exclusionMode: ExclusionMode.Ignore

    color: "transparent"

    ColumnLayout {
        id: layout
        spacing: 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        StyledText {
            id: timeText
            text: Qt.formatDateTime(Constants.clock.date, "dddd, MMMM dd")
            font.pixelSize: 36
            color: Constants.color_light
            // Optional: add subtle shadow/outline for readability against wallpapers
        }
    }

    // Requires import QtQuick.Effects
    // MultiEffect {
    //     source: layout
    //     anchors.fill: layout
    //     shadowEnabled: true
    //     shadowColor: Constants.color_dark // Semi-transparent black
    //     shadowBlur: 0.8
    //     shadowHorizontalOffset: 0
    //     shadowVerticalOffset: 2
    //     opacity: 0.4
    // }
}