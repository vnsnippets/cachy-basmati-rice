import QtQuick
import QtQuick.Layouts

import Quickshell

import NetworkMonitorPlugin

import qs
import qs.Styles
import qs.Controls
import qs.Utilities

/**
* 0  (NM_STATE_UNKNOWN):          Networking state is unknown.
* 10 (NM_STATE_ASLEEP):           Networking is not enabled - System may be suspended or resuming.
* 20 (NM_STATE_DISCONNECTED):     There is no active network connection.
* 30 (NM_STATE_DISCONNECTING):    Network connections are currently being cleaned up.
* 40 (NM_STATE_CONNECTING):       A network connection is being started.
* 50 (NM_STATE_CONNECTED_LOCAL):  Connected to a local network, but not the Internet.
* 60 (NM_STATE_CONNECTED_SITE):   Connected to a site (e.g., behind a captive portal).
* 70 (NM_STATE_CONNECTED_GLOBAL): Connected to the Internet.
*/

ColumnLayout {
    id: root
    spacing: Style.panel.spacing

    CurrentNetwork { Layout.fillWidth: true }
    ScanNetworks { Layout.fillWidth: true }
}