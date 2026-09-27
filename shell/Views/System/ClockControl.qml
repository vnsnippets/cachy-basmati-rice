import QtQuick
import QtQuick.Layouts

import qs
import qs.Components

ColumnLayout {
    id: content
    spacing: 2
    
    StyledText {
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: Constants.clock_color_subtext
        text: Qt.formatDateTime(Constants.clock.date, "dddd")
    }

    StyledText {
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: Constants.clock_color_text
        text: Qt.formatDateTime(Constants.clock.date, "yyyy-MM-dd HH:mm")
    }
}