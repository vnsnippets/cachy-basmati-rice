pragma ComponentBehavior: Bound

import QtQuick

import Quickshell

import qs
import qs.Services
import qs.Components

Item {
    id: root

    property var monitors: []
    property var active_monitors: monitors.filter((e) => e.enabled !== false)

    property bool zoomed: false
    readonly property real zoom_factor: 0.5

    readonly property var bounds: {
        let acc = active_monitors.reduce((a, m) => {
            let x = (m.position && typeof m.position.x === "number") ? m.position.x : (m.x || 0);
            let y = (m.position && typeof m.position.y === "number") ? m.position.y : (m.y || 0);
            let w = get_monitor_width(m);
            let h = get_monitor_height(m);
            return {
                min_x: Math.min(a.min_x, x),
                max_x: Math.max(a.max_x, x + w),
                min_y: Math.min(a.min_y, y),
                max_y: Math.max(a.max_y, y + h)
            };
        }, { min_x: Infinity, max_x: -Infinity, min_y: Infinity, max_y: -Infinity });

        return {
            min_x: acc.min_x === Infinity ? 0 : acc.min_x,
            max_x: acc.max_x === -Infinity ? 1920 : acc.max_x,
            min_y: acc.min_y === Infinity ? 0 : acc.min_y,
            max_y: acc.max_y === -Infinity ? 1080 : acc.max_y
        };
    }

    property int padding: Constants.padding

    readonly property int available_width: Math.max(1, root.width - (root.padding * 2))
    readonly property int available_height: Math.max(1, root.height - (root.padding * 2))
    readonly property real content_width: Math.max(1, bounds.max_x - bounds.min_x)
    readonly property real content_height: Math.max(1, bounds.max_y - bounds.min_y)

    readonly property real scale_factor: Math.min(available_width / content_width, available_height / content_height) * (root.zoomed ? root.zoom_factor : 1.0)

    readonly property real offset_x: root.padding + (available_width - (content_width * scale_factor)) / 2
    readonly property real offset_y: root.padding + (available_height - (content_height * scale_factor)) / 2

    Rectangle {
        id: canvas
        anchors.fill: parent
        color: Constants.color_base
        radius: Constants.radius

        Repeater {
            model: root.active_monitors

            delegate: Clickable {
                id: monitor

                property point click_offset: Qt.point(0, 0)

                required property var modelData
                
                readonly property string name: modelData?.name ?? "Unknown Port"
                readonly property string model: modelData?.model ?? "Unknown Model"
                readonly property bool is_enabled: modelData?.enabled ?? false

                readonly property int pos_x: (is_dragging) ? dragged_x : modelData?.position?.x ?? (modelData?.x ?? 0)
                readonly property int pos_y: (is_dragging) ? dragged_y : modelData?.position?.y ?? (modelData?.y ?? 0)

                // Single call to helper functions (scale is already factored inside them)
                readonly property real base_width: root.get_monitor_width(modelData)
                readonly property real base_height: root.get_monitor_height(modelData)

                x: root.offset_x + (pos_x - root.bounds.min_x) * root.scale_factor
                y: root.offset_y + (pos_y - root.bounds.min_y) * root.scale_factor

                width: base_width * root.scale_factor
                height: base_height * root.scale_factor

                property bool is_dragging: false
                property int dragged_x: pos_x
                property int dragged_y: pos_y

                acceptedButtons: Qt.LeftButton
                        
                onPressed: (mouse) => {
                    is_dragging = true;
                    let mouse_position = mapToItem(canvas, mouse.x, mouse.y);
                    click_offset = Qt.point(mouse_position.x - monitor.x, mouse_position.y - monitor.y);
                }

                onPositionChanged: (mouse) => {
                    if (!is_dragging) return;
                    
                    let mouse_position = mapToItem(canvas, mouse.x, mouse.y);
                    let new_pos_x = mouse_position.x - click_offset.x;
                    let new_pox_y = mouse_position.y - click_offset.y;

                    // Convert canvas pixels back to logical coordinates
                    let logical_x = root.bounds.min_x + (new_pos_x - root.offset_x) / root.scale_factor;
                    let logical_y = root.bounds.min_y + (new_pox_y - root.offset_y) / root.scale_factor;

                    dragged_x = Math.round(logical_x);
                    dragged_y = Math.round(logical_y);
                }

                onReleased: {
                    if (!is_dragging) return;
                    is_dragging = false;

                    root.monitors = root.monitors.map(m => {
                        if (m === modelData || (m.name && m.name === modelData.name)) {
                            return Object.assign({}, m, {
                                position: { x: dragged_x, y: dragged_y }
                            });
                        }
                        return m;
                    });
                }

                Rectangle {
                    anchors.fill: parent

                    color: Qt.alpha(Constants.color_surface, (monitor.containsMouse) ? 1 : 0.5)
                    border.color: (monitor.containsMouse) ? Constants.default_color_accent : Constants.color_base
                    border.width: 1
                    radius: Constants.radius / 2

                    Behavior on color { ColorAnimation { duration: 250 } }
                    Behavior on border.color { ColorAnimation { duration: 250 } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        StyledText {
                            text: `${monitor.name} : ${monitor.model}`.toUpperCase()
                            color: Constants.color_text
                            font.pixelSize: (root.zoomed) ? Constants.font_size / 1.5 : Constants.font_size
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StyledText {
                            text: Math.round(monitor.base_width) + "x" + Math.round(monitor.base_height) + " (" + (monitor.modelData.scale || 1) + "x)"
                            color: Constants.color_subtext
                            font.pixelSize: (root.zoomed) ? Constants.font_size_sm / 1.5 : Constants.font_size_sm
                            anchors.horizontalCenter: parent.horizontalCenter
                        }                        
                    }
                }
            }
        }

        ClickableIcon {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Constants.padding

            padding: (root.zoomed) ? Constants.padding : (Constants.padding / 1.5)

            size: 32
            iconname: "capture-screen.svg"
            radius: Constants.radius

            styles.icon_color_idle: Constants.color_subtext
            styles.icon_color_active: Constants.color_text

            styles.background_color_idle: Qt.alpha(Constants.color_surface, 0.5)
            styles.background_color_active: Qt.alpha(Constants.color_surface, 1)

            onClicked: {
                root.zoomed = !root.zoomed
            }
        }
    }

    // Helper functions for scaling and sizing
    function get_monitor_scale(mon) {
        return (mon.scale && mon.scale > 0) ? mon.scale : 1.0;
    }

    function get_monitor_width(mon) {
        let rawWidth = 1920;
        if (mon.width && mon.width > 0) {
            rawWidth = mon.width;
        } else if (mon.modes) {
            let mode = mon.modes.find(m => m.current) || mon.modes.find(m => m.preferred) || mon.modes[0];
            if (mode) rawWidth = mode.width;
        }
        return rawWidth / get_monitor_scale(mon);
    }

    function get_monitor_height(mon) {
        let rawHeight = 1080;
        if (mon.height && mon.height > 0) {
            rawHeight = mon.height;
        } else if (mon.modes) {
            let mode = mon.modes.find(m => m.current) || mon.modes.find(m => m.preferred) || mon.modes[0];
            if (mode) rawHeight = mode.height;
        }
        return rawHeight / get_monitor_scale(mon);
    }

    Component.onCompleted: DisplayService.all((e) => root.monitors = e)
    
    Connections {
        target: Quickshell
        function onScreensChanged() {
            DisplayService.all((e) => root.monitors = e)
        }
    }
}