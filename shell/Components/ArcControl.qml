pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

import qs

Item {
    id: control

    // External target ratio (0.0 to 1.0)
    property real ratio: 1.0

    // Internal property driven during initial load and live updates
    property real animatedRatio: 0.0
    property real stroke: 2

    component ColorStyles: QtObject {
        property color arc: "#a6adc8"
        property color track: "#313244"
    }
    
    property ColorStyles colors: ColorStyles {}

    implicitWidth: 16
    implicitHeight: 16

    readonly property real center: width / 2

    // Initial render animation from 0.0 to starting ratio
    NumberAnimation {
        id: _EntryAnim
        target: control
        property: "animatedRatio"
        from: 0.0
        to: control.ratio
        duration: 300
        easing.type: Easing.OutCubic
        onFinished: {
            // Bind directly to ratio prop once initial render animation completes
            control.animatedRatio = Qt.binding(() => control.ratio)
        }
    }

    Component.onCompleted: _EntryAnim.start()

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 20

        // Track Background
        ShapePath {
            fillColor: "transparent"
            strokeColor: control.colors.track
            strokeWidth: control.stroke

            PathAngleArc {
                centerX: control.center
                centerY: control.center
                radiusX: control.center - control.stroke
                radiusY: control.center - control.stroke
                startAngle: 0
                sweepAngle: 360
            }
        }

        // Active Arc
        ShapePath {
            fillColor: "transparent"
            strokeColor: control.colors.arc
            strokeWidth: control.stroke
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: control.center
                centerY: control.center
                radiusX: control.center - control.stroke
                radiusY: control.center - control.stroke
                startAngle: -90
                sweepAngle: 360 * Math.max(0, Math.min(1, control.animatedRatio))
            }
        }
    }
}