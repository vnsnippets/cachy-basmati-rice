import QtQuick
import Quickshell

import qs

Base {
    id: container

    property string format: "yyyy-MM-dd HH:mm:ss"

    style.foreground.idle: Theme.color_light
    style.border.idle: Theme.color_slate

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    label: Qt.formatDateTime(clock.date, format)

    // property string tooltipformat: "D dd MMMyyyy-MM-dd HH:mm:ss"

    // function ordinalDay(day) {
    //     if (day % 10 === 1 && day % 100 !== 11) return day + "st";
    //     if (day % 10 === 2 && day % 100 !== 12) return day + "nd";
    //     if (day % 10 === 3 && day % 100 !== 13) return day + "rd";
    //     return day + "th";
    // }

    // tooltip: Qt.formatDate(new Date(), "MMMM") + " " + ordinalDay(new Date()) + ", " + Qt.formatDate(new Date(), "yyyy");
}