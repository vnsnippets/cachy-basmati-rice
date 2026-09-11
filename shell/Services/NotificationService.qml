pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

import Quickshell
import Quickshell.Services.Notifications

import qs.Utilities

Singleton {
    id: _Service

    property alias notifications: _NotificationServer.trackedNotifications

    NotificationServer {
        id: _NotificationServer

        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: (e) => {
            e.tracked = true;
            Debug.log("[Notification] Received", e.appName, "| ID:", e.id);
        }
    }

    function target(clients, notification) {
        Debug.json("---", "Notification: ", notification);
        Debug.log("---", "Discovered", clients.length, "clients");

        if (!notification || !Array.isArray(clients) || clients.length === 0) return null;

        const hints = notification.hints || {};

        // Helper: Normalize app IDs (strips paths, extensions like .desktop/.png, and lowercases)
        const normalize = (str) => {
            if (!str || typeof str !== "string") return "";
            return str
            .trim()
            .replace(/^.*[\\\/]/, "") // Strip directory path if present
            .replace(/\.(desktop|png|svg|xpm)$/i, "") // Strip file extension
            .toLowerCase();
        };

        // -------------------------------------------------------------
        // PASS 1: Strict PID Match (Highest Confidence)
        // -------------------------------------------------------------
        const pid = hints["sender-pid"] ?? hints["pid"];

        if (pid) {
            const pidMatch = clients.find((c) => c.pid === pid);
            if (pidMatch) {
                Debug.log("---", "Found target client with PID:", pid);
                return pidMatch;
            }
        }

        // -------------------------------------------------------------
        // PASS 2: Exact App Identifier Match
        // -------------------------------------------------------------
        const candidateList = [
            hints["desktop-entry"],
            notification.desktopEntry,
            notification.appIcon,
            notification.appName
        ];

        // Clean up candidates and deduplicate
        const candidates = [...new Set(candidateList.map(normalize).filter((c) => c.length > 0))];

        for (const cand of candidates) {
            const exactAppIdMatch = clients.find((c) => normalize(c.appid) === cand);
            if (exactAppIdMatch) {
                Debug.log("---", "Found target client with App ID:", cand);
                return exactAppIdMatch;
            }
        }

        // -------------------------------------------------------------
        // PASS 3: Partial / Cross-Inclusion Match
        // Handles reverse DNS like "org.telegram.desktop" vs "telegram"
        // -------------------------------------------------------------
        for (const cand of candidates) {
            // Skip short generic candidate names to prevent false positives (e.g., "org")
            if (cand.length < 3) continue;

            const partialAppIdMatch = clients.find((c) => {
                const appId = normalize(c.appid);
                if (!appId) return false;
                return appId.includes(cand) || cand.includes(appId);
            });

            if (partialAppIdMatch) {
                Debug.log("---", "Found target client with partial App ID match:", cand);
                return partialAppIdMatch;
            }
        }

        // -------------------------------------------------------------
        // PASS 4: Window Title Match (Fallback for Web Apps / Electron)
        // -------------------------------------------------------------
        const summary = (notification.summary || "").toLowerCase().trim();
        if (summary.length > 2) {
            const partialTitleMatch = clients.find((c) => (c.title || "").toLowerCase().includes(summary));
            if (partialTitleMatch) {
                Debug.log("---", "Found target client with partial title match:", cand);
                return partialTitleMatch;
            }
        }

        return null;
    }
}