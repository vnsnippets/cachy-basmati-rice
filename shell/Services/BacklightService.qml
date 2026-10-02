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

    property Timer debounce: Timer {
        interval: 50
        repeat: false
        property int pendingValue: 0
        onTriggered: service.apply(pendingValue)
    }

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
            service.brightness = target;
            service.release.restart();
        });
    }

    function sync() {
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