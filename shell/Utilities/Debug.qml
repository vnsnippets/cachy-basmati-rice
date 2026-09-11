pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property bool _DEBUG_MODE_: Quickshell.env("DEBUG") === "1"

    function log(...args) {
        if (_DEBUG_MODE_)
            console.log(Date.now(), "::", ...args);
    }

    function json(...args) {
        if (!_DEBUG_MODE_) return;

        const formattedArgs = args.map(arg => {
            if (typeof arg === "object" && arg !== null) {
                try {
                    return JSON.stringify(arg, null, 2);
                } catch (e) {
                    return arg; // Fallback if circular references exist
                }
            }
            return arg;
        });

        console.log(Date.now(), "::", ...formattedArgs);
    }
}