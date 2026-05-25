import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Services.Pipewire

import qs.Assets
import qs.Services
import qs.Components

Rectangle {
    id: root
    
    signal settingsClicked()

    clip: true
    implicitHeight: Style.clickable.dimensions.height

    Timer {
        id: changeCooldown
        running: false
        interval: 1000
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Style.padding
        anchors.rightMargin: Style.padding
        spacing: Style.spacing * 2

        Clickable {
            Layout.alignment: Qt.AlignVCenter
            
            implicitWidth: volume.width
            implicitHeight: volume.height

            borderWidth: 0
            colors.background.idle: "transparent"
            colors.background.active: "transparent"

            StyledText {
                id: volume
                readonly property int volumeAsPercent: Math.round((PipewireService.defaultSink?.audio.volume * 100) / 5) * 5
                text: (PipewireService.defaultSink?.audio.muted ?? false) ? "" : changeCooldown.running ? volumeAsPercent : ""
            }

            onClicked: PipewireService.defaultSink.audio.muted = !PipewireService.defaultSink?.audio.muted
        }

        SliderControl {
            id: slider
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            from: 0; to: 100;
            stepSize: 5
            snapMode: Slider.SnapAlways

            implicitWidth: width
            activeColor: Style.colors.green
            handleColor: Style.colors.green
            handleBorderColor: Style.colors.green
            trackColor: Qt.alpha(Style.colors.text, 0.1)
            trackHeight: 12
            value: PipewireService.defaultSink?.audio?.volume * 100 ?? 0

            onValueChanged: {
                if (PipewireService.defaultSink?.audio) {
                    PipewireService.defaultSink.audio.volume = value/100
                    changeCooldown.restart();
                }
            }
        }

        Clickable {
            Layout.alignment: Qt.AlignVCenter

            implicitWidth: settings.width
            implicitHeight: settings.height

            borderWidth: 0
            colors.background.idle: "transparent"
            colors.background.active: "transparent"

            StyledText {
                id: settings
                text: ""
            }

            onClicked: settingsClicked()
        }
    }
}