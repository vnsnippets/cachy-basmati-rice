import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.Pipewire

import qs.Styles
import qs.Controls

Rectangle {
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
            text: "\ueb4e"
        }

        SliderControl {
            id: slider
            property bool changeLock: false

            Layout.fillWidth: true

            // anchors.centerIn: parent

            implicitWidth: width
            activeColor: Style.colors.green
            handleColor: Style.colors.green
            handleBorderColor: Style.colors.green
            trackColor: Qt.alpha(Style.colors.text, 0.1)
            trackHeight: 12
            value: Pipewire?.defaultAudioSink?.audio?.volume ?? 0

            onValueChanged: {
                if (slider.changeLock) return;
                slider.changeLock = true
                Pipewire.defaultAudioSink.audio.volume = value
                throttle.restart();
            }

            Timer {
                id: throttle
                interval: 50 
                onTriggered: slider.changeLock = false
            }
        }
    }
}