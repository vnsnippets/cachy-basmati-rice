pragma Singleton

import Quickshell

Singleton {
    signal consoleToggleEvent(ShellScreen screen);
    signal consoleCloseEvent(ShellScreen screen);
    signal consoleCloseCompleted(ShellScreen screen);

    signal osdCloseEvent(ShellScreen screen);
    signal osdTimeoutEvent(ShellScreen screen);

    signal screensChangeEvent();
}