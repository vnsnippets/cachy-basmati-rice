pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: command

    property var processes: []

    function execute(args, callback) {
        const p = _shell.createObject(command, {
            "command":  args,
            "callbackHandle": callback 
        });

        let current = processes;
        current.push(p);
        processes = current;

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

            // Using the signal handler instead of .connect() in the singleton
            onRunningChanged: {
                if (running) return;

                // 1. Remove from parent list safely
                if (command) {
                    let list = command.processes;
                    const idx = list.indexOf(proc);
                    if (idx >= 0) {
                        list.splice(idx, 1);
                        command.processes = list;
                    }
                }

                // 2. Execute callback
                if (callbackHandle) {
                    const result = { 
                        success: _exitCode === 0, 
                        output: _stdoutCollector.text.trim(), 
                        error: _stderrCollector.text.trim(), 
                        exitCode: _exitCode 
                    };
                    callbackHandle(result, _exitCode);
                }

                // 3. Immediate destruction - NEVER use destroy(100) in Quickshell
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