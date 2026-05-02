import QtQuick
import QtQuick.Layouts

import Quickshell

import qs
import qs.Styles
import qs.Widgets

Popup {
    id: root
    ColumnLayout {
        anchors.centerIn: parent
        Text {
            text: "Hello World from clock"
            color: Style.color_light
            font.family: Style.fonts.family
            font.pixelSize: Style.fonts.size
        }
    }
}