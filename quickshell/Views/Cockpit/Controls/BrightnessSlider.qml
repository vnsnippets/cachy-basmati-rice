import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.Styles
import qs.Controls
import qs.Utilities

Rectangle {
    id: root
    radius: Style.panel.radius - 4
    color: Style.panel.widget.background

    clip: true

    width: implicitWidth
    implicitHeight: Style.clickable.dimensions.height
    
    RowLayout {
        id: sliderLayout
        anchors.centerIn: parent
        implicitWidth: parent.width - Style.panel.padding * 2

        StyledText {
            Layout.fillWidth: false
            Layout.fillHeight: true
            text: "\uE20A"
        }

        SliderControl {
            id: slider
            from: 0; to: 100;
            property bool changeLock: true

            Layout.fillWidth: true
            implicitWidth: width

            activeColor: Style.colors.green
            handleColor: Style.colors.green
            handleBorderColor: Style.colors.green
            trackColor: Qt.alpha(Style.colors.text, 0.1)
            trackHeight: 12

            onValueChanged: {
                if (slider.changeLock) return;
                slider.changeLock = true;
                Daemon.execute(["brightnessctl", "set", value + "%"], () => slider.changeLock = false)
            }

            Component.onCompleted: {
                Daemon.execute(["sh", "-c", "brightnessctl -m | cut -d, -f4 | tr -d %"], (e) => {
                    slider.value = parseFloat(e?.output?.trim());
                })
                slider.changeLock = false;
            }
        }
    }
}