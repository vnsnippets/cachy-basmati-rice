pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell.Services.UPower

import qs
import qs.Components

RowLayout {
    id: root
    spacing: Constants.spacing

    property int max_height: 0

    Repeater {
        model: [
            {
                title: "Power Saver",
                desc: "Optimal Battery",
                vector: "leaf.svg",
                accent: Constants.battery_color_powersaver,
                profile: PowerProfile.PowerSaver
            },
            {
                title: "Balanced",
                desc: "Default Profile",
                vector: "balance.svg",
                accent: Constants.battery_color_balanced,
                profile: PowerProfile.Balanced
            },
            {
                title: "Performance",
                desc: "Full Throttle",
                vector: "fire.svg",
                accent: Constants.battery_color_performance,
                profile: PowerProfile.Performance
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
            required property int profile

            readonly property bool active: PowerProfiles.profile === item.profile || containsMouse

            Rectangle {
                implicitHeight: Math.max(200, root.max_height)

                radius: Constants.radius
                color: Constants.battery_color_background

                border.width: 1
                border.color: (enabled && item.active) ? item.accent : Constants.battery_color_border

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
                        styles.icon_color_idle: Constants.battery_color_ink_muted
                        styles.icon_color_active: item.accent
                    }

                    StyledText {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.bold: true
                        font.pixelSize: Constants.font_size_lg
                        horizontalAlignment: Text.AlignHCenter
                        text: item.title
                        styles.color_idle: Constants.battery_color_ink_muted
                        styles.color_active: item.accent
                        active: item.active
                    }

                    StyledText {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        text: item.desc
                        styles.color_idle: Qt.alpha(Constants.battery_color_ink_muted, 0.75)
                        styles.color_active: Constants.battery_color_ink_default
                        active: item.active
                    }
                }

            }

            onClicked: {
                if (PowerProfiles.profile !== item.profile) {
                    PowerProfiles.profile = item.profile;
                }
            }
        }
    }
}