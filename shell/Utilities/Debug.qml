pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property bool _DEBUG_MODE_: Quickshell.env("DEBUG") === "1"

    function log(ctx, ...args) {
        if (!_DEBUG_MODE_) return;

        const ctxarray = [(new Date()).toTimeString().slice(0, 5), ...ctx]
        const ctxhead = ctxarray.map(item => `[${item}]`).join('');

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

        console.log(ctxhead, "::", ...formattedArgs);
    }
}