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
        sourceComponent: (root.page_size > 0) ? _NetworksFoundComponent : _NoNetworkComponent
    }

    Component {
        id: _NetworksFoundComponent
        ListView {
            id: _ListViewNetworks
            Layout.fillWidth: true

            implicitHeight: root.capped_height
            Layout.preferredHeight: root.capped_height

            spacing: Constants.spacing
            clip: true

            model: root.device?.networks?.values ?? []

            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOff; }

            delegate: StyledBox {
                id: _NetworkItem
                width: _ListViewNetworks.width
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

                readonly property color accent: Constants.network_color_active

                function forget() { modelData.forget(); }
                function disconnect() { modelData.disconnect(); }
                function connect() { modelData.connect(); }

                function handleConnect() {
                    if (_NetworkItem.connected) {
                        _NetworkItem.disconnect();
                    } else {
                        _NetworkItem.connect();
                    }
                }

                color: Constants.network_color_background
                border.color: (connected) ? Qt.alpha(accent, 0.5) : Constants.network_color_border
                border.width: 1

                ColumnLayout {
                    id: _NetworkItemDetails
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    RowLayout {
                        Layout.fillWidth: true

                        Column {
                            spacing: 1
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            Layout.margins: _NetworkItem._padding * 1.25

                            StyledText {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                text: _NetworkItem.name
                                color: _NetworkItem.connected ? _NetworkItem.accent : Constants.network_color_ink_default
                                elide: Text.ElideRight
                            }

                            StyledText {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                text: _NetworkItem.connection_state
                                color: Constants.network_color_ink_muted
                                font.pixelSize: Constants.font_size - 1
                                // qmllint disable
                                visible: _NetworkItem.modelData?.state !== ConnectionState.Disconnected
                                // qmllint enable
                            }
                        }

                        RowLayout {
                            spacing: Constants.spacing
                            Layout.fillHeight: true

                            ClickableWithIcon {
                                size: Constants.font_size_lg
                                padding: 0

                                enabled: _NetworkItem.is_known
                                styles.icon_color_idle: Constants.network_color_ink_muted
                                styles.icon_color_active: (enabled) ? Constants.network_color_ink_default : Constants.network_color_ink_muted
                                iconname: (enabled) ? "Tag-Filled.svg" : "Tag-Outline.svg"
                                opacity: enabled ? 1 : 0.4
                                onClicked: _NetworkItem.forget()
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
                                color: Constants.network_color_ink_muted
                            }
                        }

                        RowLayout {
                            spacing: Constants.spacing
                            Layout.fillHeight: true
                            Layout.rightMargin: _NetworkItem._padding * 1.25

                            Loader {
                                Layout.preferredWidth: implicitWidth
                                Layout.alignment: Qt.AlignVCenter

                                sourceComponent: (_NetworkItem.state_changing) ? _BusyActionComponent : _ConnectActionComponent

                                Component {
                                    id: _ConnectActionComponent

                                    ClickableButton {
                                        implicitWidth: 96
                                        Layout.fillHeight: true

                                        topPadding: Constants.padding / 1.5
                                        bottomPadding: Constants.padding / 1.5

                                        colors.accent: (_NetworkItem.connected) ? Constants.network_color_critical : Constants.network_color_active
                                        colors.ink: Constants.network_color_ink_active
                                        text: (_NetworkItem.connected) ? "Disconnect" : "Connect"

                                        onClicked: _NetworkItem.handleConnect()
                                    }
                                }

                                Component {
                                    id: _BusyActionComponent
                                    Item {
                                        id: _BusyBox
                                        implicitWidth: 96
                                        Layout.fillHeight: true
                                        Layout.margins: Constants.padding / 1.5
                                        Layout.leftMargin: Constants.padding
                                        Layout.rightMargin: Constants.padding

                                        Rectangle {
                                            id: _BusyBoxBall
                                            anchors.verticalCenter: parent.verticalCenter

                                            implicitHeight: 10
                                            implicitWidth: implicitHeight

                                            color: Constants.network_color_busy
                                            radius: implicitHeight

                                            readonly property real min_x: Constants.padding
                                            readonly property real max_x: _BusyBox.width - _BusyBoxBall.width - Constants.padding

                                            SequentialAnimation on x {
                                                loops: Animation.Infinite
                                                running: true

                                                NumberAnimation {
                                                    from: _BusyBoxBall.min_x
                                                    to: _BusyBoxBall.max_x
                                                    duration: Constants.animation_duration * 2
                                                    easing.type: Easing.InOutQuad
                                                }

                                                NumberAnimation {
                                                    from: _BusyBoxBall.max_x
                                                    to: _BusyBoxBall.min_x
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
        id: _NoNetworkComponent
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: _NoNetworkLabel.implicitHeight + Constants.padding * 3
            radius: Constants.radius
            color: Qt.alpha(Constants.network_color_inactive, 0.15)
            border.width: 1
            border.color: Constants.network_color_inactive

            StyledText {
                id: _NoNetworkLabel
                leftPadding: Constants.padding * 1.5
                rightPadding: Constants.padding * 1.5
                anchors.verticalCenter: parent.verticalCenter
                text: "No ethernet cable connected"
                color: Constants.network_color_ink_muted
            }

            Behavior on opacity {
                NumberAnimation { duration: Constants.animation_duration }
            }
        }
    }
}