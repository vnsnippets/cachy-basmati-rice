import QtQuick

import Quickshell
import Quickshell.Widgets

import qs.Views
import qs.Services
import qs.Utilities
import qs.Components

WrapperMouseArea {
    id: root

    property int animduration: 250

    // --- OSD State ---
    property bool osdactive: true
    property bool isready: false

    required property ShellScreen screen

    implicitWidth: Styles.audio.osd.width
    implicitHeight: volumecontrol.implicitHeight

    // Keep OSD active for a few seconds after last volume change
    Timer {
        id: osdtimer
        interval: Styles.audio.osd.activetimeout
        onTriggered: root.osdactive = false;
    }

    Connections {
        target: EventOrchestrator
        function onOsdTimeoutEvent(targetscreen) {
            if (targetscreen === root.screen) {
                root.osdactive = true;
                osdtimer.restart();
            }
        }
    }

    // Pause timer if mouse is hovering over the OSD
    onContainsMouseChanged: {
        if (root.containsMouse) osdtimer.stop();
        else if (root.osdactive) osdtimer.restart();
    }

    // Force dismiss on click
    onClicked: {
        if (osdactive) {
            osdtimer.stop();
            root.osdactive = false;
        }
    }

    // --- Animation Setup ---
    // Start at full visibility layout constraints; the state machine will handle transitions smoothly
    opacity: 0
    anchors.bottomMargin: -root.implicitHeight

    states: [
        State {
            name: "visible"
            when: root.osdactive
            
            PropertyChanges { 
                target: root
                opacity: 1
                anchors.bottomMargin: Styles.audio.osd.offsetvertical
            } 
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "visible"
            NumberAnimation { 
                properties: "opacity, anchors.bottomMargin"
                duration: root.animduration
                easing.type: Easing.OutCubic
            }
        },
        Transition {
            from: "visible"
            to: "*"
            
            // This safely drives the unmount loop only AFTER the animation completes
            NumberAnimation { 
                properties: "opacity, anchors.bottomMargin"
                duration: root.animduration
                easing.type: Easing.InCubic
            }
            
            onRunningChanged: {
                if (!running && !root.osdactive) {
                    EventOrchestrator.osdCloseEvent(root.screen);
                }
            }
        }
    ]

    AudioVolumeControl { 
        id: volumecontrol
        hidesettings: true
        color: Styles.audio.osd.background.idle
        radius: Styles.radius
        border.width: 1
        border.color: Styles.audio.osd.border.idle

        Behavior on scale { NumberAnimation { duration: root.animduration/2; } }
    }

    Component.onCompleted: {
        if (root.osdactive) osdtimer.restart();
    }


    hoverEnabled: true
    cursorShape: this.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

    onPressed: volumecontrol.scale = 0.98
    onReleased: volumecontrol.scale = 1.0
}