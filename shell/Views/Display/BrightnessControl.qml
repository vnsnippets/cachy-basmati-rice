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
            id: brightnessIcon
            size: Constants.osd_icon_size
            iconname: "brightness.svg"
            styles.icon.color: [ Constants.color_text, Constants.color_text ]
        }
        
        StyledSlider {
            id: slide
            Layout.fillWidth: true
            property bool active: false

            from: 0; to: 100;
            stepSize: 5

            colors.track: control.colors.track
            colors.accent: control.colors.accent
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
            color: Constants.color_text
            Behavior on opacity { NumberAnimation { duration: control._animationDuration } }
        }
    }
}