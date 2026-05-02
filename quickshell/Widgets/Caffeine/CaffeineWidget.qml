import QtQuick

import Quickshell
import Quickshell.Io

import qs
import qs.Styles
import qs.Utilities
import qs.Widgets

Clickable {
    id: root

    readonly property bool active: Context.process.prevent_screen_lock !== null

    property color color_caffeineon: Style.color_red
    property color color_caffeineoff: Style.color_light

    // (Active: True)   - Caffeine active (System won't lock)
    // (Active: False)  - Auto-lock is active (System will lock)
    icon: (active) ? "󱂟" : ""
    label: (active) ? `[${Context.process.prevent_screen_lock.processId}]` : ""
    style.text.idle: (active) ? color_caffeineon : color_caffeineoff
    
    onClicked: () => {
        if (active) {
            Context.process.prevent_screen_lock.running = false;
            Context.process.prevent_screen_lock = null;
        } else {
            // Start and save the reference
            var cmd = ["systemd-inhibit", "--what=idle", "sleep", "infinity"]
            Context.process.prevent_screen_lock = Daemon.execute(cmd);

            // Process dies unexpectedly (crashes), reset our state
            Context.process.prevent_screen_lock.runningChanged.connect(() => {
                if (Context.process.prevent_screen_lock && !Context.process.prevent_screen_lock.running) {
                    Context.process.prevent_screen_lock.running = false;
                    Context.process.prevent_screen_lock = null;
                }
            });
        }
    }
}