pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell.Networking

import qs
import qs.Components

ColumnLayout {
    id: root
    spacing: Constants.spacing

    required property WifiDevice device
    readonly property bool is_scanning: device?.scannerEnabled ?? false

    readonly property int item_height: Constants.size * 1.5

    property int page_size: Math.min(5, device?.networks?.values.length ?? 0)
    readonly property int capped_height: (item_height * page_size) + (Constants.spacing * Math.max(0, page_size - 1))

    RowLayout {
        Layout.fillWidth: true
        spacing: Constants.spacing

        BarControl {
            Layout.fillWidth: true
            Layout.fillHeight: true

            value: 1.0 - (timeout_scan.remaining / timeout_scan.interval)
            blink: false
            length: 25
            radius: Constants.radius / 2
            spacing: Constants.spacing / 2

            styles.color_idle: Constants.default_background
            styles.color_active: Constants.default_color_accent
        }

        ClickableWithIcon {
            implicitHeight: Constants.size - (Constants.padding / 2)
            padding: Constants.padding

            readonly property color accent_color: (root.is_scanning) ?  Constants.network_device_color_action_disconnect : Constants.network_device_color_action_connect

            styles.background_color_idle: Constants.color_transparent
            styles.background_color_active: accent_color

            styles.border_width: 1
            styles.border_color_idle: Qt.alpha(accent_color, 0.5)
            styles.border_color_active: Qt.alpha(accent_color, 1)

            palette.buttonText: (hovered || active) ? Constants.network_device_color_action_text_active : accent_color

            font.family: Constants.font_family
            text: (root.is_scanning) ? "Stop Scanning" : "Scan Networks"

            radius: Constants.radius

            onClicked: root.device.scannerEnabled = !root.is_scanning;
        }
    }

    Loader {
        Layout.fillWidth: true
        sourceComponent: (root.page_size > 0) ? component_with_networks : component_no_network
    }

    Component {
        id: component_with_networks
        ListView {
            id: network_list
            Layout.fillWidth: true

            implicitHeight: root.capped_height
            Layout.preferredHeight: root.capped_height

            spacing: Constants.spacing
            clip: true

            model: root.device?.networks?.values ?? []

            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOff; }

            delegate: StyledBox {
                id: network
                width: ListView.view.width
                radius: Constants.radius

                readonly property int _padding: Constants.padding

                implicitHeight: root.item_height

                required property WifiNetwork modelData

                readonly property bool is_connected: modelData?.connected ?? false
                readonly property bool state_changing: modelData?.stateChanging ?? false

                readonly property string ssid: modelData?.name || "Unidentified Network"
                readonly property bool is_known: modelData?.known ?? false
                readonly property bool connected: modelData?.connected ?? false

                readonly property real signal: modelData?.signalStrength ?? 0
                readonly property bool is_critical: signal <= Constants.network_threshold_critical
                readonly property bool is_warning: signal <= Constants.network_threshold_warning

                // qmllint disable
                readonly property string connection_state: (modelData?.state) ? ConnectionState.toString(modelData.state) : ""
                readonly property string security_type: (modelData?.security) ? WifiSecurityType.toString(modelData.security) : ""
                readonly property bool is_secure: ![
                    WifiSecurityType.Open,
                    WifiSecurityType.Owe,
                    WifiSecurityType.Unknown
                ].includes(modelData?.security ?? null)
                // qmllint enable

                readonly property color accent_color:
                    (network.is_critical) ? Constants.network_color_critical :
                                            (network.is_warning) ? Constants.network_color_warning :
                                                                Constants.network_device_color_connected

                color: Constants.network_device_color_background
                border.color: (is_connected) ? Qt.alpha(accent_color, 0.5) : Constants.network_device_color_border
                border.width: 1

                ColumnLayout {
                    id: network_content
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    // Network SSID and Strength
                    RowLayout {
                        Layout.fillWidth: true

                        Column {
                            spacing: 1
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            Layout.margins: network._padding * 1.25

                            StyledText {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                text: network.ssid
                                color: network.is_connected ? network.accent_color : Constants.network_device_color_text
                                elide: Text.ElideRight
                            }

                            StyledText {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                text: network.connection_state
                                color: Constants.network_device_color_subtext
                                font.pixelSize: Constants.font_size - 1
                                // qmllint disable
                                visible: network.modelData?.state !== ConnectionState.Disconnected
                                // qmllint enable
                            }
                        }

                        RowLayout {
                            spacing: Constants.spacing
                            Layout.fillHeight: true
                            Layout.margins: network._padding * 1.25

                            ClickableWithIcon {
                                size: Constants.font_size_lg
                                padding: 0

                                enabled: network.is_known
                                styles.icon_color_idle: Constants.network_device_color_subtext
                                styles.icon_color_active: (enabled) ? Constants.network_device_color_text : Constants.network_device_color_subtext
                                iconname: (enabled) ? "bookmark-filled.svg" : "bookmark-outline.svg"
                                opacity: enabled ? 1 : 0.4
                                onClicked: network.modelData.forget()
                            }

                            BarControl {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.preferredHeight: 14
                                Layout.preferredWidth: (height * length) + (spacing * (length - 1))

                                value: network.signal
                                blink: false
                                length: 5
                                radius: 2
                                spacing: 2
                                animation_duration: 50

                                styles.color_idle: Constants.network_device_color_disconnected
                                styles.color_active: network.accent_color
                            }

                            StyledText {
                                Layout.fillWidth: false
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                Layout.preferredWidth: 36
                                text: Math.floor(network.signal * 100) + "%"
                                color: Constants.network_device_color_subtext
                            }

                            Loader {
                                active: network.is_secure
                                sourceComponent: ClickableWithIcon {
                                    size: Constants.icon_size * 1.5
                                    padding: 0

                                    styles.icon_color_idle: Constants.network_device_color_subtext
                                    styles.border_width: 0

                                    enabled: false
                                    iconname: "key.svg"
                                }
                            }

                            Loader {
                                Layout.preferredWidth: implicitWidth
                                Layout.alignment: Qt.AlignVCenter

                                sourceComponent: (network.state_changing) ? action_busy :
                                                    (network.is_connected) ? action_disconnect : action_connect

                                Component {
                                    id: action_disconnect
                                    ClickableWithIcon {
                                        implicitWidth: 96
                                        Layout.fillHeight: true

                                        padding: Constants.padding / 1.5
                                        leftPadding: Constants.padding
                                        rightPadding: Constants.padding

                                        styles.background_color_idle: Qt.alpha(Constants.network_device_color_action_disconnect, 0.2)
                                        styles.background_color_active: Qt.alpha(Constants.network_device_color_action_disconnect, 1)

                                        styles.icon_color_idle: Constants.network_device_color_action_disconnect
                                        styles.icon_color_active: Constants.network_device_color_action_text_active

                                        styles.border_width: 1
                                        styles.border_color_idle: Qt.alpha(Constants.network_device_color_action_disconnect, 0.5)
                                        styles.border_color_active: Qt.alpha(Constants.network_device_color_action_disconnect, 1)

                                        palette.buttonText: (hovered || active) ? Constants.network_device_color_action_text_active : Constants.network_device_color_action_disconnect

                                        font.family: Constants.font_family
                                        text: "Disconnect"

                                        radius: Constants.radius

                                        onClicked: network.modelData.disconnect()
                                    }
                                }

                                Component {
                                    id: action_connect
                                    ClickableWithIcon {
                                        implicitWidth: 96
                                        Layout.fillHeight: true

                                        padding: Constants.padding / 1.5
                                        leftPadding: Constants.padding
                                        rightPadding: Constants.padding

                                        styles.background_color_idle: Qt.alpha(Constants.network_device_color_action_connect, 0.2)
                                        styles.background_color_active: Qt.alpha(Constants.network_device_color_action_connect, 1)

                                        styles.icon_color_idle: Constants.network_device_color_action_connect
                                        styles.icon_color_active: Constants.network_device_color_action_text_active

                                        styles.border_width: 1
                                        styles.border_color_idle: Qt.alpha(Constants.network_device_color_action_connect, 0.5)
                                        styles.border_color_active: Qt.alpha(Constants.network_device_color_action_connect, 1)

                                        palette.buttonText: (hovered || active) ? Constants.network_device_color_action_text_active : Constants.network_device_color_action_connect

                                        font.family: Constants.font_family
                                        text: "Connect"

                                        radius: Constants.radius

                                        onClicked: network.modelData.connect()
                                    }
                                }

                                Component {
                                    id: action_busy
                                    Item {
                                        id: busy_box
                                        implicitWidth: 96
                                        Layout.fillHeight: true
                                        Layout.margins: Constants.padding / 1.5
                                        Layout.leftMargin: Constants.padding
                                        Layout.rightMargin: Constants.padding

                                        Rectangle {
                                            id: rect_ball
                                            // Anchor vertically only so 'x' can animate freely
                                            anchors.verticalCenter: parent.verticalCenter

                                            implicitHeight: 10
                                            implicitWidth: implicitHeight

                                            color: Constants.network_device_color_action_busy
                                            radius: implicitHeight

                                            // Oscillation travel parameters
                                            readonly property real min_x: Constants.padding
                                            readonly property real max_x: busy_box.width - rect_ball.width - Constants.padding

                                            // Continuous left-to-right bounce
                                            SequentialAnimation on x {
                                                loops: Animation.Infinite
                                                running: true

                                                NumberAnimation {
                                                    from: rect_ball.min_x
                                                    to: rect_ball.max_x
                                                    duration: Constants.animation_duration * 2
                                                    easing.type: Easing.InOutQuad
                                                }

                                                NumberAnimation {
                                                    from: rect_ball.max_x
                                                    to: rect_ball.min_x
                                                    duration: Constants.animation_duration * 2
                                                    easing.type: Easing.InOutQuad
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: component_no_network
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: no_network_label.implicitHeight + Constants.padding * 3
            radius: Constants.radius
            color: Qt.alpha(Constants.network_device_color_nonetwork_background, 0.15)
            border.width: 1
            border.color: Constants.network_device_color_nonetwork_background

            StyledText {
                id: no_network_label
                leftPadding: Constants.padding * 1.5
                rightPadding: Constants.padding * 1.5
                anchors.verticalCenter: parent.verticalCenter
                text: "Not connected to any networks"
                color: Constants.network_device_color_nonetwork_text
            }

            Behavior on opacity {
                NumberAnimation { duration: Constants.animation_duration }
            }
        }
    }

    Timer {
        id: timeout_scan

        property real starttime: -1
        readonly property int remaining: (running && starttime > 0) ? Math.max(0, interval - (timeout_tick.now - starttime)) : interval

        interval: 10000
        running: root.device?.scannerEnabled ?? false

        onTriggered: if (root.device) root.device.scannerEnabled = false
        onRunningChanged: starttime = running ? Date.now() : -1
    }

    Timer {
        id: timeout_tick
        property real now: Date.now()
        interval: 50
        running: timeout_scan.running
        repeat: true
        onTriggered: now = Date.now()
    }
}