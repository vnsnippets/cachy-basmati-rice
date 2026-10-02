pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: daemon

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
            property int _exitCode: 0
            
            readonly property alias _stdoutCollector: stdoutColl
            readonly property alias _stderrCollector: stderrColl

            environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })
            stdout: StdioCollector { id: stdoutColl }
            stderr: StdioCollector { id: stderrColl }

            onExited: (code) => { _exitCode = code; }

            onRunningChanged: {
                if (running) return;

                if (daemon) {
                    const idx = daemon.threads.indexOf(thread);
                    if (idx >= 0) {
                        daemon.threads.splice(idx, 1);
                    }
                }

                if (callback) {
                    const result = { 
                        success: _exitCode === 0, 
                        output: _stdoutCollector.text.trim(), 
                        error: _stderrCollector.text.trim(), 
                        exitCode: _exitCode 
                    };
                    callback(result, _exitCode);
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
}