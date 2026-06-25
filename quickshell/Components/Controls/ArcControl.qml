import QtQuick
import QtQuick.Shapes

import qs.Utilities
import qs.Components

Rectangle {
    id: root

    property bool showText: false

    property real target: 0
    property real value: 0

    property var stroke: 4
    property var center: (this.implicitHeight / 2)

    property color arcColor: Styles.colors.text
    property color trackColor: Styles.colors.subtext

    NumberAnimation on value {
        from: 0
        to: root.target.toFixed(0)
        duration: 800
        easing.type: Easing.OutCubic 
    }

    color: "transparent"

    Shape {
        // High samples for smooth rounded edges on CachyOS
        layer.enabled: true
        layer.samples: 6

        // Arc track
        ShapePath {
            fillColor: "transparent"
            strokeColor: root.trackColor
            strokeWidth: root.stroke

            PathAngleArc {
                centerX: root.center; centerY: root.center;
                radiusX: root.center - root.stroke; radiusY: root.center - root.stroke;
                startAngle: 0
                sweepAngle: 360
            }
        }

        // Animated arc based on value and target
        ShapePath {
            fillColor: "transparent"
            strokeColor: root.arcColor
            strokeWidth: root.stroke
            
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.center; centerY: root.center;
                radiusX: root.center - root.stroke; radiusY: root.center - root.stroke;
                startAngle: -90
                sweepAngle: 360 * (root.value / 100)
            }
        }
    }

    StyledText {
        visible: root.showText
        anchors.centerIn: parent
        text: root.value.toFixed(0) + "%"
        font.pixelSize: 12
        color: root.arcColor
    }
}