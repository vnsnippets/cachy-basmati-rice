pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: daemon_container

    property var processes: []

    function execute(args, callback) {
        const p = _shell.createObject(daemon_container, {
            "command":  args,
            "callbackHandle": callback
        });

        processes.push(p);
        p.running = true;
        return p;
    }

    Component {
        id: _shell

        Process {
            id: proc
            property var callbackHandle: null
            property int _exitCode: 0
            
            readonly property alias _stdoutCollector: stdoutColl
            readonly property alias _stderrCollector: stderrColl

            environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })
            stdout: StdioCollector { id: stdoutColl }
            stderr: StdioCollector { id: stderrColl }

            onExited: (code) => { _exitCode = code; }

            onRunningChanged: {
                if (running) return;

                if (daemon_container) {
                    const idx = daemon_container.processes.indexOf(proc);
                    if (idx >= 0) {
                        daemon_container.processes.splice(idx, 1);
                    }
                }

                if (callbackHandle) {
                    const result = { 
                        success: _exitCode === 0, 
                        output: _stdoutCollector.text.trim(), 
                        error: _stderrCollector.text.trim(), 
                        exitCode: _exitCode 
                    };
                    callbackHandle(result, _exitCode);
                }

                proc.destroy(); 
            }
        }
    }

    Component.onDestruction: {
        for (let p of processes) {
            if (p) {
                p.running = false;
                p.destroy();
            }
        }
        processes = [];
    }
}