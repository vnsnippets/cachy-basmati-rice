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
            id: brightnessIcon
            size: Constants.toast_icon_size
            iconname: "brightness.svg"
            styles.icon_color_idle: Constants.display_control_color_ink_default
            styles.icon_color_active: Constants.display_control_color_ink_active
        }
        
        StyledSlider {
            id: slide
            Layout.fillWidth: true
            property bool active: false

            property bool _initializing: true

            from: 0; to: 100
            stepSize: 5

            styles.track_color: control.styles.track_color
            styles.accent_color: control.styles.accent_color
            size: 12

            value: 0

            NumberAnimation on value {
                id: startupAnimation
                from: 0
                to: BacklightService.brightness ?? 0
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
                target: BacklightService
                function onBrightnessChanged() {
                    if (!slide.pressed && !slide._initializing) {
                        slide.value = BacklightService.brightness;
                    }
                }
            }

            onValueChanged: {
                if (!_initializing && BacklightService.brightness !== value) {
                    BacklightService.set(value);
                }
            }
        }

        StyledText {
            id: label
            visible: opacity > 0
            Layout.alignment: Qt.AlignVCenter
            text: Math.round(slide.value) + "%"
            color: Constants.display_control_color_ink_default
            Behavior on opacity { NumberAnimation { duration: control._animationDuration } }
        }
    }
}