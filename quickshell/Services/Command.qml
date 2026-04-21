// Command.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: command

    property var processes: []

    function execute(args, callback) {
        const p = shell.createObject(command, {
            "command": args,
            "callback": callback
        });

        // Update tracking list
        let current = processes;
        current.push(p);
        processes = current;

        // Cleanup and finish logic
        p.runningChanged.connect(() => {
            if (!p.running) {
                // Remove from tracking
                let list = processes;
                const index = list.indexOf(p);
                if (index >= 0) {
                    list.splice(index, 1);
                    processes = list;
                }

                // Fire callback with combined output (or handle error code)
                if (p.callback) {
                    const result = p.stdoutCollector.text.trim() || p.stderrCollector.text.trim();
                    console.log(result)
                    p.callback(result, p.exitCode);
                }

                p.destroy(100); 
            }
        });

        p.exec({ command: args, callback: callback });
        return p;
    }

    Component {
        id: shell
        Process {
            id: proc
            property var callback: null

            // We use alias to access collectors in the singleton logic
            property alias stdoutCollector: stdoutColl
            property alias stderrCollector: stderrColl

            stdout: StdioCollector { id: stdoutColl }
            stderr: StdioCollector { id: stderrColl }
        }
    }
}