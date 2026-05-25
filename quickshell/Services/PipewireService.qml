pragma Singleton

import QtQuick

import Quickshell
import Quickshell.Services.Pipewire

import qs.Utilities

Singleton {
    id: root
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.preferredDefaultAudioSink, ...Pipewire.nodes.values]
    }
    
    readonly property PwNode defaultSink: Pipewire.defaultAudioSink    
    readonly property var audioSinks: Pipewire.nodes.values.filter((node) => node.isSink && !node.isStream);

    readonly property var connectedMicrophones: Pipewire.nodes.values.filter(node => node.ready && !node.name.includes(".monitor") && node.properties["media.class"] === "Audio/Source").map((node) => {
        const enrichedNode = {
            node: node,
            plugged: true
        }

        // --- Hardware Verification Layer ---
        
        // Clear out the phantom ALC257 analog jack clone
        if (node.properties["device.api"] === "alsa") {
            const alsaId = node.properties["alsa.id"] || "";
            const alsaPath = node.properties["api.alsa.path"] || "";
            const deviceBus = node.properties["device.bus"] || "";
            
            // Check if this is the integrated PCI audio controller
            if (deviceBus === "pci") {
                // The phantom node uses the "Generic_1" legacy handler, 
                // while the true digital array maps directly to the AMD acp coprocessor.
                if (alsaId === "Generic_1" && !alsaPath.includes("acp")) {
                    enrichedNode.plugged = false;
                    return enrichedNode;
                }
            }
        }

        // Bluetooth validation
        if (node.properties["device.api"] === "bluez5" && node.properties["device.bluetooth.connected"] !== "true") {
            enrichedNode.plugged = false;
            return enrichedNode;
        }

        return enrichedNode;
    }).sort((a, b) => {
        // Name/Description: Alphabetical order
        const nameA = a.node.description ?? a.node.name ?? '';
        const nameB = b.node.description ?? b.node.name ?? '';
        const sortName = nameA.localeCompare(nameB);
        if (sortName !== 0) return sortName;

        // (Fallback) ID: Smaller ID comes first
        return a.node.id - b.node.id;
    });
}