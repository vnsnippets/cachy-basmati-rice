pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell.Networking

import qs
import qs.Services
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
            Layout.topMargin: 4
            Layout.bottomMargin: 4

            value: 1.0 - (_ScanTimeout.remaining / _ScanTimeout.interval)
            blink: false
            length: 25
            radius: Constants.radius / 2
            spacing: Constants.spacing / 2

            styles.color_idle: Qt.alpha(Constants.network_color_inactive, 0.5)
            styles.color_active: Constants.network_color_busy
        }


        ClickableButton {
            implicitWidth: 120
            implicitHeight: Constants.size - (Constants.padding / 2)
            
            Layout.maximumHeight: parent.height
            enabled: Networking.wifiEnabled

            colors.accent: (!Networking.wifiEnabled) ? Constants.network_color_inactive :
                           (root.is_scanning) ? Constants.network_color_critical :
                           Constants.network_color_active
            colors.ink: Constants.network_color_ink_active
            text: (root.is_scanning) ? "Stop Scanning" : "Scan Networks"

            onClicked: root.device.scannerEnabled = !root.is_scanning;
        }

        // Power Toggle Button
        ClickableWithIcon {
            readonly property color accent: Constants.network_color_active

            implicitHeight: Constants.size - (Constants.padding / 2)
            implicitWidth: Constants.size - (Constants.padding / 2)

            padding: Constants.padding

            active: Networking.wifiEnabled

            styles.background_color_idle: Constants.color_transparent
            styles.background_color_active: accent

            styles.icon_color_idle: accent
            styles.icon_color_active: Constants.network_color_ink_active

            styles.border_width: 1
            styles.border_color_idle: Qt.alpha(accent, 0.5)
            styles.border_color_active: accent

            iconname: "Power.svg"

            onClicked: {
                if (root.device) root.device.scannerEnabled = false;
                Networking.wifiEnabled = !Networking.wifiEnabled;
            }

            radius: (active) ? Constants.radius_active : Constants.radius
            Behavior on radius { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
        }
    }

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

                required property WifiNetwork modelData

                readonly property bool connected: modelData?.connected ?? false
                readonly property bool state_changing: modelData?.stateChanging ?? false

                readonly property string ssid: modelData?.name || "Unidentified Network"
                readonly property bool is_known: modelData?.known ?? false

                readonly property real signal: modelData?.signalStrength ?? 0
                readonly property bool is_critical: signal <= Constants.network_threshold_critical
                readonly property bool is_warning: signal <= Constants.network_threshold_warning

                property string channel: NetworkService.channels[ssid] ?? ""

                // qmllint disable
                readonly property bool requires_psk: [
                    WifiSecurityType.WpaPsk,
                    WifiSecurityType.Wpa2Psk,
                    WifiSecurityType.Sae
                ].includes(modelData?.security ?? null)
                readonly property string connection_state: (modelData?.state) ? ConnectionState.toString(modelData.state) : ""
                readonly property string security_type: (modelData?.security) ? WifiSecurityType.toString(modelData.security) : ""
                readonly property bool is_secure: ![
                    WifiSecurityType.Open,
                    WifiSecurityType.Owe,
                    WifiSecurityType.Unknown
                ].includes(modelData?.security ?? null)
                // qmllint enable

                // Reset field when network connects or disconnects
                onConnectedChanged: if (connected) pskInputOngoing = false;

                property bool pskInputOngoing: false
                onPskInputOngoingChanged: {
                    _NetworkItemPSKTextField.forceActiveFocus();
                    if (pskInputOngoing) _ScanTimeout.stop();
                    else _ScanTimeout.restart();
                }

                readonly property color accent:
                    (_NetworkItem.is_critical) ? Constants.network_color_critical :
                                            (_NetworkItem.is_warning) ? Constants.network_color_warning :
                                                                   Constants.network_color_active

                function forget() { modelData.forget(); }
                function disconnect() { modelData.disconnect(); }

                function handleConnect() {
                    if (_NetworkItem.connected) {
                        _NetworkItem.disconnect();
                        return;
                    }

                    // If network needs PSK and hasn't opened input box yet
                    if (_NetworkItem.requires_psk && !_NetworkItem.is_known && !_NetworkItem.pskInputOngoing) {
                        _NetworkItem.pskInputOngoing = true;
                        return;
                    }

                    // Submit PSK if input is visible
                    if (_NetworkItem.pskInputOngoing) {
                        if (_NetworkItemPSKTextField.text.length > 0) {
                            modelData.connectWithPsk(_NetworkItemPSKTextField.text);
                        }
                        return;
                    }

                    // Standard open network or already saved network connection
                    modelData.connect();
                }

                color: Constants.network_color_background
                border.color: (connected) ? Qt.alpha(accent, 0.5) : Constants.network_color_border
                border.width: 1

                ColumnLayout {
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
                            Layout.margins: _NetworkItem._padding * 1.25

                            StyledText {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                text: (Constants.network_scramble_ssid) ? NetworkService.scramble(_NetworkItem.ssid) : _NetworkItem.ssid
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

                        Item {
                            Layout.fillHeight: true
                            Layout.preferredWidth: _NetworkItem.pskInputOngoing ? _NetworkItemPSK.implicitWidth : _NetworkItemProperties.implicitWidth

                            Behavior on Layout.preferredWidth {
                                NumberAnimation { duration: Constants.animation_duration; easing.type: Easing.OutCubic }
                            }

                            // Network Properties View (Hides when pskInputOngoing is true)
                            RowLayout {
                                id: _NetworkItemProperties
                                anchors.centerIn: parent
                                spacing: Constants.spacing
                                opacity: _NetworkItem.pskInputOngoing ? 0 : 1
                                scale: _NetworkItem.pskInputOngoing ? 0.9 : 1
                                visible: opacity > 0

                                Behavior on opacity { NumberAnimation { duration: Constants.animation_duration } }
                                Behavior on scale { NumberAnimation { duration: Constants.animation_duration; easing.type: Easing.OutCubic } }

                                StyledText {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    text: `${_NetworkItem.channel} GHz`
                                    color: Constants.network_color_ink_muted
                                    visible: _NetworkItem.channel.length > 0
                                }

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

                                BarControl {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.preferredHeight: 14
                                    Layout.preferredWidth: (height * length) + (spacing * (length - 1))

                                    value: _NetworkItem.signal
                                    blink: false
                                    length: 5
                                    radius: 2
                                    spacing: 2
                                    animation_duration: 50

                                    styles.color_idle: Constants.network_color_inactive
                                    styles.color_active: _NetworkItem.accent
                                }

                                StyledText {
                                    Layout.fillWidth: false
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    Layout.preferredWidth: 36
                                    text: Math.floor(_NetworkItem.signal * 100) + "%"
                                    color: Constants.network_color_ink_muted
                                }

                                ClickableWithIcon {
                                    size: Constants.icon_size * 1.5
                                    padding: 0

                                    styles.icon_color_idle: Constants.network_color_ink_muted
                                    styles.border_width: 0

                                    enabled: false
                                    iconname: "Key.svg"
                                }
                            }

                            RowLayout {
                                id: _NetworkItemPSK
                                anchors.centerIn: parent
                                opacity: _NetworkItem.pskInputOngoing ? 1 : 0
                                scale: _NetworkItem.pskInputOngoing ? 1 : 0.9
                                visible: opacity > 0
                                spacing: Constants.spacing

                                Behavior on opacity { NumberAnimation { duration: Constants.animation_duration } }
                                Behavior on scale { NumberAnimation { duration: Constants.animation_duration; easing.type: Easing.OutCubic } }

                                TextField {
                                    id: _NetworkItemPSKTextField
                                    implicitWidth: 200
                                    implicitHeight: Constants.size - (Constants.padding)
                                    padding: Constants.padding/2
                                    echoMode: TextInput.Password
                                    placeholderText: "Password..."
                                    placeholderTextColor: Constants.network_color_ink_muted
                                    font.family: Constants.font_family
                                    color: Constants.network_color_ink_default

                                    background: Rectangle {
                                        color: Constants.network_color_background
                                        radius: Constants.radius / 2
                                        border.color: _NetworkItemPSKTextField.activeFocus ? Constants.network_color_ink_muted : Constants.network_color_border
                                        border.width: 1
                                    }

                                    onAccepted: _NetworkItem.handleConnect();
                                    Component.onCompleted: {
                                        _NetworkItemPSKTextField.forceActiveFocus();
                                    }
                                }

                                ClickableWithIcon {
                                    readonly property color accent: Constants.network_color_critical

                                    size: (Constants.icon_size * 1.5) - (padding * 2)
                                    padding: Constants.padding / 1.5

                                    styles.background_color_idle: Qt.alpha(accent, 0.2)
                                    styles.background_color_active: Qt.alpha(accent, 1)

                                    styles.icon_color_idle: accent
                                    styles.icon_color_active: Constants.network_color_ink_active

                                    styles.border_width: 1
                                    styles.border_color_idle: Qt.alpha(accent, 0.5)
                                    styles.border_color_active: Qt.alpha(accent, 1)

                                    iconname: "Dismiss.svg"
                                    radius: Constants.radius

                                    onClicked: _NetworkItem.pskInputOngoing = false;
                                }
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
                                        text: (_NetworkItem.connected) ? "Disconnect" : (_NetworkItem.pskInputOngoing ? "Submit" : "Connect")

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
                text: "Not connected to any networks"
                color: Constants.network_color_ink_muted
            }

            Behavior on opacity {
                NumberAnimation { duration: Constants.animation_duration }
            }
        }
    }

    Timer {
        id: _ScanTimeout

        property real starttime: -1
        readonly property int remaining: (running && starttime > 0) ? Math.max(0, interval - (_TimeoutTick.now - starttime)) : interval

        interval: 10000
        running: root.device?.scannerEnabled ?? false

        onTriggered: if (root.device) root.device.scannerEnabled = false
        onRunningChanged: starttime = running ? Date.now() : -1
    }

    Timer {
        id: _TimeoutTick

        property real now: Date.now()
        interval: 50
        running: _ScanTimeout.running
        repeat: true
        onTriggered: now = Date.now()
    }
}