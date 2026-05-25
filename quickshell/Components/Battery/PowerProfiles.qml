import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

import qs.Assets
import qs.Utilities
import qs.Components

RowLayout {
    id: root
    spacing: Style.spacing * 3

    // --- Profile Configuration Map ---
    // Links Quickshell profiles to descriptive strings, icons, and Catppuccin accent colors
    readonly property var profileMap: ({
        [PowerProfile.PowerSaver]: {
            title: "Power Saver",
            desc: "Optimal Battery",
            icon: "󰌪",
            accent: Style.colors.green
        },
        [PowerProfile.Balanced]: {
            title: "Balanced",
            desc: "Default Profile",
            icon: "󰗑",
            accent: Style.colors.blue
        },
        [PowerProfile.Performance]: {
            title: "Performance",
            desc: "Bankai Processing",
            icon: "󰓅",
            accent: Style.colors.red
        }
    })

    // Inline Card Component for individual profile entries
    component ProfileCard : Clickable {
        id: card
        Layout.fillWidth: true
        Layout.fillHeight: true
        implicitHeight: 200
        
        property int profileEnum: -1
        readonly property var dataModel: root.profileMap[profileEnum]
        readonly property bool isActive: PowerProfiles.profile === profileEnum

        radius: Style.radius
        enabled: !isActive

        colors.background.idle: Qt.alpha(Style.colors.surface, 0.40)
        colors.background.active: Qt.alpha(Style.colors.surface, 0.65)
        
        colors.border.idle: (isActive) ? dataModel.accent : Qt.alpha(Style.colors.surface, 0.40)
        colors.border.active: Style.colors.overlay

        onClicked: {
            if (PowerProfiles.profile !== profileEnum) {
                PowerProfiles.profile = profileEnum;
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.padding*2
            spacing: Style.spacing

            // Big Icon Indicator
            StyledText {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillHeight: true
                font.pixelSize: 48
                text: card.dataModel.icon
                style.idle: card.isActive ? card.dataModel.accent : Style.colors.subtext;
                style.active: card.dataModel.accent
                active: card.containsMouse
            }

            // Profile Title Text
            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                font.bold: true
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                text: card.dataModel.title
                style.idle: card.isActive ? card.dataModel.accent : Style.colors.subtext
                style.active: card.dataModel.accent
                active: card.containsMouse
            }

            // Descriptive Subtext
            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                maximumLineCount: 2
                text: card.dataModel.desc
                style.idle: Style.colors.overlay
                style.active: Style.colors.subtext
                active: card.containsMouse
            }
        }
    }

    // --- Render Deck ---
    // Repeats the custom cards cleanly for all three supported backend configurations
    ProfileCard { profileEnum: PowerProfile.PowerSaver }
    ProfileCard { profileEnum: PowerProfile.Balanced }
    ProfileCard { profileEnum: PowerProfile.Performance }
}