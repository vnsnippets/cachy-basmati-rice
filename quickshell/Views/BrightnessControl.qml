import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Utilities
import qs.Components
import qs.Components.Controls

Rectangle {
    id: root
    implicitHeight: Styles.size

    RowLayout {
        id: row
        spacing: Styles.spacing
        anchors.fill: parent
        anchors.leftMargin: Styles.padding
        anchors.rightMargin: Styles.padding

        ClickableWithIcon {
            id: mutetoggle
            size: Styles.brightness.slide.icon.size
            iconname: "brightness.svg"
            
            enabled: false
            iconstyle.idle: Styles.brightness.slide.icon.color
            iconstyle.active: Styles.brightness.slide.icon.color
        }
        
        SlideControl {
            id: slide
            Layout.fillWidth: true
            property bool active: false

            signal moveCallback

            from: 0; to: 100;
            stepSize: 5

            activeColor: Styles.brightness.slide.track.active
            handleColor: Styles.brightness.slide.track.handle.color
            handleBorderColor: Styles.brightness.slide.track.handle.border
            trackColor: Styles.brightness.slide.track.idle
            trackHeight: Styles.brightness.slide.track.height

            value: 0
            onValueChanged: {
                BrightnessService.set(value)
            }

            Component.onCompleted: BrightnessService.get((e) => slide.value = e)
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            text: (slide.value ?? 0) + "%"
            color: Styles.brightness.slide.text
        }
    }
}