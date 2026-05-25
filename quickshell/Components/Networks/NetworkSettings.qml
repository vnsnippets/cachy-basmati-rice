import QtQuick
import QtQuick.Layouts

import Quickshell.Networking

import qs.Assets
import qs.Utilities
import qs.Components

TabLayout {
    tabs: Networking.devices.values.filter((device) => device.type === DeviceType.Wifi).map((device) => {
        const componentUri = "WirelessNetwork.qml";

        const component = Qt.createComponent(componentUri);
        if (component.status === Component.Ready) {
            const instance = component.createObject(parent, {
                "device": device
            });

            return {
                label: device.name.toUpperCase(),
                content: instance
            };
        }
    }).filter(Boolean)
}