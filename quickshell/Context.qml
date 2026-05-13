pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

import qs.Utilities

Singleton {
    id: dataprovider
    
    readonly property QtObject process: QtObject {
        property var prevent_screen_lock: null
        property var shutdown: null
    }

    readonly property QtObject stopwatch: QtObject {
        property var scan_networks: Stopwatch.create(this, false, false)
    }

    readonly property QtObject battery: QtObject {
        readonly property int criticalLimit: 20
        readonly property int warningLimit: 30

        readonly property QtObject stopwatch: QtObject {
            property var scan: Stopwatch.create(this, false, false)
        }
    }

    readonly property QtObject network: QtObject {
        readonly property int criticalLimit: 20
        readonly property int degradedLimit: 60
    }

    readonly property SystemClock clock: SystemClock {
        id: system_clock
        precision: SystemClock.Minutes
    }
}