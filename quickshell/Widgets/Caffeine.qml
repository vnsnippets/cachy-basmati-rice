import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.Utilities
import qs.Services

WidgetBase {
    id: widget

    readonly property bool active: StateProvider.caffeine.inhibitProcess !== null

    // (Active: True)   - Caffeine active (System won't lock)
    // (Active: False)  - Auto-lock is active (System will lock)
    icon: (active) ? "" : ""
    label: (active) ? `[${StateProvider.caffeine.inhibitProcess.processId}]` : ""
    style.foreground.idle: (active) ? Theme.color_red : Theme.color_green
    
    onClicked: () => {
        if (active) {
            StateProvider.caffeine.inhibitProcess.running = false;
            StateProvider.caffeine.inhibitProcess = null;
        } else {
            // Start and save the reference
            StateProvider.caffeine.inhibitProcess = Command.execute(["systemd-inhibit", "--what=idle", "sleep", "infinity"]);

            // Process dies unexpectedly (crashes), reset our state
            StateProvider.caffeine.inhibitProcess.runningChanged.connect(() => {
                if (StateProvider.caffeine.inhibitProcess && !StateProvider.caffeine.inhibitProcess.running) {
                    StateProvider.caffeine.inhibitProcess.running = false;
                    StateProvider.caffeine.inhibitProcess = null;
                }
            });
        }
    }
}