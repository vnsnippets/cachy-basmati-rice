pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

import qs

import qs.Styles
import qs.Widgets.Audio
import qs.Widgets.Battery
import qs.Widgets.Caffeine
import qs.Widgets.Network
import qs.Widgets.Workspaces

import qs.Types
import qs.Controls
import qs.Utilities

Item {
    id: root

    implicitHeight: container.height

    // --- LEFT ---
    RowLayout {
        id: container
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.spacing

        Loader {
            active: shell._DEBUG_MODE_
            sourceComponent: Clickable {
                StyledText {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: "BETA"
                    font.pixelSize: 12
                    font.bold: true
                }
            }
        }

        Clickable {
            implicitWidth: clock.width + Style.clickable.padding * 2
            StyledText {
                id: clock
                anchors.centerIn: parent
                text: Qt.formatDateTime(Context.clock.date, "yyyy-MM-dd HH:mm")
            }
        }
    }

    FramedGroup {
        anchors.centerIn: parent
        color: Style.colors.slate

        spacing: Style.spacing
        offset: 12
        radius: implicitWidth/2

        WorkspaceControl {
            filterByMonitor: true
            activeColor: Style.colors.green
            inactiveColor: Style.clickable.background.idle
            activeBorderColor: Style.colors.green
            inactiveBorderColor: Style.clickable.border.idle
            activeTextColor: Style.colors.base
            inactiveTextColor: Style.colors.text
        }
    }

    // --- RIGHT ---
    RowLayout {
        anchors.top: parent.top;
        anchors.right: parent.right;
        anchors.verticalCenter: parent.verticalCenter

        spacing: Style.spacing

        NetworkWidget  {
            showLabel: false
            color_disconnected: Style.colors.subtext
            color_connecting: Style.colors.yellow
            color_connected_default: Style.colors.green
            color_connected_critical: Style.colors.red
            color_connected_limited: Style.colors.yellow
        }

        AudioWidget {
            color_inactive: Style.colors.base
            color_default: Style.colors.blue
        }

        BatteryWidget {
            color_critical: Style.colors.red
            color_warning: Style.colors.yellow
            color_charging: Style.colors.yellow
            color_default: Style.colors.green
        }

        CaffeineWidget {
            activeColor: Style.colors.red
            inactiveColor: Style.colors.blue
        }

        Clickable {
            id: powerWidget

            colors.background.active: Style.colors.red
            colors.border.active: Style.colors.red

            onClicked: Context.process.shutdown = Daemon.execute(["poweroff"]);
            StyledText {
                anchors.centerIn: parent
                text: "\uF619" //""
                active: powerWidget.containsMouse
                style.idle: Style.colors.red
                style.active: Style.colors.base
                font.pixelSize: 18
                
            }
        }
        
        // Clickable {
        //     StyledText {
        //         anchors.centerIn: parent
        //         text:""
        //     }
        //     onClicked: scope.sidePanelOpen = !scope.sidePanelOpen
        // }
    }
}