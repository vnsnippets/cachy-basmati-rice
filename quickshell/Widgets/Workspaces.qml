import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import qs

 Repeater {
    id: container
    model: 9

    Layout.preferredWidth: parent.width
    Layout.preferredHeight: parent.height

    readonly property int default_size: 12
    readonly property int active_size:  24

    property var workspace: null;
    property var is_active: null;

    Base {
        height: default_size
        width: variant.active ? active_size : default_size
        radius: default_size/2

        onClicked: Hyprland.dispatch("workspace " + (index + 1))
    }
}