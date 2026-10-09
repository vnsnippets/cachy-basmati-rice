pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs
import qs.Services
import qs.Components

Rectangle {
    id: control
    implicitHeight: content.implicitHeight + (Constants.padding * 2)
    readonly property int _animationDuration: Constants.animation_duration

    component Styles: QtObject {
        property color border_color: "transparent"
        property color background_color: "transparent"
        property color track_color: "transparent"
        property color accent_color: "transparent"
    }
    
    property Styles styles: Styles {}

    color: styles.background_color
    border.color: styles.border_color

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
            size: Constants.toast_icon_size
            iconname: {
                if (PipewireService.defaultSink?.audio.muted) return "volume-muted.svg";

                const volume = PipewireService.defaultSink?.audio.volume;
                if (!volume || volume === 0) return "volume-off.svg";

                const icons = [ "volume-low.svg", "volume-high.svg" ];

                const targetIndex = Math.floor(volume * icons.length);
                const safeIndex = Math.min(Math.max(0, targetIndex), icons.length - 1);

                return icons[safeIndex];
            }
            
            styles.icon_color_idle: Constants.volume_control_color_ink_default
            styles.icon_color_active: Constants.volume_control_color_ink_active

            onClicked: PipewireService.defaultSink.audio.muted = !PipewireService.defaultSink?.audio.muted
        }
        
        StyledSlider {
            id: slide
            Layout.fillWidth: true
            property bool active: false
            property bool _initializing: true

            signal moveCallback

            from: 0; to: 100
            stepSize: 5

            styles.track_color: control.styles.track_color
            styles.accent_color: (PipewireService.defaultSink.audio.muted) ? 
                Qt.alpha(control.styles.accent_color, 0.25) : control.styles.accent_color
                
            size: 12

            value: 0

            NumberAnimation on value {
                id: startupAnimation
                from: 0
                to: (PipewireService.defaultSink?.audio?.volume ?? 0) * 100
                duration: control._animationDuration
                easing.type: Easing.OutCubic
                running: false

                onFinished: {
                    slide._initializing = false;
                }
            }

            Component.onCompleted: {
                startupAnimation.start();
            }

            Connections {
                target: PipewireService.defaultSink?.audio ?? null
                function onVolumeChanged() {
                    if (!slide.pressed && !slide._initializing) {
                        slide.value = (PipewireService.defaultSink?.audio?.volume ?? 0) * 100;
                    }
                }
            }

            onValueChanged: {
                if (!_initializing && PipewireService.defaultSink) {
                    PipewireService.defaultSink.audio.volume = value / 100;
                    if (slide.moveCallback) slide.moveCallback();
                    changeCooldown.restart();
                }
            }
        }

        StyledText {
            id: label
            visible: opacity > 0

            Layout.alignment: Qt.AlignVCenter
            text: Math.round(slide.value) + "%"
            color: Constants.volume_control_color_ink_default

            Behavior on opacity { NumberAnimation { duration: control._animationDuration } }
        }
    }
}