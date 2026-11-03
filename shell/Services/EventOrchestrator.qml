pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Polkit

Singleton {
    // --- OSD EVENTS ---
    readonly property string _VOLUME_CHANGE_EVENT:  "VOLUME_CHANGE"
    readonly property string _DISPLAY_CHANGE_EVENT: "DISPLAY_CHANGE"
    readonly property string _BACKLIGHT_CHANGE_EVENT: "BACKLIGHT_CHANGE"
    readonly property string _SCREEN_CAPTURE_EVENT: "SCREEN_CAPTURE"

    readonly property string _POLKIT_REQUEST_EVENT: "POLKIT_REQUEST"

    signal osdDismissCompleted();
    signal osdTriggerEvent(string key, bool dismissive, var data);
    signal osdDismissEvent();

    signal notificationEvent(int timestamp, var data)
    
    signal consoleToggleEvent(ShellScreen screen);
    signal consoleCloseEvent();
    signal consoleCloseCompleted(ShellScreen screen);
    signal consoleDismissContentEvent();

    signal polkitRequestEvent(PolkitAgent agent);
}