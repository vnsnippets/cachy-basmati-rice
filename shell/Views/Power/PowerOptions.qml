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
                accent: Constants.color_red,
                command: ["systemctl", "poweroff"]
            },
            {
                title: "Reboot",
                desc: "Restart the machine",
                vector: "reboot.svg",
                accent: Constants.color_peach,
                command: ["systemctl", "reboot"]
            },
            {
                title: "Suspend",
                desc: "Low power state",
                vector: "sleep.svg",
                accent: Constants.color_mauve,
                command: ["systemctl", "suspend"]
            },
            {
                title: "Log Out",
                desc: "End session",
                vector: "logout.svg",
                accent: Constants.color_sapphire,
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
            required property int command

            readonly property bool active: containsMouse
            readonly property color background_color_idle: Qt.alpha(Constants.color_surface, 0.40)
            readonly property color background_color_active: Qt.alpha(Constants.color_surface, 0.65)
            readonly property color color_idle: Qt.alpha(Constants.color_surface, 0.40)
            readonly property color color_active: item.accent

            Rectangle {
                implicitHeight: Math.max(160, root.max_height)

                radius: Constants.radius
                color: (enabled && item.active) ? item.background_color_active : item.background_color_idle

                border.width: 1
                border.color: (enabled && item.active) ? item.color_active : item.color_idle

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
                        styles.icon_color_idle: Constants.color_subtext
                        styles.icon_color_active: item.accent
                    }

                    StyledText {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        text: item.title
                        styles.color_idle: Constants.color_overlay
                        styles.color_active: Constants.color_text
                        active: item.active
                    }
                }

            }

            onClicked: {
                Debug.log("[Power Menu] Executing System Action: " + item.command)
                Quickshell.execDetached({ command: item.command });
            }
        }
    }
}