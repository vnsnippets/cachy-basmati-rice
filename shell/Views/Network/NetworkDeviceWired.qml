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

    required property WiredDevice device

    readonly property int item_height: Constants.size * 1.5

    property int page_size: Math.min(5, device?.networks?.values.length ?? 0)
    readonly property int capped_height: (item_height * page_size) + (Constants.spacing * Math.max(0, page_size - 1))

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

                required property Network modelData

                readonly property bool connected: modelData?.connected ?? false
                readonly property bool state_changing: modelData?.stateChanging ?? false

                readonly property string name: modelData?.name || "Wired Connection"
                readonly property bool is_known: modelData?.known ?? false

                // qmllint disable
                readonly property string connection_state: (modelData?.state) ? ConnectionState.toString(modelData.state) : ""
                // qmllint enable

                readonly property color accent_color: Constants.network_device_color_connected

                function forget() { modelData.forget(); }
                function disconnect() { modelData.disconnect(); }
                function connect() { modelData.connect(); }

                function handleConnect() {
                    if (network.connected) {
                        network.disconnect();
                    } else {
                        network.connect();
                    }
                }

                color: Constants.network_device_color_background
                border.color: (connected) ? Qt.alpha(accent_color, 0.5) : Constants.network_device_color_border
                border.width: 1

                ColumnLayout {
                    id: network_content
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

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
                                text: network.name
                                color: network.connected ? network.accent_color : Constants.network_device_color_text
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
                            id: network_properties
                            spacing: Constants.spacing
                            Layout.fillHeight: true

                            ClickableWithIcon {
                                size: Constants.font_size_lg
                                padding: 0

                                enabled: network.is_known
                                styles.icon_color_idle: Constants.network_device_color_subtext
                                styles.icon_color_active: (enabled) ? Constants.network_device_color_text : Constants.network_device_color_subtext
                                iconname: (enabled) ? "bookmark-filled.svg" : "bookmark-outline.svg"
                                opacity: enabled ? 1 : 0.4
                                onClicked: network.forget()
                            }

                            // Wired Link Speed Indicator
                            StyledText {
                                Layout.fillWidth: false
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                text: {
                                    const speed = root.device?.linkSpeed ?? 0;
                                    if (speed <= 0) return "Disconnected";
                                    return speed >= 1000 ? (speed / 1000) + " Gbps" : speed + " Mbps";
                                }
                                color: Constants.network_device_color_subtext
                            }
                        }

                        RowLayout {
                            spacing: Constants.spacing
                            Layout.fillHeight: true
                            Layout.rightMargin: network._padding * 1.25

                            Loader {
                                Layout.preferredWidth: implicitWidth
                                Layout.alignment: Qt.AlignVCenter

                                sourceComponent: (network.state_changing) ? action_busy : action_connect

                                Component {
                                    id: action_connect

                                    ClickableWithIcon {
                                        implicitWidth: 96
                                        Layout.fillHeight: true

                                        readonly property color accent_color: (network.connected) ? Constants.network_device_color_action_disconnect : Constants.network_device_color_action_connect

                                        padding: Constants.padding / 1.5
                                        leftPadding: Constants.padding
                                        rightPadding: Constants.padding

                                        styles.background_color_idle: Qt.alpha(accent_color, 0.2)
                                        styles.background_color_active: Qt.alpha(accent_color, 1)

                                        styles.icon_color_idle: accent_color
                                        styles.icon_color_active: Constants.network_device_color_action_text_active

                                        styles.border_width: 1
                                        styles.border_color_idle: Qt.alpha(accent_color, 0.5)
                                        styles.border_color_active: Qt.alpha(accent_color, 1)

                                        palette.buttonText: (hovered || active) ? Constants.network_device_color_action_text_active : accent_color

                                        font.family: Constants.font_family
                                        text: (network.connected) ? "Disconnect" : "Connect"

                                        radius: Constants.radius

                                        onClicked: network.handleConnect()
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
                                            anchors.verticalCenter: parent.verticalCenter

                                            implicitHeight: 10
                                            implicitWidth: implicitHeight

                                            color: Constants.network_device_color_action_busy
                                            radius: implicitHeight

                                            readonly property real min_x: Constants.padding
                                            readonly property real max_x: busy_box.width - rect_ball.width - Constants.padding

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
                text: "No ethernet cable connected"
                color: Constants.network_device_color_nonetwork_text
            }

            Behavior on opacity {
                NumberAnimation { duration: Constants.animation_duration }
            }
        }
    }
}