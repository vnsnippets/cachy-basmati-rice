pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell

import qs
import qs.Services
import qs.Components

StyledBox {
    id: control

    readonly property list<var> options: [
        { 
            vector: "capture-region.svg",
            command: () => {
                EventOrchestrator.osdDismissEvent(); 
                Quickshell.execDetached([
                    "sh", "-c", Constants.screen_capture_command_region
                ]);
            } 
        },
        { 
            vector: "capture-screen.svg",
            command: () => {
                EventOrchestrator.osdDismissEvent(); 
                Quickshell.execDetached([
                    "sh", "-c", Constants.screen_capture_command_full
                ])
            } 
        },
        { 
            vector: "dismiss.svg", 
            command: () => { 
                EventOrchestrator.osdDismissEvent(); 
            } 
        }
    ]

    implicitHeight: content.implicitHeight + Constants.padding
    implicitWidth: content.implicitWidth + Constants.padding

    RowLayout {
        id: content
        anchors.centerIn: parent

        spacing: 2

        Repeater {
            model: control.options
            delegate: ClickableIcon {
                required property string vector
                required property var command

                padding: Constants.padding / 1.5

                size: Constants.icon_size
                iconname: vector
                radius: Constants.radius / 2

                styles.icon_color_idle: Constants.color_subtext
                styles.icon_color_active: Constants.color_text

                styles.background_color_idle: Qt.alpha(Constants.color_surface, 0)
                styles.background_color_active: Qt.alpha(Constants.color_surface, 1)

                onClicked: command()
            }
        }
    }
}