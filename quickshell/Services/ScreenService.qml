pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io

import qs.Utilities

Singleton {
    id: wlroots

    function randr(callback) {
        if (!callback) return;

        Daemon.execute(["wlr-randr"], (res) => {
            if (!res.success) callback([]);
            
            const lines = res.output.split("\n");
            const monitors = [];
            let currentMonitor = null;
            let currentMode = null;
            let inModesSection = false;

            for (let i = 0; i < lines.length; i++) {
                const line = lines[i];

                // 1. Match monitor output line (e.g. "eDP-1 "Chimei Innolux Corporation ...")
                if (line.length > 0 && !line.startsWith(" ") && !line.startsWith("\t")) {
                    const parts = line.trim().split(/\s+/);
                    const name = parts[0];
                    const model = parts.slice(1).join(" ").replace(/^"|"$/g, "");

                    currentMonitor = {
                        name: name,
                        model: cleanMakeModel(model),
                        enabled: true,
                        width: 0,
                        height: 0,
                        x: 0,
                        y: 0,
                        scale: 1.0,
                        transform: "normal",
                        modes: []
                    };
                    monitors.push(currentMonitor);
                    inModesSection = false;
                    continue;
                }

                if (!currentMonitor) continue;

                const trimmed = line.trim();

                // 2. Parse property lines under a monitor
                if (trimmed.startsWith("Enabled:")) {
                    currentMonitor.enabled = trimmed.includes("yes");
                } else if (trimmed.startsWith("Position:")) {
                    const pos = trimmed.replace("Position:", "").trim().split(",");
                    currentMonitor.x = parseInt(pos[0], 10) || 0;
                    currentMonitor.y = parseInt(pos[1], 10) || 0;
                } else if (trimmed.startsWith("Scale:")) {
                    currentMonitor.scale = parseFloat(trimmed.replace("Scale:", "").trim()) || 1.0;
                } else if (trimmed.startsWith("Transform:")) {
                    currentMonitor.transform = trimmed.replace("Transform:", "").trim();
                } else if (trimmed.startsWith("Modes:")) {
                    inModesSection = true;
                } else if (inModesSection && trimmed.length > 0) {
                    // 3. Parse mode lines (e.g. "1920x1080 px, 60.001000 Hz (current) (preferred)")
                    const isCurrent = line.includes("(current)");
                    const isPreferred = line.includes("(preferred)");

                    const modeParts = trimmed.split(" px, ");
                    if (modeParts.length === 2) {
                        const resParts = modeParts[0].split("x");
                        const w = parseInt(resParts[0], 10);
                        const h = parseInt(resParts[1], 10);
                        const refreshRate = parseFloat(modeParts[1].split(" ")[0]);

                        const modeObj = {
                            width: w,
                            height: h,
                            refreshRate: refreshRate,
                            current: isCurrent,
                            preferred: isPreferred
                        };

                        currentMonitor.modes.push(modeObj);

                        if (isCurrent) {
                            currentMonitor.width = w;
                            currentMonitor.height = h;
                        }
                    }
                }
            }

            callback(monitors);
        });
    }

    function cleanMakeModel(str) {
        if (!str) return "";

        // 1. Remove trailing port tags like "(DP-2)" or "(eDP-1)"
        let cleaned = str.replace(/\s*\([A-Za-z0-9_-]+\)\s*$/, "").trim();

        // 2. Deduplicate repeated vendor acronyms (e.g. "BNQ BenQ" -> "BenQ", "SAM Samsung" -> "Samsung")
        const parts = cleaned.split(/\s+/);
        if (parts.length > 1 && parts[0].length === 3 && parts[1].toLowerCase().startsWith(parts[0].toLowerCase().slice(0, 2))) {
            cleaned = parts.slice(1).join(" ");
        }

        return cleaned;
    }

    function safeToggle(monitor, callback) {
        if (!monitor || !monitor.name) return;

        // If monitor is currently disabled, turn it on directly
        if (!monitor.enabled) {
            Daemon.execute(["wlr-randr", "--output", monitor.name, "--on"], (res) => {
                if (callback) callback(res);
            });
            return;
        }

        // If monitor is enabled, turn off ONLY if more than 1 display is active
        const cmd = `[ $(wlr-randr | grep -c "Enabled: yes") -gt 1 ] && wlr-randr --output ${monitor.name} --off`;
        
        Daemon.execute(["sh", "-c", cmd], (res) => {
            if (callback) callback(res);
        });
    }
}