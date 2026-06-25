pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property SystemClock clock: SystemClock {
        precision: SystemClock.Minutes
    }
}