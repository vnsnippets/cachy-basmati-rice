pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

import Quickshell

import qs.Utilities

Singleton {
    id: root

    function getCurrentMonitorName(callback) {
        if (!callback) return false;

        Daemon.execute(["mmsg", "get", "last_open_surface"], (e) => {
            // E.g. {"monitor":"eDP-1","last_open_surface":"quickshell"}
            const result = JSON.parse(e?.output?.trim());
            callback(result?.monitor ?? null);
        });
    }

    function getconnectedmonitors(callback) {
        if (!callback) return false;

        Daemon.execute(["mmsg", "get", "all-monitors"], (e) => {
            try {
                const result = JSON.parse(e?.output?.trim() ?? "[]");
                callback(result ?? []);
            } catch (err) {
                callback([]);
            }
        });
    }

    // Socket {
    //     id: monitorwatch
    //     path: Quickshell.env("MANGO_INSTANCE_SIGNATURE")
    //     connected: true

    //     onConnectedChanged: {
    //         Debug.log("[Mango IPC]", `(${Quickshell.env("MANGO_INSTANCE_SIGNATURE")})`, connected ? "Connected." : "Connection Dropped.");
    //         if (connected) {
    //             this.write("watch all-monitors\n")
    //         }
    //     }

    //     parser: SplitParser {
    //         splitMarker: "\n"
    //         onRead: (msg) => {
    //             Debug.log("[Watch All Monitors] Triggered.")
    //         }
    //     }
    // }
}