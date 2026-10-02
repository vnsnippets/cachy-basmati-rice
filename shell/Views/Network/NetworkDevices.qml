pragma ComponentBehavior: Bound

import QtQuick

import qs.Types
import qs.Layouts
import qs.Views.Power
import qs.Views.Battery

ContentTabContainer {
    tabs: [
        TabItem {
            label: "Display"
            content: PowerOptions { max_height: 160; }
        },
        TabItem {
            label: "Audio"
            content: BatteryProfiles { max_height: 160 }
        }
    ]
}