pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Styles
import qs.Controls

RowLayout {
    id: root
    spacing: 24

    readonly property var profileMap: [
        { icon: "", label: "Performance", color: Style.colors.red, target: PowerProfile.Performance },
        { icon: "", label: "Balanced", color: Style.colors.yellow, target: PowerProfile.Balanced },
        { icon: "", label: "Power Saver", color: Style.colors.green, target: PowerProfile.PowerSaver }
    ]

    readonly property var activeProfile: profileMap[PowerProfiles.profile]

    Column {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            text: "Profile"
            font.pixelSize: 14
            color: Style.colors.text
            opacity: 0.6
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            text: root.activeProfile.label
            font.pixelSize: 16
            color: Style.colors.text
        }
    }

    Row {
        spacing: 8
        Repeater {
            model: root.profileMap

            delegate: Clickable {
                id: button
                Layout.alignment: Qt.AlignVCenter

                required property var modelData
                readonly property bool isActive: PowerProfiles.profile === modelData.target

                // Simplify style logic: if active, it stays its color even when idled
                colors.background.idle: isActive ? modelData.color : Style.colors.slate
                colors.border.idle:     isActive ? modelData.color : Style.colors.wayborder
                
                colors.background.active: modelData.color
                colors.border.active:     modelData.color

                StyledText {
                    anchors.centerIn: parent
                    text: modelData.icon
                    color: (isActive || button.containsMouse) ? Style.colors.base : Style.colors.text
                }
                onClicked: PowerProfiles.profile = modelData.target
            }
        }
    }
}