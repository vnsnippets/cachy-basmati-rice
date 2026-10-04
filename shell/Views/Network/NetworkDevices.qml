pragma ComponentBehavior: Bound

import QtQuick

import Quickshell.Networking

import qs.Types
import qs.Layouts
import qs.Utilities

ContentTabContainer {
    id: container

    // Function to populate the tabs array dynamically from NetworkService
    function rebuildTabs() {
        const devices = Networking.devices.values ?? [];
        const generatedTabs = [];

        for (var i=0; i < devices.length; i++) {
            const dev = devices[i]
            const tabName = dev.name ?? (dev.type === DeviceType.Wifi ? "Wi-Fi" : "Ethernet");

            Debug.log(x)

            // Create TabItem instance using component factory
            const tabInstance = tabItemComponent.createObject(container, {
                label: tabName,
                // Assign a component delegate pre-bound to this specific device
                content: component_device_item.createObject(container, { model: dev }).delegate
            });

            generatedTabs.push(tabInstance);
        }

        container.tabs = generatedTabs;
    }

    // Factory component for TabItem instances
    Component {
        id: tabItemComponent
        
        TabItem {}
    }

    Component {
        id: component_device_item
        QtObject {
            id: device_item
            property var model: null
            property Component delegate: Component {
                NetworkDeviceView {
                    device: device_item.model
                }
            }
        }
    }

    Component.onCompleted: rebuildTabs()

    // Re-evaluate tabs if hardware interfaces are plugged in or removed
    Connections {
        target: Networking.devices
        function onValuesChanged() {
            container.rebuildTabs();
        }
    }
}