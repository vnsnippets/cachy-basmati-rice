pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string _AUDIO_OSD_EVENT_KEY: "AUDIOOSD"

    signal osdDismissEvent(ShellScreen screen);
    signal osdTriggerEvent(ShellScreen screen, string key);
}