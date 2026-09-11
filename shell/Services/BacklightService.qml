pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

import Quickshell
import Quickshell.Io

import qs.Utilities

Singleton {
    id: service

    property int brightness: 0
    property bool _busy: false

    // Debounce slider drags so process spawns after movement pauses
    property Timer debounce: Timer {
        interval: 50
        repeat: false
        property int pendingValue: 0
        onTriggered: service.apply(pendingValue)
    }

    // Lock release timer to swallow echo events right after a change
    property Timer release: Timer {
        interval: 150
        repeat: false
        onTriggered: service._busy = false
    }

    function set(value) {
        debounce.pendingValue = value;
        debounce.restart();
    }

    function apply(value) {
        service._busy = true;
        const target = Math.max(0, Math.min(100, Math.round(value)));

        Daemon.execute(["brightnessctl", "set", `${target}%`], () => {
            // Update value locally first, then release the lock shortly after
            service.brightness = target;
            service.release.restart();
        });
    }

    function sync() {
        // Ignore incoming udev events while actively setting brightness
        if (service._busy) return;

        Daemon.execute(["brightnessctl", "-m"], (res) => {
            if (!res.success || service._busy) return;

            const parts = res.output.split(",");
            if (parts.length >= 4) {
                const pct = parseInt(parts[3]);
                if (!isNaN(pct)) service.brightness = pct;
            }
        });
    }

    property Process _udevProc: Process {
        command: ["udevadm", "monitor", "--subsystem-match=backlight"]
        running: true
        stdout: SplitParser {
            onRead: () => service.sync()
        }
    }

    Component.onCompleted: service.sync()
}