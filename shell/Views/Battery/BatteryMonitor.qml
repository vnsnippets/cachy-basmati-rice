pragma ComponentBehavior: Bound

import QtQuick

import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Services

Scope {
    id: root
    required property UPowerDevice device

    property bool notified_warning: false
    property bool notified_critical: false

    Connections {
        target: root.device ?? null
        enabled: root.device

        function onStateChanged() {
            let state = root.device.state;

            if (state === UPowerDeviceState.Charging || state === UPowerDeviceState.FullyCharged) {
                NotificationService.push(`Battery (${UPowerDeviceState.toString(state)})`);
                
                root.notified_warning = false;
                root.notified_critical = false;
            }
        }
    }

    Connections {
        target: root.device

        enabled: (root.device && root.device.percentage <= Constants.battery_threshold_warning)

        function onPercentageChanged() {
            if (root.device.percentage < Constants.battery_threshold_critical && !root.notified_critical) {
                NotificationService.push(`Battery Critical (${Math.round(root.device.percentage * 100)}%)`);
                root.notified_critical = true;
                return;
            }

            if (root.device.percentage < Constants.battery_threshold_warning && !root.notified_warning && !root.notified_critical) {
                NotificationService.push(`Battery Warning (${Math.round(root.device.percentage * 100)}%)`);
                root.notified_warning = true;
                return;
            }
        }
    }
}