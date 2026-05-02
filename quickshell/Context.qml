pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: dataprovider
    
    readonly property QtObject process: QtObject {
        property var prevent_screen_lock: null
        property var shutdown: null
    }

    readonly property QtObject stopwatch: QtObject {
        property var scan_networks: null
    }

    readonly property QtObject battery: QtObject {
        readonly property int criticalLimit: 20
        readonly property int warningLimit: 30
    }
}