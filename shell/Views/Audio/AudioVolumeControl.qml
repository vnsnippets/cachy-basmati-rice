// pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs
import qs.Services
import qs.Components

Rectangle {
    id: control
    implicitHeight: content.implicitHeight + (Constants.padding * 2)
    readonly property int _animationDuration: Constants.animation_duration

    component ColorStyles: QtObject {
        property color border: "transparent"
        property color background: "transparent"
        property color track: "transparent"
        property color accent: "transparent"
    }
    
    property ColorStyles colors: ColorStyles {}

    color: colors.background
    border.color:  colors.border

    RowLayout {
        id: content

        spacing: Constants.spacing
        anchors.fill: parent
        anchors.leftMargin: Constants.padding
        anchors.rightMargin: Constants.padding
        anchors.verticalCenter: parent.verticalCenter

        Timer { id: changeCooldown; running: false; interval: 1000 }

        ClickableWithIcon {
            id: mutetoggle
            size: Constants.osd_icon_size
            iconname: {
                if (PipewireService.defaultSink?.audio.muted) return "volume-muted.svg";

                const volume = PipewireService.defaultSink?.audio.volume;
                if (!volume || volume === 0) return "volume-off.svg";

                const icons = [ "volume-low.svg", "volume-high.svg" ];

                const targetIndex = Math.floor(volume * icons.length);
                const safeIndex = Math.min(Math.max(0, targetIndex), icons.length - 1);

                return icons[safeIndex];
            }
            
            styles.icon.color: [ Constants.color_text, Constants.color_accent ]
            onClicked: PipewireService.defaultSink.audio.muted = !PipewireService.defaultSink?.audio.muted
        }
        
        StyledSlider {
            id: slide
            Layout.fillWidth: true
            property bool active: false

            signal moveCallback

            from: 0; to: 100;
            stepSize: 5

            colors.track: control.colors.track
            colors.accent: control.colors.accent
            size: 12

            value: PipewireService.defaultSink?.audio?.volume * 100 ?? 0
            onValueChanged: {
                if (!PipewireService.defaultSink) return;
                PipewireService.defaultSink.audio.volume = value/100;
                if (slide.moveCallback) slide.moveCallback();
                changeCooldown.restart();
            }
        }

        StyledText {
            id: label
            visible: opacity > 0

            Layout.alignment: Qt.AlignVCenter
            text: Math.round((PipewireService.defaultSink?.audio.volume * 100) / 5) * 5 + "%"
            color: Constants.color_text

            Behavior on opacity { NumberAnimation { duration: control._animationDuration } }
        }
    }
}