import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.Utilities
import qs.Components

RowLayout {
    id: root
    spacing: Styles.spacing

    property int itemheight: 0
    property int animduration: 250

    // --- System Action Runner ---
    function runAction(command) {
        Debug.log("Executing System Action: " + command)
        Quickshell.execDetached({
            command: command
        });
    }

    Repeater {
        id: repeater
        model: [
            {
                title: "Shutdown",
                desc: "Turn computer off",
                icon: "power.svg",
                accent: Styles.colors.red,
                command: ["systemctl", "poweroff"]
            },
            {
                title: "Reboot",
                desc: "Restart the machine",
                icon: "reboot.svg",
                accent: Styles.colors.peach,
                command: ["systemctl", "reboot"]
            },
            {
                title: "Suspend",
                desc: "Low power state",
                icon: "sleep.svg",
                accent: Styles.colors.mauve,
                command: ["systemctl", "suspend"]
            },
            {
                title: "Log Out",
                desc: "End session",
                icon: "logout.svg",
                accent: Styles.colors.sapphire,
                command: ["loginctl", "kill-session", Quickshell.env("XDG_SESSION_ID")]
            }
        ]
        
        delegate: Clickable {
            id: card
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            implicitHeight: root.itemheight

            // Create a clean local alias linking to the repeater's array data point
            readonly property var data: modelData

            radius: Styles.radius
            
            styles.background.idle: Qt.alpha(Styles.colors.surface, 0.40)
            styles.background.active: Qt.alpha(Styles.colors.surface, 0.65)
            styles.border.idle: Qt.alpha(Styles.colors.surface, 0.40)
            styles.border.active: card.data.accent

            onClicked: {
                Debug.log("Executing System Action: " + card.data.command)
                Quickshell.execDetached({
                    command: card.data.command
                });
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Styles.padding * 2
                spacing: Styles.spacing

                ClickableWithIcon {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    size: 48
                    padding: 0
                    iconname: card.data.icon
                    enabled: false
                    iconstyle.idle: card.active ? card.data.accent : Styles.colors.subtext;
                    iconstyle.active: card.data.accent
                }

                StyledText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    text: card.data.title
                    style.idle: Styles.colors.overlay
                    style.active: Styles.colors.text
                    active: card.containsMouse
                }
            }
        }
    }
}
