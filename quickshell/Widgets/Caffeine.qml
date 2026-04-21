import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.Utilities
import qs.Services

WidgetBase {
    id: widget

    property var inhibitProcess: null
    readonly property bool active: inhibitProcess !== null

    // (Active: True)   - Caffeine active (System won't lock)
    // (Active: False)  - Auto-lock is active (System will lock)
    icon: (active) ? "" : ""
    label: (active) ? `[${inhibitProcess.processId}]` : ""
    style.foreground.idle: (active) ? Theme.color_red : Theme.color_green
    
    onClicked: () => {
        if (active) {
            inhibitProcess.running = false;
            inhibitProcess = null;
        } else {
            // Start and save the reference
            inhibitProcess = Command.execute(["systemd-inhibit", "--what=idle", "sleep", "infinity"]);

            // Process dies unexpectedly (crashes), reset our state
            inhibitProcess.runningChanged.connect(() => {
                if (inhibitProcess && !inhibitProcess.running) {
                    inhibitProcess.running = false;
                    inhibitProcess = null;
                }
            });
        }
    }
}