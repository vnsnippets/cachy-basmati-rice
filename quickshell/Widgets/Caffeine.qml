import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.Utilities
import qs.Services

WidgetBase {
    id: widget

    property QtObject state: StateProvider.caffeine
    readonly property bool active: state.inhibitProcess !== null

    // (Active: True)   - Caffeine active (System won't lock)
    // (Active: False)  - Auto-lock is active (System will lock)
    icon: (active) ? "" : ""
    label: (active) ? `[${state.inhibitProcess.processId}]` : ""
    style.foreground.idle: (active) ? Theme.color_red : Theme.color_green
    
    onClicked: () => {
        if (active) {
            state.inhibitProcess.running = false;
            state.inhibitProcess = null;
        } else {
            // Start and save the reference
            state.inhibitProcess = Command.execute(["systemd-inhibit", "--what=idle", "sleep", "infinity"]);

            // Process dies unexpectedly (crashes), reset our state
            state.inhibitProcess.runningChanged.connect(() => {
                if (state.inhibitProcess && !state.inhibitProcess.running) {
                    state.inhibitProcess.running = false;
                    state.inhibitProcess = null;
                }
            });
        }
    }
}