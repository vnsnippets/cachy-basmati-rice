import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.Services

Base {
    id: widget
    icon: ""

    // Style: Idle
    style.foreground.idle: Theme.color_red

    // Style: Active
    style.background.active: Theme.color_red
    style.foreground.active: Theme.color_dark
    style.border.active: Theme.color_red

    onClicked: () => {
        var cmd = ["poweroff"]
        Global.process.shutdown = Daemon.execute(cmd);
    }
}