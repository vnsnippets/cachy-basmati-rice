import QtQuick
import Quickshell

import "../Utilities"

Pill {
    property int interval: 1000
    property string format: "yyyy-MM-dd HH:mm:ss"

    id: clockPill
    labelText: Qt.formatDateTime(new Date(), format)
    tooltipText: Qt.formatDateTime(new Date(), format)
    // iconText: ""
        
    Timer {
        interval: interval; running: true; repeat: true
        onTriggered: () => {
            clockPill.labelText = Qt.formatDateTime(new Date(), format)
            clockPill.tooltipText = Qt.formatDateTime(new Date(), format)
        }
    }
}