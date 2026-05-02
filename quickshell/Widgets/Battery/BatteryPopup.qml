pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs
import qs.Styles
import qs.Widgets
import qs.Widgets.Battery.Components

Popup {
    id: root

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.popup.spacing

        RowLayout {
            spacing: Style.popup.spacing
            Layout.fillWidth: true

            BatteryControl { Layout.fillWidth: true }

            Item { Layout.fillWidth: true }

            Clickable {
                Layout.alignment: Qt.AlignTop
                icon: ""
                style.background.idle: Style.popup.button.background.idle
                style.background.active: Style.popup.button.background.active
            }
        }
        
        BrightnessControl { Layout.fillWidth: true }
        // PowerControl { Layout.fillWidth: true }

        // --- Power Profiles Selector ---
        ModeControl { Layout.fillWidth: true }
    }
}
