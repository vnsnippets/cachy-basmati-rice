import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.UPower

import qs.Utilities
import qs.Components

RowLayout {
    id: root
    spacing: Styles.spacing

    property int itemheight: 0
    property int animduration: 250

    Repeater {
        model: [
            {
                title: "Power Saver",
                desc: "Optimal Battery",
                icon: "leaf.svg",
                accent: Styles.colors.green,
                profile: PowerProfile.PowerSaver
            },
            {
                title: "Balanced",
                desc: "Default Profile",
                icon: "balance.svg",
                accent: Styles.colors.blue,
                profile: PowerProfile.Balanced
            },
            {
                title: "Performance",
                desc: "Full Throttle",
                icon: "fire.svg",
                accent: Styles.colors.red,
                profile: PowerProfile.Performance
            }
        ]
        
        delegate: Clickable {
            id: card
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            implicitHeight: Math.max(160, root.itemheight)

            // Create a clean local alias linking to the repeater's array data point
            readonly property var data: modelData
            readonly property bool active: PowerProfiles.profile === data.profile

            radius: Styles.radius
            
            styles.background.idle: Qt.alpha(Styles.colors.surface, 0.40)
            styles.background.active: Qt.alpha(Styles.colors.surface, 0.65)
            styles.border.idle: card.active ? card.data.accent : Qt.alpha(Styles.colors.surface, 0.40)
            styles.border.active: card.data.accent

            onClicked: {
                if (PowerProfiles.profile !== data.profile) {
                    PowerProfiles.profile = data.profile;
                }
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Styles.padding * 2
                spacing: Styles.spacing / 2

                ClickableWithIcon {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.bottomMargin: Styles.padding
                    size: 48
                    padding: 0
                    iconname: card.data.icon
                    enabled: false
                    iconstyle.idle: card.active ? card.data.accent : Styles.colors.subtext;
                    iconstyle.active: card.data.accent
                }

                // Profile Title Text
                StyledText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.bold: true
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    text: card.data.title
                    style.idle: card.active ? card.data.accent : Styles.colors.subtext
                    style.active: card.data.accent
                    active: card.containsMouse
                }

                // Descriptive Subtext
                StyledText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    text: card.data.desc
                    style.idle: Styles.colors.overlay
                    style.active: Styles.colors.subtext
                    active: card.containsMouse
                }
            }
        }
    }
}