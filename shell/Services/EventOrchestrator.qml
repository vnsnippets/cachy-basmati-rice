pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string _AUDIO_OSD_EVENT_KEY:  "AUDIOOSD"
    readonly property string _SCREEN_OSD_EVENT_KEY: "SCREENOSD"
    readonly property string _BACKLIGHT_OSD_EVENT_KEY: "BACKLIGHTOSD"

    signal osdDismissEvent();
    signal osdTriggerEvent(string key, var data);
}