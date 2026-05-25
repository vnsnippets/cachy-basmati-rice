import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs.Assets
import qs.Components
import qs.Utilities

Rectangle {
    id: root
    clip: true

    implicitHeight: Style.clickable.dimensions.height
    
    Timer {
        id: changeCooldown
        running: false
        interval: 1000
    }

    RowLayout {
        id: sliderLayout
        anchors.fill: parent
        anchors.leftMargin: Style.padding
        anchors.rightMargin: Style.padding

        StyledText {
            rightPadding: Style.spacing

            readonly property int sliderValueAsPercent: slider.value
            text: changeCooldown.running ? sliderValueAsPercent : ""
        }

        SliderControl {
            id: slider
            from: 0; to: 100;
            stepSize: 5
            snapMode: Slider.SnapAlways
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
                changeCooldown.restart();
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