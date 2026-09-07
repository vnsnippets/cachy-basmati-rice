import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import qs
import qs.Services
import qs.Utilities
import qs.Components

ColumnLayout {
    id: root
    
    property var _monitors: ScreenService.screens
    required property string title
    property int animduration: 200

    spacing: Styles.spacing
    visible: repeater.count > 0

    // --- Section Header ---
    StyledText {
        text: root.title + " (" + repeater.count + ")"
        color: Styles.network.section.titlecolor // Reusing your semantic structure
        font.bold: true
    }

    Repeater {
        id: repeater
        model: root._monitors
        delegate: Rectangle {
            Layout.fillWidth: true

            color: "transparent"
            radius: Styles.radius
            height: 52

            border.width: 1
            border.color: Qt.alpha(Styles.colors.surface, 0.60)

            readonly property var monitor: modelData ?? null

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Styles.padding
                anchors.verticalCenter: parent.verticalCenter
                spacing: Styles.spacing

                StyledText {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    text: monitor.model
                    color: Styles.colors.text
                    elide: Text.ElideRight
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    leftPadding: Styles.padding / 2
                    text: monitor.name
                    color: Styles.colors.subtext
                    elide: Text.ElideRight
                }

                Clickable {
                    id: power
                    
                    StyledText {
                        readonly property color textcolor: (monitor.enabled) ? Styles.colors.green : Styles.colors.red

                        Layout.fillWidth: false
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        active: monitor.enabled
                        text: (monitor.enabled) ? "ON" : "OFF"
                        style.idle: Qt.alpha(textcolor, 0.4)
                        style.active: Qt.alpha(textcolor, 1)
                    }

                    onClicked: ScreenService.safeToggle(monitor)
                }
            }
        }
    }
}