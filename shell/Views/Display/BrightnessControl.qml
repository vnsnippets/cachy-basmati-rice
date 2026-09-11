import QtQuick
import QtQuick.Layouts

import qs
import qs.Services
import "../../Components"

Rectangle {
    id: control
    implicitHeight: content.implicitHeight + (Constants.padding * 2)
    readonly property int _animationDuration: Constants.animation_duration

    RowLayout {
        id: content

        spacing: Constants.spacing
        anchors.fill: parent
        anchors.leftMargin: Constants.padding
        anchors.rightMargin: Constants.padding

        ClickableWithIcon {
            id: brightnessIcon
            size: Constants.size - Constants.padding * 2
            iconname: "brightness.svg"
            styles.icon.color.idle: Constants.color_text
            styles.icon.color.active: Constants.color_accent
        }

        StyledSlider {
            id: slide
            Layout.fillWidth: true

            from: 0
            to: 100
            stepSize: 5

            colors.track: Constants.color_muted
            colors.accent: Constants.color_accent
            size: 12

            value: BacklightService.brightness ?? 0
            onValueChanged: {
                if (BacklightService.brightness !== value) {
                    BacklightService.set(value);
                }
            }
        }

        StyledText {
            id: label
            visible: opacity > 0

            Layout.alignment: Qt.AlignVCenter
            text: Math.round(BacklightService.brightness ?? 0) + "%"
            colors.idle: Constants.color_text
            colors.active: Constants.color_text

            Behavior on opacity { 
                NumberAnimation { duration: control._animationDuration } 
            }
        }
    }
}