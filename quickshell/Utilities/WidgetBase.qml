import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs
import qs.Style

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

    property ClickableStyle style: ClickableStyle {}
    
    signal clicked()
    signal doubleClicked()
    signal scrolled(var wheel)

    scale: locks.pressed ? 0.94 : (locks.hover ? 0.96 : 1.0)
    color: locks.hover ? style.background.hover : style.background.idle
    border.color: locks.pressed ? style.border.active : (locks.hover ? style.border.hover : style.border.idle)

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
            color: locks.pressed ? container.style.foreground.active : 
                (locks.hover ? container.style.foreground.hover : container.style.foreground.idle)
            font.pixelSize: Theme.font_size
            font.family: Theme.font_family
            visible: text !== ""
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text { 
            id: labeltext
            text: label
            color: locks.pressed ? container.style.foreground.active : 
                (locks.hover ? container.style.foreground.hover : container.style.foreground.idle)
            font.pixelSize: Theme.font_size
            font.family: Theme.font_family
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