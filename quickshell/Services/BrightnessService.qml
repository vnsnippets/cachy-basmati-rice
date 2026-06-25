pragma Singleton

import QtQuick
import Quickshell

import qs.Utilities

Singleton {
    id: root
    property bool changeLock: true

    Timer {
        id: changeCooldown
        running: false
        interval: 1000
    }

    function get(callback) {
        Daemon.execute(["sh", "-c", "brightnessctl -m | cut -d, -f4 | tr -d %"], (e) => {
            if (!callback) return;
            const val = parseFloat(e?.output?.trim()) ?? 0;
            Debug.log("Brightness:", val, "%");
            callback(val);
        });
        root.changeLock = false;
    }

    function set(value) {
        if (root.changeLock) return;
        root.changeLock = true;
        Daemon.execute(["brightnessctl", "set", value + "%"], () => root.changeLock = false)
        changeCooldown.restart();
    }
}