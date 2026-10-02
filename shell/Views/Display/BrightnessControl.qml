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

    component Styles: QtObject {
        property color border_color: "transparent"
        property color background_color: "transparent"
        property color track_color: "transparent"
        property color accent_color: "transparent"
    }
    
    property Styles styles: Styles {}

    color: styles.background_color
    border.color:  styles.border_color

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
            styles.icon_color_idle: Constants.display_control_color_icon
            styles.icon_color_active: Constants.display_control_color_icon_active
        }
        
        StyledSlider {
            id: slide
            Layout.fillWidth: true
            property bool active: false

            from: 0; to: 100;
            stepSize: 5

            styles.track_color: control.styles.track_color
            styles.accent_color: control.styles.accent_color
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
            color: Constants.display_control_color_text
            Behavior on opacity { NumberAnimation { duration: control._animationDuration } }
        }
    }
}