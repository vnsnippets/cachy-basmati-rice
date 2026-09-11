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
            Debug.json(e);
        }
    }
}