import QtQuick
import QtQuick.Layouts

import qs.Types
import qs.Styles

Rectangle {
    id: root

    // New property to control direction
    property string position: "left" // "left" or "right"
    
    property bool active: false
    property bool exiting: false
    
    color: Style.panel.colors.background
    radius: Style.panel.radius
    border.width: Style.borderWidth
    border.color: Style.panel.colors.border

    default property alias content: container.data
    clip: true

    // Initial state: Hidden, scaled down, and offset
    opacity: (active) ? 1 : 0
    scale: (active) ? 1 : 0.9

    x: {
        if (active) return 0;

        switch (position) {
            case (PanelPosition.left): return -50;
            case (PanelPosition.right): return 50;
            default: return 0;
        }
    }

    Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.Linear; }}
    Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.Linear; }}
    Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.Linear; }}

    Item { 
        id: container
        anchors.centerIn: parent 
    }

    Component.onCompleted: root.active = true
}