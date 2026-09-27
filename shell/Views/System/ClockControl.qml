import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Types
import qs.Utilities
import qs.Components

// StyledBox {
//     implicitWidth: content.implicitWidth + (Constants.padding * 2)
//     implicitHeight: content.implicitHeight + (Constants.padding * 2)

ColumnLayout {
    id: content
    spacing: 1
    anchors.verticalCenter: parent.verticalCenter

    StyledText {
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: Qt.alpha(Constants.color_text, 0.75)
        text: Qt.formatDateTime(Constants.clock.date, "dddd")
    }

    StyledText {
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: Constants.color_text
        font.pixelSize: 16
        text: Qt.formatDateTime(Constants.clock.date, "yyyy-MM-dd HH:mm")
    }
}
// }