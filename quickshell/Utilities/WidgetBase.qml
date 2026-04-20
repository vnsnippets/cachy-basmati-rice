import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs
import qs.Style

Rectangle {
    id: container
    readonly property int defaultSize: 38
    readonly property int defaultHPadding: 24
    readonly property real defaultBorderWidth: 1
    readonly property real defaultBorderRoundness: 3.2
    readonly property int defaultSpacing: 4
    readonly property int defaultTransitionDuration: 250

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
    border.width: defaultBorderWidth
    radius: height / defaultBorderRoundness
    Layout.preferredHeight: defaultSize
    implicitWidth: label === "" ? defaultSize : content.width + defaultHPadding

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: defaultSpacing

        Text {
            id: icontext
            text: icon
            color: container.style.foreground.idle
            font.pixelSize: Theme.font_size
            font.family: Theme.font_family
            visible: text !== ""
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            id: labeltext
            text: label
            color: container.style.foreground.idle
            font.pixelSize: Theme.font_size
            font.family: Theme.font_family
            visible: text !== ""
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
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
            PropertyChanges { target: container; scale: 0.96; color: style.background.hover; border.color: style.border.hover }
            PropertyChanges { target: icontext; color: container.style.foreground.hover }
            PropertyChanges { target: labeltext; color: container.style.foreground.hover }
        },
        State {
            name: "pressed"
            PropertyChanges { target: container; scale: 0.94; color: style.background.active; border.color: style.border.active }
            PropertyChanges { target: icontext; color: container.style.foreground.active }
            PropertyChanges { target: labeltext; color: container.style.foreground.active }
        }
    ]

    // --- transitions ---
    transitions: [
        Transition {
            from: "*"
            to: "*"
            ParallelAnimation {
                NumberAnimation { properties: "scale"; duration: defaultTransitionDuration; easing.type: Easing.OutCubic }
                ColorAnimation { properties: "color"; duration: defaultTransitionDuration; easing.type: Easing.InCubic }
                ColorAnimation { properties: "border.color"; duration: defaultTransitionDuration; easing.type: Easing.OutCubic }
                ColorAnimation { properties: "color"; target: icontext; duration: defaultTransitionDuration; easing.type: Easing.OutCubic }
                ColorAnimation { properties: "color"; target: labeltext; duration: defaultTransitionDuration; easing.type: Easing.OutCubic }
            }
        }
    ]    
}