pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

import qs.Styles
import qs.Widgets
import qs.Widgets.Audio
import qs.Widgets.Battery
import qs.Widgets.Caffeine
import qs.Widgets.Clock
import qs.Widgets.Network
import qs.Widgets.Power
import qs.Widgets.Workspaces

RowLayout {
    id: root
    spacing: Style.dock.spacing

    anchors.topMargin: Style.dock.margin
    anchors.leftMargin: Style.dock.margin
    anchors.rightMargin: Style.dock.margin

    // --- LEFT ---
    RowLayout {
        id: section_start
        spacing: Style.dock.spacing

        ClockWidget { 
            format: "yyyy-MM-dd HH:mm"
        }
    }

    // --- MIDDLE: Workspace Dots ---
    Rectangle {
        readonly property int offset: section_end.width - section_start.width

        Layout.fillWidth: true
        implicitHeight: parent.height

        Layout.leftMargin: Math.max(offset, 0)
        Layout.rightMargin: Math.max(-offset, 0)

        color: "transparent"

        WorkspaceControl { 
            style.border.active: Style.color_light
        }
    }

    // --- RIGHT ---
    RowLayout {
        id: section_end
        spacing: Style.dock.spacing

        NetworkWidget  {
            popup: NetworkPopup {}
            color_disconnected: Style.color_muted
            color_connecting: Style.color_yellow
            color_connected_default: Style.color_green
            color_connected_critical: Style.color_red
            color_connected_limited: Style.color_yellow
        }

        AudioWidget {
            color_inactive: Style.color_slate
            color_default: Style.color_teal    
        }

        BatteryWidget {
            popup: BatteryPopup {}
            color_critical: Style.color_red
            color_warning: Style.color_yellow
            color_charging: Style.color_yellow
            color_default: Style.color_green
        }

        CaffeineWidget {
            color_caffeineon: Style.color_red
            color_caffeineoff: Style.color_blue
        }

        PowerWidget {
            Layout.alignment: Qt.AlignTop
            style.text.idle: Style.color_red
            style.background.active: Style.color_red
            style.text.active: Style.color_dark
            style.border.active: Style.color_red
        }
    }
}