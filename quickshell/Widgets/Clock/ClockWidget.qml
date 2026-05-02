import QtQuick
import Quickshell

import qs
import qs.Styles
import qs.Utilities
import qs.Widgets

Clickable {
    id: root
    readonly property Component popup: ClockPopup {}
    property string format: "yyyy-MM-dd HH:mm"

    SystemClock {
        id: system_clock
        precision: SystemClock.Minutes
    }

    label: Qt.formatDateTime(system_clock.date, format)

    onClicked: canvas.handleWidgetPopup(this);
}