pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import Quickshell

import qs

Button {
    id: clickable

    required property int size
    required property string source
    required property color tint

    readonly property string _path: (`${Quickshell.shellDir}/${Constants.icons_directory}/${source}`).replace("//", "/")

    hoverEnabled: true
    antialiasing: true
    smooth: true

    padding: 0

    icon.width: size
    icon.height: size
    icon.color: tint
    icon.source: (_path.length > 0) ? Qt.resolvedUrl(_path) : ""

    background: null

    Behavior on icon.color { ColorAnimation { duration: Constants.animation_duration } }
    enabled: false
}