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

    width: size - (padding * 2)
    height: size - (padding * 2)

    icon.width: width
    icon.height: height
    icon.color: tint
    icon.source: (_path.length > 0) ? Qt.resolvedUrl(_path) : ""

    background: null

    Behavior on icon.color { ColorAnimation { duration: Constants.animation_duration } }
    enabled: false
}