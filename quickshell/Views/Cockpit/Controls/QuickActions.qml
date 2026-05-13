import QtQuick
import QtQuick.Layouts

import qs.Styles
import qs.Controls
import qs.Utilities

RowLayout {
    Layout.alignment: Qt.AlignHCenter
    spacing: Style.spacing

    Clickable {
        id: wifi
        
        property bool enabled: false

        colors.background.idle: (enabled) ? Style.colors.green : Style.clickable.background.idle
        colors.background.active: colors.background.idle
        colors.border.idle: (enabled) ? Style.colors.green : Style.clickable.border.idle
        
        StyledText {
            anchors.centerIn: parent
            text: ""
            active: wifi.containsMouse
            style.idle: (wifi.enabled) ? Style.colors.base : Style.colors.text
            style.active: style.idle
        }

        Component.onCompleted: {
            Daemon.execute(["nmcli", "radio", "wifi"], (e) => {
                if (!e || !e.output) return;
                wifi.enabled = (e.output.trim() === "enabled")
            })
        }
    }

    Clickable {
        id: bluetooth
        implicitWidth: 40
        implicitHeight: 40
        property bool enabled: false

        colors.background.idle: (enabled) ? Style.colors.green : Style.clickable.background.idle
        colors.background.active: colors.background.idle
        colors.border.idle: (enabled) ? Style.colors.green : Style.clickable.border.idle
        
        StyledText {
            anchors.centerIn: parent
            text: "󰂯"
            active: bluetooth.containsMouse
            style.idle: (bluetooth.enabled) ? Style.colors.base : Style.colors.text
            style.active: style.idle
        }

        Component.onCompleted: {
            Daemon.execute(["systemctl", "status", "bluetooth"], (e) => {
                if (!e || !e.output) return;
                bluetooth.enabled = e.output.includes("active (running)")
            })
        }
    }
}