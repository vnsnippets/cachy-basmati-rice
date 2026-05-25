pragma Singleton

import QtQuick
import Quickshell
// import Quickshell.Io

Singleton {
    readonly property bool _DEBUG_MODE_: Quickshell.env("DEBUG") === "1"

    function log(...args) {
        if (_DEBUG_MODE_)
            console.log(...args);
    }

    function json(obj) {
        if (_DEBUG_MODE_)
            console.log(JSON.stringify(obj, null, 2));
    }
}