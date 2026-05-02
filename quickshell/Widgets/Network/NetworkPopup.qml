pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs
import qs.Styles
import qs.Widgets
import qs.Widgets.Network.Components

Popup {
    id: root

    Column {
        anchors.centerIn: parent
        spacing: Style.popup.spacing

        NetworkControl { Layout.fillWidth: true }
    }    
}