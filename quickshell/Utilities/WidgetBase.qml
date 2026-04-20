import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs
import qs.Style

Rectangle {
    id: container

    property string icon: ""
    property string label: ""
    property string tooltip: ""
    property bool interactive: true


    property QtObject locks: QtObject {
        property bool hover: false
        property bool pressed: false
    }

    property ClickableStyle style: ClickableStyle {}
    
    signal clicked()
    signal doubleClicked()
    signal scrolled(var wheel)

    scale: 1.0
    color: style.background.idle
    border.color: style.border.idle
    border.width: Theme.border
    radius: height / Theme.roundness
    Layout.preferredHeight: Theme.size
    implicitWidth: label === "" ? Theme.size : content.width + Theme.padding
    width: implicitWidth

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: Theme.spacing

        Text {
            id: icontext
            text: icon
            color: container.style.foreground.idle
            font.pixelSize: Theme.font_size
            font.family: Theme.font_family
            visible: text !== ""
            Layout.margins: 0
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            id: labeltext
            text: label
            color: container.style.foreground.idle
            font.pixelSize: Theme.font_size
            font.family: Theme.font_family
            visible: text !== ""
            Layout.margins: 0
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: interactive ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: if (interactive) container.clicked()
        onDoubleClicked: if (interactive) container.doubleClicked()
        onWheel: (wheel) => { if (interactive) container.scrolled(wheel) }

        onPressed: if (interactive) container.state = "pressed"
        onReleased: if (interactive) container.state = "hover"
        onEntered: if (interactive) container.state = "hover"
        onExited: container.state = "idle"
    }

    // --- states ---
    states: [
        State {
            name: "idle"
            PropertyChanges { target: container; scale: 1.0; color: style.background.idle; border.color: style.border.idle }
            PropertyChanges { target: icontext; color: container.style.foreground.idle }
            PropertyChanges { target: labeltext; color: container.style.foreground.idle }
        },
        State {
            name: "hover"
            PropertyChanges { target: container; scale: 0.96; color: style.background.active; border.color: style.border.active }
            PropertyChanges { target: icontext; color: container.style.foreground.active }
            PropertyChanges { target: labeltext; color: container.style.foreground.active }
        },
        State {
            name: "pressed"
            PropertyChanges { target: container; scale: 0.94; color: style.background.active; border.color: style.border.active }
            PropertyChanges { target: icontext; color: container.style.foreground.active }
            PropertyChanges { target: labeltext; color: container.style.foreground.active }
        }
    ]

    // --- Transitions ---
    transitions: [
        Transition {
            from: "*"
            to: "*"
            ParallelAnimation {
                NumberAnimation { properties: "scale"; duration: Theme.duration; easing.type: Easing.OutCubic }
                ColorAnimation { properties: "color"; duration: Theme.duration; easing.type: Easing.OutCubic }
                ColorAnimation { properties: "border.color"; duration: Theme.duration; easing.type: Easing.OutCubic }
                ColorAnimation { properties: "color"; target: icontext; duration: Theme.duration; easing.type: Easing.OutCubic }
                ColorAnimation { properties: "color"; target: labeltext; duration: Theme.duration; easing.type: Easing.OutCubic }
            }
        }
    ]

    Behavior on width {
        SpringAnimation {
            spring: 15      // stiffness of the spring
            damping: 0.25   // how quickly it settles
        }
    }

    Component.onCompleted: container.state = "idle"
}