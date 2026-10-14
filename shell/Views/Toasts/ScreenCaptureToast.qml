pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import qs
import qs.Services
import qs.Components

StyledBox {
    id: control

    property bool clipboard_holds_image: false

    readonly property list<var> options: [
        { 
            vector: "capture-region.svg",
            disabled: false,
            command: () => {
                EventOrchestrator.osdDismissEvent(); 
                Quickshell.execDetached([
                    "sh", "-c", Constants.screen_capture_command_region
                ]);
            } 
        },
        { 
            vector: "capture-screen.svg",
            disabled: false,
            command: () => {
                EventOrchestrator.osdDismissEvent(); 
                Quickshell.execDetached([
                    "sh", "-c", Constants.screen_capture_command_full
                ])
            } 
        },
        { 
            vector: "capture-image.svg",
            disabled: !control.clipboard_holds_image,
            command: () => {
                EventOrchestrator.osdDismissEvent(); 
                Quickshell.execDetached([
                    "sh", "-c", Constants.screen_capture_command_clipboard
                ])
            } 
        },
        { 
            vector: "dismiss.svg",
            disabled: false,
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
                required property bool disabled

                enabled: !disabled

                padding: Constants.padding / 1.5

                size: Constants.icon_size
                iconname: vector
                radius: Constants.radius / 2

                styles.icon_color_idle: Constants.color_subtext
                styles.icon_color_active: Constants.default_color_accent

                styles.background_color_idle: Qt.alpha(Constants.color_surface, 0)
                styles.background_color_active: Qt.alpha(Constants.color_surface, 1)

                opacity: (enabled) ? 1 : 0.5

                onClicked: command()
            }
        }
    }

    Process {
        id: proc_clipboard_check
        command: ["wl-paste", "--list-types"]
        running: !control.clipboard_holds_image

        stdout: SplitParser {
            onRead: (data) => {
                if (control.clipboard_holds_image) return;
                control.clipboard_holds_image = data.includes("image/");
            }
        }
    }
}