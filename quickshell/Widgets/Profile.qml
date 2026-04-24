import QtQuick
import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Style

Base {
    id: container

    // Icons
    readonly property var icon_map: ({
        [PowerProfile.PowerSaver]:  "",
        [PowerProfile.Balanced]:    "",
        [PowerProfile.Performance]: ""
    })

    // Colors
    readonly property var color_map: ({
        [PowerProfile.PowerSaver]:  Theme.color_green,
        [PowerProfile.Balanced]:    Theme.color_yellow,
        [PowerProfile.Performance]: Theme.color_red
    })

    // Bind directly to the service
    property var current_profile: PowerProfiles.profile

    // Live bindings: these re‑evaluate whenever current_profile changes
    icon: icon_map[current_profile]
    style.foreground.idle: color_map[current_profile]

    // Rotate profiles on click
    onClicked: {
        switch (current_profile) {
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
}
