import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

import qs
import qs.Utilities
import qs.Widgets

Clickable {
    id: container

    readonly property real increment_diff: 0.05
    property bool change_lock: false

    property color color_inactive: null
    property color color_default: null

    Timer {
        id: throttle_timer
        interval: 50 
        onTriggered: container.change_lock = false
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }
    
    icon: Pipewire?.defaultAudioSink?.audio?.muted ? "" : ""
    // icon: Pipewire?.defaultAudioSink?.audio?.muted ? "\ue906" : (Pipewire?.defaultAudioSink?.audio?.volume === 0) ? "\ue905" : (Pipewire?.defaultAudioSink?.audio?.volume <= 0.5) ? "\ue908" : "\ue907"
    label: `${(Pipewire?.defaultAudioSink?.audio?.volume * 100).toFixed(0) ?? 0}%`
    style.text.idle: Pipewire?.defaultAudioSink?.audio ? color_default : color_inactive

    onClicked: () => {
        Pipewire.defaultAudioSink.audio.muted = Pipewire?.ready ? !Pipewire?.defaultAudioSink?.audio?.muted : false;
    }

    onScrolled: (event) => {
        if (change_lock || !Pipewire.defaultAudioSink?.audio) return;

        change_lock = true;
        let current_vol = Pipewire.defaultAudioSink.audio.volume;
        let updated_vol = current_vol;

        // Use a small epsilon or Math.min/max to prevent overshooting
        if (event.angleDelta.y > 0) {
            updated_vol = Math.min(1.0, current_vol + increment_diff);
        } else {
            updated_vol = Math.max(0.0, current_vol - increment_diff);
        }

        if (Math.abs(updated_vol - current_vol) > 0.001) {
            Pipewire.defaultAudioSink.audio.volume = updated_vol;
        }
        
        throttle_timer.restart();
    }

}