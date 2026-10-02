pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

import Quickshell

import qs.Utilities

Singleton {
    id: service
    property var screens: []

    property bool isFetching: false
    property var pendingCallbacks: []

    function init() {
        Debug.log("[Service][Display] Initializing...")        
        all((result) => { service.screens = result; });
    }

    function all(callback) {
        if (!callback) return;

        service.pendingCallbacks.push(callback);
        if (service.isFetching) return;

        service.isFetching = true;

        Daemon.execute(["wlr-randr", "--json"], (res) => {
            service.isFetching = false;
            
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

        const previous = [...service.screens];

        Debug.log("[Service][Display] Refreshing...");
        
        all((result) => {
            service.screens = result;
            callback(previous, result);
        });
    }
}