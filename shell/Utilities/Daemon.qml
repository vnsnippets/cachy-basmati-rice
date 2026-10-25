pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell.Wayland

import QtQuick
import Quickshell
import Quickshell.Io

import qs.Services
import qs.Utilities

Singleton {
    id: daemon

    readonly property IdleInhibitor idle_inhibitor: IdleInhibitor { }
    readonly property SystemClock clock: SystemClock { precision: SystemClock.Minutes }

    property var threads: []

    function execute(args, callback) {
        const p = _shell.createObject(daemon, {
            "command":  args,
            "callback": callback
        });

        threads.push(p);
        p.running = true;
        return p;
    }

    Component {
        id: _shell

        Process {
            id: thread
            property var callback: null
            
            readonly property alias _stdoutCollector: stdoutColl
            readonly property alias _stderrCollector: stderrColl

            stdout: StdioCollector { id: stdoutColl }
            stderr: StdioCollector { id: stderrColl }


            onRunningChanged: {
                if (running) return;

                if (daemon) {
                    const idx = daemon.threads.indexOf(thread);
                    if (idx >= 0) {
                        daemon.threads.splice(idx, 1);
                    }
                }

                const log = _stdoutCollector.text.trim();
                const err = _stderrCollector.text.trim();

                if (callback) {
                    const result = {
                        success: !(err && err.length > 0), 
                        output: log, 
                        error: err, 
                    };
                    callback(result);
                }

                thread.destroy(); 
            }
        }
    }

    Component.onDestruction: {
        for (let p of threads) {
            if (p) {
                p.running = false;
                p.destroy();
            }
        }
        threads = [];
    }

    // 15 Seconds Dim
    IdleMonitor {
        timeout: 15
        enabled: !daemon.idle_inhibitor.enabled
        property int cached_brightness: -1
        readonly property bool brightness_is_cached: cached_brightness > -1
        readonly property int low_brightness_level: 10

        onIsIdleChanged: {
            Debug.log("[Idle Monitor] \t", (isIdle) ? `Lowering brightness to ${low_brightness_level}%` : `Restoring brightness to ${cached_brightness}%`);

            if (isIdle) {
                cached_brightness = (brightness_is_cached) ? cached_brightness : BacklightService.brightness;
                BacklightService.set(low_brightness_level);
            }
            else {
                BacklightService.set(cached_brightness);
                cached_brightness = -1;
            }
        }
    }

    // 30 Seconds Sleep
    IdleMonitor {
        timeout: 30
        enabled: !daemon.idle_inhibitor.enabled

        onIsIdleChanged: {
            Debug.log("[Idle Monitor] \t", (isIdle) ? "Sleeping monitors" : "Waking Monitors");

            if (isIdle) 
                Quickshell.screens.map((e) => {
                    MangoIPCService.sleep_monitor(e.name);
                })
            else 
                Quickshell.screens.map((e) => {
                    MangoIPCService.wake_monitor(e.name);
                })
        }
    }
}