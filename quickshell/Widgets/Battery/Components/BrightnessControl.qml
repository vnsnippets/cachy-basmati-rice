import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs
import qs.Styles
import qs.Utilities

RowLayout {
    spacing: 10
    Text {
        text: ""
        color: Style.color_light
        font.pixelSize: 20
    }
    
    Slider {
        id: sd_root
        Layout.fillWidth: true

        property alias progress_width: progress.width
        readonly property color trackColor: Qt.rgba(1, 1, 1, 0.1)

        // Custom Handle
        handle: Rectangle {
            // x: sd_root.leftPadding + (sd_root.visualPosition * (sd_root.availableWidth - width))
            x: sd_root.progress_width - width
            y: sd_root.topPadding + sd_root.availableHeight / 2 - height / 2

            implicitWidth: 20
            implicitHeight: 20
            radius: sd_root.availableHeight/2.5
            border.width: 1
            border.color: Style.color_blue
            color: Style.color_light
            scale: sd_root.pressed ? 0.8 : 1

            Behavior on scale {
                NumberAnimation {
                    duration: 100;
                    easing: Easing.Linear
                }
            }
        }

        // Custom Background (Progress bar)
        background: Rectangle {
            x: sd_root.leftPadding
            y: sd_root.topPadding + sd_root.availableHeight / 2 - height / 2

            // Static width/height to break the loop
            implicitWidth: 200
            implicitHeight: 20

            width: sd_root.availableWidth
            height: sd_root.availableHeight

            radius: sd_root.availableHeight/2.5
            color: sd_root.trackColor

            Rectangle {
                id: progress

                property bool disable_animation: false

                // Use visualPosition logic for the target width
                readonly property real targetWidth: (sd_root.visualPosition * (parent.width - sd_root.handle.width)) + (sd_root.handle.width)
                
                // If loaded, follow target exactly; if not, wait for animation
                width: targetWidth

                // implicitWidth: (sd_root.visualPosition * (parent.width - sd_root.handle.width)) + (sd_root.handle.width)
                // width: implicitWidth
                height: parent.height
                color: Style.color_blue
                radius: parent.radius

                Behavior on width {
                    enabled: !progress.disable_animation // 3. Only animate while not loaded
                    NumberAnimation {
                        to: progress.targetWidth
                        duration: 600
                        easing.type: Easing.OutCubic // Fast to slow looks better for loading
                        onRunningChanged: {
                            if (!running) progress.disable_animation = true; // 4. Set loaded to true when finished
                        }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            // Required so the MouseArea doesn't steal the slider's drag events
            onPressed: (mouse) => mouse.accepted = false
        }

        onMoved: {
            // Example: Setting brightness via brightnessctl
            Daemon.execute(["brightnessctl", "set", Math.round(value * 100) + "%"])
        }

        Component.onCompleted: {
            Daemon.execute(["sh", "-c", "brightnessctl -m | cut -d, -f4 | tr -d %"], (e) => {
                sd_root.value = parseFloat(e?.output?.trim()) / 100;
            })
        }
    }
}