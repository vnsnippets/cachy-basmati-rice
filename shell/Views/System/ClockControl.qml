import QtQuick
import QtQuick.Layouts

import qs
import qs.Utilities
import qs.Components

ColumnLayout {
    id: content
    spacing: 0
    
    StyledText {
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: Constants.clock_color_subtext
        text: Qt.formatDateTime(Daemon.clock.date, "dddd")
    }

    StyledText {
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: Constants.clock_color_text
        text: Qt.formatDateTime(Daemon.clock.date, "yyyy-MM-dd HH:mm")
    }
}