import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs

Rectangle {
    id: container
    readonly property int defaultSize: 40
    readonly property int defaultHPadding: 24
    readonly property int defaultBorderWidth: 1
    readonly property int defaultBorderRoundness: 3
    readonly property int defaultSpacing: 4

    property string icon: ""
    property string label: ""
    property string tooltip: ""
    property bool interactive: true


    property QtObject locks: QtObject {
        property bool hover: false
        property bool pressed: false
    }

    property QtObject colors: QtObject {
        property QtObject background: QtObject {
            property color idle: Theme.background.idle
            property color hover: Theme.background.hover
            property color active: Theme.background.active
        }
        property QtObject foreground: QtObject {
            property color idle: Theme.foreground.idle
            property color hover: Theme.foreground.hover
            property color active: hover
        }
        property QtObject border: QtObject {
            property color idle: Theme.border.idle
            property color hover: Theme.border.hover
            property color active: hover
        }
    }

    property QtObject fonts: QtObject {
        property int size: 14
        property string family: "JetBrainsMono Nerd Font"
    }
    
    signal clicked()
    signal doubleClicked()
    signal scrolled(var wheel)

    scale: locks.pressed ? 0.94 : (locks.hover ? 0.96 : 1.0)
    color: locks.hover ? colors.background.hover : colors.background.idle
    border.color: locks.pressed ? colors.border.active : (locks.hover ? colors.border.hover : colors.border.idle)

    Layout.preferredHeight: defaultSize
    implicitWidth: label === "" ? defaultSize : content.width + defaultHPadding
    radius: height / defaultBorderRoundness
    border.width: defaultBorderWidth

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: defaultSpacing

        Text { 
            id: icontext
            text: icon
            color: locks.pressed ? colors.foreground.active : 
                (locks.hover ? colors.foreground.hover : colors.foreground.idle)
            font.pixelSize: fonts.size
            font.family: fonts.family
            visible: text !== ""
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text { 
            id: labeltext
            text: label
            color: locks.pressed ? colors.foreground.active : 
                (locks.hover ? colors.foreground.hover : colors.foreground.idle)
            font.pixelSize: fonts.size
            font.family: fonts.family
            visible: text !== ""
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        hoverEnabled: true

        onPressed: if (interactive) container.locks.pressed = true
        onReleased: container.locks.pressed = false
        
        onClicked: if (interactive) container.clicked()
        onDoubleClicked: if (interactive) container.doubleClicked()
        
        onEntered: if (interactive) container.locks.hover = true
        onExited: {
            container.locks.hover = false
            container.locks.pressed = false
        }

        onWheel: (e) => {
            if (interactive) container.scrolled(e)
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }
}