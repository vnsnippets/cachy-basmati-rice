import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs
import qs.Style

Rectangle {
    id: container

    default property alias content: content_container.data

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
    width: implicitWidth

    implicitWidth: label === "" ? Theme.size : content.width + Theme.padding

    Layout.preferredHeight: Theme.size

    RowLayout {
        id: content
        anchors.centerIn: parent

        RowLayout {
            spacing: Theme.spacing

            Text {
                id: icon_text
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
                id: label_text
                text: label
                color: container.style.foreground.idle
                font.pixelSize: Theme.font_size
                font.family: Theme.font_family
                visible: text !== ""
                Layout.margins: 0
                Layout.alignment: Qt.AlignVCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        RowLayout {
            id: content_container
            visible: children.length > 0 && children.some((c) => c.width > 0)
            spacing: Theme.spacing
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: (interactive) ? Qt.PointingHandCursor : Qt.ArrowCursor

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
            PropertyChanges { target: icon_text; color: container.style.foreground.idle }
            PropertyChanges { target: label_text; color: container.style.foreground.idle }
        },
        State {
            name: "hover"
            PropertyChanges { target: container; scale: 0.96; color: style.background.active; border.color: style.border.active }
            PropertyChanges { target: icon_text; color: container.style.foreground.active }
            PropertyChanges { target: label_text; color: container.style.foreground.active }
        },
        State {
            name: "pressed"
            PropertyChanges { target: container; scale: 0.94; color: style.background.active; border.color: style.border.active }
            PropertyChanges { target: icon_text; color: container.style.foreground.active }
            PropertyChanges { target: label_text; color: container.style.foreground.active }
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
                ColorAnimation { properties: "color"; target: icon_text; duration: Theme.duration; easing.type: Easing.OutCubic }
                ColorAnimation { properties: "color"; target: label_text; duration: Theme.duration; easing.type: Easing.OutCubic }
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