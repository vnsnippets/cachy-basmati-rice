pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland

import qs
import qs.Styles
import qs.Widgets

RowLayout {
    id: root

    anchors.fill: parent
    spacing: Style.widgets.spacing
    Layout.alignment: Qt.AlignCenter

    readonly property var filteredWorkspaces: {
        const screenName = canvas.screen?.name;
        if (!screenName) return [];
        return Hyprland.workspaces.values
            .filter(ws => ws.monitor?.name === screenName)
            .sort((a, b) => a.id - b.id);
    }

    property ColorScheme style: ColorScheme {}

    Item { Layout.fillWidth: true }

    Repeater {
        model: root.filteredWorkspaces

        Clickable {
            id: dot
            required property var modelData
            readonly property bool isActive: Hyprland.focusedWorkspace?.id === modelData?.id ?? false

            Layout.preferredHeight: 24
            implicitWidth: (isActive) ? 40 : 24
            radius: 20

            style: root.style

            onClicked: modelData.activate()

            Behavior on implicitWidth {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuint }
            }
        }
    }

    Item { Layout.fillWidth: true }
}