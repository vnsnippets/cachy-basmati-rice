import QtQuick
import Quickshell

import qs
import qs.Utilities

WidgetBase {
    id: clockWidget

    style.foreground.idle: Theme.color_light
    style.border.idle: Theme.color_slate

    property int interval: 1000
    property string format: "yyyy-MM-dd HH:mm:ss"
    property string tooltipformat: "D dd MMMyyyy-MM-dd HH:mm:ss"

    function ordinalDay(day) {
        if (day % 10 === 1 && day % 100 !== 11) return day + "st";
        if (day % 10 === 2 && day % 100 !== 12) return day + "nd";
        if (day % 10 === 3 && day % 100 !== 13) return day + "rd";
        return day + "th";
    }

    label: Qt.formatDateTime(new Date(), format)
    tooltip: Qt.formatDate(new Date(), "MMMM") + " " + ordinalDay(new Date()) + ", " + Qt.formatDate(new Date(), "yyyy");
        
    Timer {
        interval: interval; running: true; repeat: true
        onTriggered: () => {
            const d = new Date()
            clockWidget.label = Qt.formatDateTime(d, format)
            clockWidget.tooltip = Qt.formatDate(d, "MMMM") + " " + ordinalDay(new Date()) + ", " + Qt.formatDate(d, "yyyy");

        }
    }
}