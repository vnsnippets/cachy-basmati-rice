import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Styles
import qs.Widgets

RowLayout {
    id: root
    spacing: 8

    readonly property var profileMap: [
        { icon: "", label: "Performance", color: Style.color_red, target: PowerProfile.Performance },
        { icon: "", label: "Balanced", color: Style.color_yellow, target: PowerProfile.Balanced },
        { icon: "", label: "Power Saver", color: Style.color_green, target: PowerProfile.PowerSaver }
    ]

    readonly property var activeProfile: profileMap[PowerProfiles.profile]

    Column {
        Layout.fillWidth: true

        Text {
            text: "Profile"
            font.pixelSize: 14
            color: Style.color_light
            opacity: 0.6
        }

        Text {
            text: root.activeProfile.label
            font.pixelSize: 16
            color: Style.color_light
        }
    }

    Repeater {
        model: root.profileMap

        delegate: Clickable {
            required property var modelData
            readonly property bool isActive: PowerProfiles.profile === modelData.target

            // Simplify style logic: if active, it stays its color even when idled
            style.background.idle: isActive ? modelData.color : Style.popup.button.background.idle
            style.text.idle:       isActive ? Style.color_dark : Style.color_light
            style.border.idle:     isActive ? modelData.color : Style.color_light
            
            style.background.active: modelData.color
            style.text.active:       Style.color_dark
            style.border.active:     modelData.color

            icon: modelData.icon
            onClicked: PowerProfiles.profile = modelData.target
        }
    }
}