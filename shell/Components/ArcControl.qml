pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

import qs

Item {
    id: root

    // External target ratio (0.0 to 1.0)
    property real ratio: 1.0

    // Internal property driven during initial load and live updates
    property real animatedRatio: 0.0

    property real stroke: 2
    
    property color arcColor: Constants.color_text
    property color trackColor: Constants.color_overlay

    implicitWidth: 16
    implicitHeight: 16

    readonly property real center: width / 2

    // Initial render animation from 0.0 to starting ratio
    NumberAnimation {
        id: _EntryAnim
        target: root
        property: "animatedRatio"
        from: 0.0
        to: root.ratio
        duration: 300
        easing.type: Easing.OutCubic
        onFinished: {
            // Bind directly to ratio prop once initial render animation completes
            root.animatedRatio = Qt.binding(() => root.ratio)
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
            strokeColor: root.trackColor
            strokeWidth: root.stroke

            PathAngleArc {
                centerX: root.center
                centerY: root.center
                radiusX: root.center - root.stroke
                radiusY: root.center - root.stroke
                startAngle: 0
                sweepAngle: 360
            }
        }

        // Active Arc
        ShapePath {
            fillColor: "transparent"
            strokeColor: root.arcColor
            strokeWidth: root.stroke
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.center
                centerY: root.center
                radiusX: root.center - root.stroke
                radiusY: root.center - root.stroke
                startAngle: -90
                sweepAngle: 360 * Math.max(0, Math.min(1, root.animatedRatio))
            }
        }
    }
}