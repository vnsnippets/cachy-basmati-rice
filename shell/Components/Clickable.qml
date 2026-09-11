import QtQuick

import Quickshell.Widgets

WrapperMouseArea {
    id: clickable
    readonly property int _animationDuration: 150

    hoverEnabled: true
    cursorShape: this.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

    onPressed: scale = 0.98
    onReleased: scale = 1.0

    Behavior on scale { NumberAnimation { duration: clickable._animationDuration; } }
}