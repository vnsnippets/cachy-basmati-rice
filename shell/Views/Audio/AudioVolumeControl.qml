import QtQuick
import QtQuick.Layouts

import qs
import qs.Services
import qs.Utilities
import "../../Components"

Rectangle {
    id: control
    implicitHeight: Constants.size
    readonly property int _animationDuration: Constants.animation_duration
    
    RowLayout {
        spacing: Constants.spacing
        anchors.fill: parent
        anchors.leftMargin: Constants.padding
        anchors.rightMargin: Constants.padding

        Timer { id: changeCooldown; running: false; interval: 1000 }

        ClickableWithIcon {
            id: mutetoggle
            size: Constants.size - Constants.padding * 2
            iconname: {
                if (PipewireService.defaultSink?.audio.muted) return "volume-muted.svg";

                const volume = PipewireService.defaultSink?.audio.volume;
                if (!volume || volume === 0) return "volume-off.svg";

                const icons = [ "volume-low.svg", "volume-high.svg" ];

                const targetIndex = Math.floor(volume * icons.length);
                const safeIndex = Math.min(Math.max(0, targetIndex), icons.length - 1);

                return icons[safeIndex];
            }
            
            colors.icon.idle: Constants.color_text
            colors.icon.active: Constants.color_accent

            onClicked: PipewireService.defaultSink.audio.muted = !PipewireService.defaultSink?.audio.muted
        }
        
        StyledSlider {
            id: slide
            Layout.fillWidth: true
            property bool active: false

            signal moveCallback

            from: 0; to: 100;
            stepSize: 5

            colors.track: Constants.color_muted
            colors.accent: Constants.color_accent
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
            colors.idle: Constants.color_text
            colors.active: Constants.color_text

            Behavior on opacity { NumberAnimation { duration: control._animationDuration } }
        }

        // ClickableWithIcon {
        //     opacity: (label.visible) ? 0 : 1
        //     visible: opacity > 0
        //     size: Constants.size - Constants.padding * 2
        //     iconname: "settings.svg"
        //     colors.icon.idle: Constants.color_text
        //     colors.icon.active: Constants.color_accent

        //     onClicked: control.settingsClicked();

        //     Behavior on opacity {
        //         NumberAnimation { duration: root.animduration }
        //     }
        // }
    }
}