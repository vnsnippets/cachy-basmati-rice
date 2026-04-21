pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: dataprovider
    
    property QtObject caffeine: QtObject {
        property var inhibitProcess: null
    }
}