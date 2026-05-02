import QtQuick
import QtQuick.Layouts

import Quickshell

import qs
import qs.Styles
import qs.Widgets
import qs.Utilities

RowLayout {
    Layout.fillWidth: true
    spacing: Style.widgets.spacing

    Clickable { 
        Layout.fillWidth: true
        Layout.preferredWidth: 0
        icon: "󰌾"
        label: "Lock"
        onClicked: Daemon.execute(["loginctl", "lock-session"])
        style.background.idle: Style.popup.button.background.idle
        style.background.active: Style.popup.button.background.active
    }

    Clickable {
        Layout.fillWidth: true
        Layout.preferredWidth: 0
        icon: "󰒲"
        label: "Sleep"
        onClicked: Daemon.execute(["systemctl", "suspend"])
        style.background.idle: Style.popup.button.background.idle
        style.background.active: Style.popup.button.background.active
    }

    Clickable {
        Layout.fillWidth: true
        Layout.preferredWidth: 0
        icon: "󰑓"
        label: "Reboot"
        onClicked: Daemon.execute(["systemctl", "reboot"])
        style.background.idle: Style.popup.button.background.idle
        style.background.active: Style.popup.button.background.active
    }
    
    Clickable {
        Layout.fillWidth: true
        Layout.preferredWidth: 0
        icon: "󰐥"
        label: "Power"
        onClicked: Daemon.execute(["systemctl", "poweroff"])
        style.background.idle: Style.popup.button.background.idle
        style.background.active: Style.popup.button.background.active
    }
}