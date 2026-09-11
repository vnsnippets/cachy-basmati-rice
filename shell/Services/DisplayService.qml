pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

import Quickshell

import qs.Utilities

Singleton {
    id: service
    property var screens: []

    // Concurrency guards to deduplicate wlr-randr calls
    property bool isFetching: false
    property var pendingCallbacks: []

    function init() {
        Debug.log("[Service][Display] Initializing...")        
        all((result) => { service.screens = result; });
    }

    // Retrieve all connected displays using wlr-randr (Deduplicated)
    function all(callback) {
        if (!callback) return;

        // Queue callback if a request is already in-flight
        service.pendingCallbacks.push(callback);
        if (service.isFetching) return;

        service.isFetching = true;

        Daemon.execute(["wlr-randr", "--json"], (res) => {
            service.isFetching = false;
            
            // Flush queue
            const callbacks = service.pendingCallbacks;
            service.pendingCallbacks = [];

            let result = [];
            if (res && res.success && res.output) {
                try {
                    const parsed = JSON.parse(res.output);
                    result = Array.isArray(parsed) ? parsed : [];
                } catch (e) {
                    Debug.log("[WLR-RANDR]", "Failed to parse JSON:", e);
                }
            }

            for (let i = 0; i < callbacks.length; i++) {
                callbacks[i](result);
            }
        });
    }

    function get(port, callback) {
        if (!callback) return;
        all((result) => {
            callback(result.find(m => m.name === port));
        });
    }

    function diff(callback) {
        if (!callback) return;

        // 1. Snapshot previous state IMMEDIATELY (synchronously) before async execution
        const previous = [...service.screens];

        Debug.log("[Service][Display] Refreshing...");
        
        // 2. Reuse deduplicated fetch
        all((result) => {
            service.screens = result;
            callback(previous, result);
        });
    }
}