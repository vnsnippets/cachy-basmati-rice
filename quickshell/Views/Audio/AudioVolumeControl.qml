import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Utilities
import qs.Components
import qs.Components.Controls

Rectangle {
    id: root
    implicitHeight: Styles.size

    signal settingsClicked;

    readonly property int animduration: 200
    property bool hidesettings: false
    
    RowLayout {
        spacing: Styles.spacing
        anchors.fill: parent
        anchors.leftMargin: Styles.padding
        anchors.rightMargin: Styles.padding

        Timer {
            id: changeCooldown
            running: false
            interval: 1000
        }

        ClickableWithIcon {
            id: mutetoggle
            size: Styles.audio.slide.icon.size
            iconname: {
                if (PipewireService.defaultSink?.audio.muted) return "volume-muted.svg";

                const volume = PipewireService.defaultSink?.audio.volume;
                if (!volume || volume === 0) return "volume-off.svg";

                const icons = [ "volume-low.svg", "volume-high.svg" ];

                const targetIndex = Math.floor(volume * icons.length);
                const safeIndex = Math.min(Math.max(0, targetIndex), icons.length - 1);

                return icons[safeIndex];
            }
            
            iconstyle.idle: Styles.audio.slide.icon.idle
            iconstyle.active: Styles.audio.slide.icon.active

            onClicked: PipewireService.defaultSink.audio.muted = !PipewireService.defaultSink?.audio.muted
        }
        
        SlideControl {
            id: slide
            Layout.fillWidth: true
            property bool active: false

            signal moveCallback

            from: 0; to: 100;
            stepSize: 5

            activeColor: Styles.audio.slide.track.active
            handleColor: Styles.audio.slide.track.handle.color
            handleBorderColor: Styles.audio.slide.track.handle.border
            trackColor: Styles.audio.slide.track.idle
            trackHeight: Styles.audio.slide.track.height

            value: PipewireService.defaultSink?.audio?.volume * 100 ?? 0
            onValueChanged: {
                if (!PipewireService.defaultSink) return;
                PipewireService.defaultSink.audio.volume = value/100;
                if (slide.moveCallback) slide.moveCallback();

                if (!root.hidesettings) changeCooldown.restart();
            }
        }

        StyledText {
            id: percenttext
            opacity: (changeCooldown.running || root.hidesettings) ? 1 : 0
            visible: opacity > 0

            Layout.alignment: Qt.AlignVCenter
            text: Math.round((PipewireService.defaultSink?.audio.volume * 100) / 5) * 5 + "%"
            color: Styles.audio.slide.text

            Behavior on opacity {
                NumberAnimation { duration: root.animduration }
            }
        }

        ClickableWithIcon {
            opacity: (percenttext.visible) ? 0 : 1
            visible: opacity > 0
            size: Styles.audio.slide.icon.size
            iconname: "settings.svg"
            iconstyle.idle: Styles.audio.slide.icon.idle
            iconstyle.active: Styles.audio.slide.icon.active

            onClicked: root.settingsClicked();

            Behavior on opacity {
                NumberAnimation { duration: root.animduration }
            }
        }
    }
}