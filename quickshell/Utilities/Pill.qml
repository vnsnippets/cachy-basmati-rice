import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Rectangle {
    id: container
    property string iconText: ""
    property string labelText: ""
    property string tooltipText: ""

    property bool hoverLock: false

    property var onScroll: (event) => {}

    property color backgroundColor: "#000000"
    property color foregroundColor: "#FFFFFF"
    property color borderColor: "#FFFFFF"

    property int fontSize: 14
    property string fontFamily: "JetBrainsMono Nerd Font"
    
    signal clicked()
    signal doubleClicked()
                        
    color: backgroundColor
    border.color: borderColor
    Layout.preferredHeight: 40
    implicitWidth: pillRow.width + 24
    radius: height / 3
    border.width: 1

    Row {
        id: pillRow
        anchors.centerIn: parent
        spacing: 6
        Text { text: iconText; color: foregroundColor; font.pixelSize: fontSize; visible: text !== "" }
        Text { text: labelText; color: foregroundColor; font.pixelSize: fontSize; visible: text !== "" }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: () => { 
            container.clicked()
        }
        onDoubleClicked: container.doubleClicked()
        onEntered: () => {
            container.hoverLock = true
        }
        onExited: () => {
            container.hoverLock = false
        }

        onWheel: (wheel) => container.onScroll(wheel)
    }

    scale: hoverLock ? 0.96 : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }
}