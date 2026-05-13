import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs
import qs.Styles
import qs.Controls
import qs.Utilities

RowLayout {
    id: root
    spacing: 10

    Text {
        text: ""
        color: Style.colors.text
        font.pixelSize: 20
    }
    
    SliderControl {
        id: slider
        Layout.fillWidth: true

        activeColor: Style.colors.blue
        handleColor: Style.colors.text
        handleBorderColor: Style.colors.blue
        trackColor: Style.colors.surface
        trackHeight: 20

        Component.onCompleted: {
            Daemon.execute(["sh", "-c", "brightnessctl -m | cut -d, -f4 | tr -d %"], (e) => {
                slider.value = parseFloat(e?.output?.trim()) / 100;
            })
        }
    }
}