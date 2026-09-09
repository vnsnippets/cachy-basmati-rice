pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int brightness: 0

    // Query current brightness level
    property Process _getProc: Process {
        command: ["brightnessctl", "-m"]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.split(",");
                if (parts.length >= 4) {
                    const pct = parseInt(parts[3]);
                    if (!isNaN(pct)) root.brightness = pct;
                }
            }
        }
    }

    // Stream udev backlight events continuously
    property Process _udevProc: Process {
        command: ["udevadm", "monitor", "--subsystem-match=backlight"]
        running: true
        stdout: SplitParser {
            onRead: () => root._getProc.running = true
        }
    }

    function setBrightness(value) {
        const target = Math.max(0, Math.min(100, Math.round(value)));
        _setProc.command = ["brightnessctl", "set", `${target}%`];
        _setProc.running = true;
    }

    property Process _setProc: Process {
        command: []
    }

    Component.onCompleted: _getProc.running = true
}