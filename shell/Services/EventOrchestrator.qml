pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Polkit

Singleton {
    readonly property string _AUDIO_OSD_EVENT_KEY:  "AUDIOOSD"
    readonly property string _SCREEN_OSD_EVENT_KEY: "SCREENOSD"
    readonly property string _BACKLIGHT_OSD_EVENT_KEY: "BACKLIGHTOSD"
    readonly property string _POLKIT_OSD_EVENT_KEY: "POLKITOSD"

    signal osdDismissEvent();
    signal osdTriggerEvent(string key, var data);
    
    signal notificationEvent(int timestamp, var data)
    
    signal consoleToggleEvent(ShellScreen screen);
    signal consoleCloseEvent();
    signal consoleCloseCompleted(ShellScreen screen);
    signal consoleDismissContentEvent();

    signal polkitRequestEvent(PolkitAgent agent);
}