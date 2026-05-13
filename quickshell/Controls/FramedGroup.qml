pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.Styles

Rectangle {
    id: root

    default property alias content: masterLayout.data
    property alias spacing: masterLayout.spacing

    property int offset: 8

    radius: Style.clickable.radius

    implicitWidth: masterLayout.width + offset
    implicitHeight: masterLayout.height + offset

    RowLayout {
        id: masterLayout
        anchors.centerIn: parent
    }
}