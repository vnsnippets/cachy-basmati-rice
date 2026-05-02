import QtQuick
import QtQuick.Effects

import Quickshell
import Quickshell.Hyprland

import qs
import qs.Styles

Rectangle {
    id: root

    color: Style.popup.background
    radius: Style.popup.border_radius
    border.width: 1
    border.color: Style.color_light

    default property alias content: content_container.data
    property bool active: false

    implicitWidth: content_container.childrenRect.width + (Style.widgets.padding * 2)
    implicitHeight: content_container.childrenRect.height + (Style.widgets.padding * 2)
    
    clip: true
    transformOrigin: Item.Top

    // Background Animations
    scale: (active) ? 1.0 : 0
    opacity: (active) ? 1.0 : 0

    Behavior on scale { NumberAnimation { duration: Style.popup.animations.duration; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: Style.popup.animations.duration } }

    Item {
        id: content_container
        anchors.centerIn: parent

        opacity: root.active ? 1 : 0
        //scale: 1 / root.scale  // Enable for counter scaling

        y: root.active ? 0 : 10 
        Behavior on y { NumberAnimation { duration: Style.popup.animations.duration; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: Style.popup.animations.duration } }
    }

    Component.onCompleted: {
        active = true;
    }
}