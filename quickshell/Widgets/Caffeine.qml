import QtQuick

import Quickshell
import Quickshell.Io

import qs
import qs.Services

Base {
    id: container

    readonly property bool active: Global.process.prevent_lock !== null

    // (Active: True)   - Caffeine active (System won't lock)
    // (Active: False)  - Auto-lock is active (System will lock)
    icon: (active) ? "" : ""
    label: (active) ? `[${Global.process.prevent_lock.processId}]` : ""
    style.foreground.idle: (active) ? Theme.color_red : Theme.color_green
    
    onClicked: () => {
        if (active) {
            Global.process.prevent_lock.running = false;
            Global.process.prevent_lock = null;
        } else {
            // Start and save the reference
            var cmd = ["systemd-inhibit", "--what=idle", "sleep", "infinity"]
            Global.process.prevent_lock = Daemon.execute(cmd);

            // Process dies unexpectedly (crashes), reset our state
            Global.process.prevent_lock.runningChanged.connect(() => {
                if (Global.process.prevent_lock && !Global.process.prevent_lock.running) {
                    Global.process.prevent_lock.running = false;
                    Global.process.prevent_lock = null;
                }
            });
        }
    }
}