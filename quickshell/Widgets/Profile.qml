import QtQuick
import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Utilities
import qs.Style

WidgetBase {
    id: powerWidget

    // Icons
    readonly property var iconMap: ({
        [PowerProfile.PowerSaver]:  "",
        [PowerProfile.Balanced]:    "",
        [PowerProfile.Performance]: ""
    })

    // Colors
    readonly property var colorMap: ({
        [PowerProfile.PowerSaver]:  Theme.color_green,
        [PowerProfile.Balanced]:    Theme.color_yellow,
        [PowerProfile.Performance]: Theme.color_red
    })

    // Bind directly to the service
    property var currentProfile: PowerProfiles.profile

    // Live bindings: these re‑evaluate whenever currentProfile changes
    icon: iconMap[currentProfile]
    style.foreground.idle: colorMap[currentProfile]
    style.background.hover: style.foreground.idle
    style.background.active: style.foreground.idle

    // Rotate profiles on click
    onClicked: {
        switch (currentProfile) {
        case PowerProfile.PowerSaver:
            PowerProfiles.profile = PowerProfile.Balanced
            break
        case PowerProfile.Balanced:
            PowerProfiles.profile = PowerProfiles.hasPerformanceProfile
                ? PowerProfile.Performance
                : PowerProfile.PowerSaver
            break
        case PowerProfile.Performance:
            PowerProfiles.profile = PowerProfile.PowerSaver
            break
        }
    }

    // Shared styles
    style.border.hover: Theme.color_dark
    style.foreground.hover: Theme.color_dark
    style.border.active: Theme.color_dark
    style.foreground.active: Theme.color_dark
}
