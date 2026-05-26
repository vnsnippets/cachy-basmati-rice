import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.Assets
import qs.Utilities
import qs.Components

RowLayout {
    id: root
    spacing: Style.spacing * 3
    
    // --- System Action Runner ---
    // Handles executing the actual system commands safely
    function runAction(command) {
        // You can use Quickshell's Process service here if imported:
        // Process.run(["sh", "-c", command])
        Debug.log("Executing System Action: " + command)
        Daemon.execute(command);
    }

    // --- Power Action Map ---
    // Maps action enums to icons, titles, accents, and shell commands
    readonly property var actionMap: ({
        0: { // Shutdown
            title: "Shutdown",
            desc: "Power off system safely",
            icon: "󰐥", 
            accent: Style.colors.red,
            command: ["poweroff"]
        },
        1: { // Reboot
            title: "Reboot",
            desc: "Restart the machine",
            icon: "󰜉",
            accent: Style.colors.peach,
            command: ["reboot"]
        },
        2: { // Suspend
            title: "Suspend",
            desc: "Sleep to low power state",
            icon: "󰤄",
            accent: Style.colors.mauve,
            command: ["systemctl", "suspend"]
        },
        3: { // Log Out
            title: "Log Out",
            desc: "End current session",
            icon: "󰍃",
            accent: Style.colors.maroon,
            // command: ["loginctl", "terminate-session", "$XDG_SESSION_ID"]
            command: ["uwsm", "stop"]
        }
    })

    // Inline Card Component for individual system actions
    component PowerButton : Clickable {
        id: button
        Layout.fillWidth: true
        Layout.fillHeight: true
        implicitHeight: 200

        property int actionType: -1
        readonly property var dataModel: root.actionMap[actionType]

        radius: Style.radius
        
        // Background blends subtly into the panel, brightening up smoothly on hover
        colors.background.idle: Qt.alpha(Style.colors.surface, 0.40)
        colors.background.active: Qt.alpha(Style.colors.surface, 0.65)
        
        // Default border matches your spec, shifts elegantly to the specific action's accent on hover
        colors.border.idle: Qt.alpha(Style.colors.surface, 0.40)
        colors.border.active: dataModel.accent

        onClicked: root.runAction(dataModel.command);

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.padding * 2
            spacing: Style.spacing

            // Large Hero Action Icon
            StyledText {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillHeight: true
                font.pixelSize: 48
                text: button.dataModel.icon
                style.idle: Style.colors.subtext
                style.active: button.dataModel.accent
                active: button.containsMouse
            }

            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                font.bold: true
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                text: button.dataModel.title
                style.idle: Style.colors.subtext
                style.active: button.dataModel.accent
                active: button.containsMouse

                Behavior on color { ColorAnimation { duration: Style.animations.duration } }
            }

            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                maximumLineCount: 2
                text: button.dataModel.desc
                style.idle: Style.colors.overlay
                style.active: Style.colors.subtext
                active: button.containsMouse
            }
        }
    }

    PowerButton { actionType: 0 }
    PowerButton { actionType: 1 }
    PowerButton { actionType: 2 }
    PowerButton { actionType: 3 }
}
