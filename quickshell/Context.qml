pragma Singleton

import QtQuick
import Quickshell

import qs.Utilities

Singleton {
    readonly property QtObject battery: QtObject {
        readonly property int criticalLimit: 20
        readonly property int warningLimit: 30
    }

    readonly property QtObject networks: QtObject {
        readonly property int criticalLimit: 20
        readonly property int degradedLimit: 60

        readonly property QtObject stopwatch: QtObject {
            property var scan: Stopwatch.create(this, false, false)
        }
    }

    readonly property SystemClock clock: SystemClock {
        precision: SystemClock.Minutes
    }

    // Standalone processes
    property var keepAwakeProcess: null
}