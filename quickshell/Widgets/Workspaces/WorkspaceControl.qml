pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland

import qs
import qs.Types
import qs.Styles
import qs.Controls

RowLayout {
    id: root
    spacing: Style.clickable.spacing

    property bool filterByMonitor: true

    readonly property int dotSize: 24
    readonly property int dotRadius: 12
    readonly property int dotActiveSize: dotSize
    readonly property int fontSize: 14

    required property color activeColor
    required property color inactiveColor

    required property color activeBorderColor
    required property color inactiveBorderColor

    required property color activeTextColor
    required property color inactiveTextColor
    

    readonly property var filteredWorkspaces: {
        const screenName = dockspace.screen?.name;
        const rawWorkspaces = Array.from(Hyprland.workspaces.values);

        if (root.filterByMonitor) {
            // OPTIMIZED PATH: 
            // Only get current monitor workspaces and do a simple ID sort.
            return rawWorkspaces
                .filter(ws => ws.monitor?.name === screenName)
                .sort((a, b) => a.id - b.id);
        } else {
            // EXTRA WORK PATH: 
            // Keep all workspaces and apply the "Other Monitors to Front" priority.
            return rawWorkspaces.sort((a, b) => {
                const aIsOther = a.monitor?.name !== screenName;
                const bIsOther = b.monitor?.name !== screenName;

                // Priority 1: Screen locality
                if (aIsOther && !bIsOther) return -1;
                if (!aIsOther && bIsOther) return 1;

                // Priority 2: Numerical ID
                return a.id - b.id;
            });
        }
    }

    Repeater {
        // Ensure at least 5 dots are displayed
        model: root.filteredWorkspaces.length

        Clickable {
            id: dot

            required property int modelData
            readonly property int index: modelData
            
            // Get the workspace object if it exists for this index
            readonly property var ws: root.filteredWorkspaces[index]
            readonly property bool isActive: Hyprland.focusedWorkspace?.id === ws?.id

            readonly property bool isOtherMonitor: (!root.filterByMonitor && ws && ws.monitor?.name !== dockspace.screen?.name) ?? false

            Layout.preferredHeight: root.dotSize
            implicitWidth: isActive ? dotActiveSize : root.dotSize
            radius: dotRadius

            // Dynamic Styling
            colors.background.idle: (isActive) ? root.activeColor : inactiveColor
            colors.background.active: root.activeColor

            colors.border.idle: (isActive) ? root.activeColor : inactiveBorderColor
            colors.border.active: root.activeColor
            
            // Only allow clicking if the workspace actually exists
            onClicked: if (ws && !isActive) ws.activate();

            Behavior on implicitWidth {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuint }
            }

            StyledText {
                anchors.centerIn: parent
                text: "\uF358" // "" "󱂬" "" "" "󰍺" "󰍹"
                visible: dot.isOtherMonitor
                active: dot.containsMouse
                style.idle: isActive ? root.activeTextColor : root.inactiveTextColor
                style.active: root.activeTextColor
                font.pixelSize: root.fontSize
                font.family: Style.fonts.icon
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Clickable {
        Layout.preferredHeight: root.dotSize
        implicitWidth: root.dotSize
        radius: dotRadius

        StyledText {
            anchors.centerIn: parent
            text: "\uF108" // ""
            color: root.inactiveTextColor
        }

        onClicked: Hyprland.dispatch(`workspace ${Hyprland.workspaces.values.length + 1}`);
    }
}