pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

import qs
import qs.Services

Singleton {
    id: dataprovider
    
    readonly property QtObject process: QtObject {
        property var prevent_lock: null
        property var shutdown: null
    }

    readonly property QtObject stopwatch: QtObject {
        property var scan_networks: null
    }

    readonly property QtObject battery: QtObject {
        readonly property int critical_threshold: 20
        readonly property int warning_threshold: 30
    }
}