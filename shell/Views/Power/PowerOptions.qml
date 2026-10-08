pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Utilities
import qs.Components

RowLayout {
    id: root
    spacing: Constants.spacing

    property int max_height: 0

    Repeater {
        model: [
            {
                title: "Shutdown",
                desc: "Turn computer off",
                vector: "power.svg",
                accent: Constants.power_color_shutdown,
                command: ["systemctl", "poweroff"]
            },
            {
                title: "Reboot",
                desc: "Restart the machine",
                vector: "reboot.svg",
                accent: Constants.power_color_reboot,
                command: ["systemctl", "reboot"]
            },
            {
                title: "Suspend",
                desc: "Low power state",
                vector: "sleep.svg",
                accent: Constants.power_color_suspend,
                command: ["systemctl", "suspend"]
            },
            {
                title: "Log Out",
                desc: "End session",
                vector: "logout.svg",
                accent: Constants.power_color_logout,
                command: ["loginctl", "kill-session", Quickshell.env("XDG_SESSION_ID")]
            }
        ]
        
        delegate: Clickable {
            id: item

            Layout.fillWidth: true
            Layout.preferredWidth: 0

            required property string title
            required property string desc
            required property string vector
            required property color accent
            required property list<string> command

            readonly property bool active: containsMouse

            Rectangle {
                implicitHeight: Math.max(160, root.max_height)

                radius: Constants.radius
                color: Constants.power_color_background

                border.width: 1
                border.color: (enabled && item.active) ? item.accent : Constants.power_color_border

                Behavior on radius { NumberAnimation { duration: Constants.animation_duration } }
                Behavior on color { ColorAnimation { duration: Constants.animation_duration } }
                Behavior on border.color { ColorAnimation { duration: Constants.animation_duration } }

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Constants.padding * 2
                    spacing: Constants.spacing / 2

                    ClickableWithIcon {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.bottomMargin: Constants.padding
                        size: 48
                        padding: 0
                        iconname: item.vector
                        enabled: false
                        active: item.active
                        styles.icon_color_idle: Constants.power_color_ink_muted
                        styles.icon_color_active: item.accent
                    }

                    StyledText {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.bold: Constants.power_show_description
                        font.pixelSize: Constants.power_show_description ? 16 : 14
                        horizontalAlignment: Text.AlignHCenter
                        text: item.title
                        styles.color_idle: Constants.power_color_ink_muted
                        styles.color_active: item.accent
                        active: item.active
                    }

                    StyledText {
                        visible: Constants.power_show_description
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.pixelSize: Constants.font_size
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        text: item.desc
                        styles.color_idle: Qt.alpha(Constants.power_color_subtext, 0.75)
                        styles.color_active: Constants.power_color_ink_default
                        active: item.active
                    }
                }

            }

            onClicked: {
                Debug.log("[Power Menu] Executing System Action: " + command)
                Quickshell.execDetached({ command: command });
            }
        }
    }
}