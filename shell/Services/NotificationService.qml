pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import QtQml.Models

import Quickshell
import Quickshell.Services.Notifications

import qs.Utilities

Singleton {
    id: _Service

    component NotificationItem: QtObject {
        id: _Item

        required property date createdAt
        required property bool active
        required property Notification notification

        function dismiss() {
            _Service.remove(_Item);
        }
    }

    property alias items: _ItemList

    // readonly property ObjectModel objects: ObjectModel {}

    ListModel { id: _ItemList }

    function push(e) {
        var item = _ItemComponent.createObject(_Service, {
            createdAt: new Date(),
            active: true,
            notification: e
        });

        _Service.items.append(item);

        Debug.log("[Notification]", "Received:", e.appName, e.body);
    }

    function remove(item) {
        _Service.items.remove(item);
    }

    property Component _ItemComponent: NotificationItem {}
}