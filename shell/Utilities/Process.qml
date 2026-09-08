pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: process
    property var threads: []

    function execute(args, callback) {
        const p = _shell.createObject(process, {
            command: args,
            callback: callback
        })
    }

    Component {
        id: _shell

        Process {
            id: thread
            property var callback: null
            property int _exitCode: 0

            readonly property alias _stdoutCollector: stdoutCollector
            readonly property alias _stderrCollector: stderrCollector

            environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })
            stdout: StdioCollector { id: stdoutCollector }
            stderr: StdioCollector { id: stderrCollector }

            onExited: (code) => { _exitCode = code; }

            onRunningChanged: {
                if (running) return;
                
                const idx = process.threads.indexOf(thread);
                if (idx >= 0) process.threads.splice(idx, 1);

                if (callback) {
                    const output = {
                        success: _exitCode === 0,
                        result: _stdoutCollector.text.trim(),
                        error: _stderrCollector.text.trim(),
                    };
                    callback(output, _exitCode);
                }

                thread.destroy();
            }
        }
    }

    Component.onDestruction: {
        threads.map((e) => {
            e.running = false;
            e.destroy();
        })

        threads = [];
    }
}