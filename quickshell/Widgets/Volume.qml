import QtQuick
import Quickshell
import Quickshell.Io

import "../Utilities"

Pill {
    id: volumeWidget
    property int volume: 0
    property bool isMuted: false
    property bool changeLocked: false

    // Helper function to safely restart a process
    function execute(proc) {
        proc.running = false;
        proc.running = true;
    }

    Process {
        id: eventListener
        command: ["pactl", "subscribe"]
        running: true
        stdout: SplitParser {
            onRead: (data) => {
                if (String(data).includes("sink")) {
                    execute(volFetcher);
                    execute(muteFetcher);
                }
            }
        }
    }

    Process {
        id: volFetcher
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\\d+(?=%)' | head -n 1"]
        stdout: SplitParser { onRead: (data) => volume = parseInt(String(data).trim()) }
    }

    Process {
        id: muteFetcher
        command: ["pactl", "get-sink-mute", "@DEFAULT_SINK@"]
        stdout: SplitParser { onRead: (data) => isMuted = String(data).includes("yes") }
    }

    Process { id: volUp; command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "+5%"] }
    Process { id: volDown; command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "-5%"] }
    Process { id: muteToggler; command: ["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"] }
    Process { id: mixerLauncher; command: ["pavucontrol"] }

    // Timer locks volume change
    // Prevents race conditions when changing too fast
    Timer {
        id: throttleTimer
        interval: 50 
        onTriggered: volumeWidget.changeLocked = false
    }

    Component.onCompleted: {
        execute(volFetcher);
        execute(muteFetcher);
    }

    iconText: isMuted ? "" : ""
    labelText: volume + "%"

    onClicked: execute(muteToggler)
    onDoubleClicked: execute(mixerLauncher)
    onScroll: (event) => {
        if (changeLocked) return;

        if (event.angleDelta.y > 0 && volume < 100) {
            changeLocked = true;
            execute(volUp);
            throttleTimer.start();
        } else if (event.angleDelta.y < 0) {
            changeLocked = true;
            execute(volDown);
            throttleTimer.start();
        }
    }
}