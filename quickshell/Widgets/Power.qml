import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.Utilities

WidgetBase {
    id: volumeWidget
    icon: ""

    // Style: Idle
    style.foreground.idle: Theme.color_red
    
    // Style: Hover
    style.background.hover: Theme.color_red
    style.foreground.hover: Theme.color_dark

    // Style: Active
    style.background.active: Theme.color_red
    style.foreground.active: Theme.color_dark
}