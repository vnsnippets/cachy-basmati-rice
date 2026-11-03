pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Bluetooth

import qs
import qs.Components

ColumnLayout {
    id: root

    // qmllint disable
    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    property int page_size: Math.min(5, adapter?.devices?.values.length ?? 0)
    // qmllint enable

    readonly property int item_height: Constants.size * 1.5
    readonly property int capped_height: (item_height * page_size) + (Constants.spacing * Math.max(0, page_size - 1))

    RowLayout {
        Layout.topMargin: Constants.padding
        Layout.fillWidth: true

        
        spacing: Constants.spacing

        // Discovery Timer Progress Indicator
        BarControl {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 4
            Layout.bottomMargin: 4

            value: 1.0 - (_DiscoveryTimeout.remaining / _DiscoveryTimeout.interval)
            blink: false
            length: 25
            radius: Constants.radius / 2
            spacing: Constants.spacing / 2

            styles.color_idle: Qt.alpha(Constants.bluetooth_color_inactive, 0.5)
            styles.color_active: Constants.bluetooth_color_busy
        }

        ClickableButton {
            implicitWidth: 108
            Layout.maximumHeight: parent.height
            enabled: root.adapter.enabled
            colors.accent: (root.adapter.discovering) ? Constants.bluetooth_color_critical : Constants.bluetooth_color_active
            colors.muted: Constants.bluetooth_color_inactive
            colors.ink: Constants.bluetooth_color_ink_active
            text: root.adapter.discovering ? "Stop Scan" : "Scan Devices"
            onClicked: {
                if (root.adapter) {
                    root.adapter.discovering = !root.adapter.discovering;
                }
            }
        }

        // Power Toggle Button
        ClickableWithIcon {
            implicitHeight: Constants.size - (Constants.padding / 2)
            implicitWidth: Constants.size - (Constants.padding / 2)
            
            padding: Constants.padding

            active: root.adapter.enabled

            styles.background_color_idle: Constants.color_transparent
            styles.background_color_active: Constants.bluetooth_color_active

            styles.icon_color_idle: Constants.bluetooth_color_active
            styles.icon_color_active: Constants.bluetooth_color_ink_active

            styles.border_width: 1
            styles.border_color_idle: Constants.bluetooth_color_active
            styles.border_color_active: Constants.bluetooth_color_active

            iconname: "Power.svg"

            onClicked: if (root.adapter) {
                root.adapter.discovering = false;
                root.adapter.enabled = !root.adapter.enabled;
            }
            
            radius: (active) ? Constants.radius_active : Constants.radius
            Behavior on radius { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
        }
    }

    Component {
        id: _DevicesFoundComponent
        ListView {
            id: _DevicesListView
            Layout.fillWidth: true

            implicitHeight: root.capped_height
            Layout.preferredHeight: root.capped_height

            spacing: Constants.spacing
            clip: true

            // qmllint disable
            model: root.adapter?.devices?.values ?? []
            // qmllint enable

            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOff; }

            delegate: StyledBox {
                id: _DeviceItem
                width: _DevicesListView.width
                radius: Constants.radius

                readonly property int _padding: Constants.padding * 1.25

                implicitHeight: root.item_height

                required property BluetoothDevice modelData
                
                readonly property string icon: modelData?.icon ?? ""

                readonly property bool connected: modelData?.connected ?? false
                readonly property bool pairing: modelData?.pairing ?? false
                readonly property bool paired: modelData?.paired ?? false
                readonly property string address: modelData?.address ?? ""

                readonly property string device_name: modelData?.name || modelData?.address || "Unknown Device"

                // qmllint disable
                readonly property bool state_changing: (modelData?.state === BluetoothDeviceState.Connecting || modelData?.state === BluetoothDeviceState.Disconnecting)
                readonly property string connection_state: {
                    if (!modelData) return "";
                    switch (modelData.state) {
                        case BluetoothDeviceState.Connected: return "Connected";
                        case BluetoothDeviceState.Connecting: return "Connecting...";
                        case BluetoothDeviceState.Disconnecting: return "Disconnecting...";
                        default: return modelData.paired ? "Paired" : "Available";
                    }
                }
                // qmllint enable

                readonly property color accent: Constants.bluetooth_color_active

                function forget() { modelData.forget(); }
                function disconnect() { modelData.disconnect(); }
                function connect() { modelData.connect(); }
                function pair() { modelData.pair(); }
                function cancel() { modelData.cancelPair(); }

                function clicked() {
                    if (_DeviceItem.pairing)_DeviceItem.cancel()
                    else if (_DeviceItem.connected) _DeviceItem.disconnect();
                    else if (_DeviceItem.paired) _DeviceItem.connect();
                    else {
                        _DeviceItem.modelData.trusted = true
                        // _DeviceItem.pair();
                        Quickshell.execDetached([
                            "foot", "sh", "-c", 
                            `(echo 'agent on'; echo 'default-agent'; echo 'pair ${_DeviceItem.address}'; cat) | bluetoothctl`
                        ]);
                    }
                }

                color: Constants.bluetooth_color_background
                border.color:  (modelData.blocked) ? Qt.alpha(Constants.bluetooth_color_critical, 0.5) :
                    (connected) ? Qt.alpha(accent, 0.5) : Constants.bluetooth_color_border
                border.width: 1

                Behavior on border.color { ColorAnimation { duration: Constants.animation_duration } }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: _DeviceItem._padding
                    anchors.rightMargin: _DeviceItem._padding

                    spacing: Constants.spacing

                    // IconControl {
                    //     size: Constants.icon_size * 1.25
                    //     source: "bluetooth/" + _DeviceItem.icon + ".svg"
                    //     tint: (_DeviceItem.connected) ? Constants.bluetooth_color_active : Constants.bluetooth_color_ink_muted
                    // }

                    Column {
                        spacing: 1
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                        StyledText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            text: _DeviceItem.device_name
                            color: _DeviceItem.connected ? _DeviceItem.accent : Constants.bluetooth_color_ink_default
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            text: _DeviceItem.connection_state + (_DeviceItem.modelData.batteryAvailable ? ` | Battery: ${(_DeviceItem.modelData.battery * 100).toFixed(0)}%` : "") 
                            color: Constants.bluetooth_color_ink_muted
                            font.pixelSize: Constants.font_size - 1
                            visible: _DeviceItem.connection_state !== ""
                        }
                    }

                    Row {
                        id: _DeviceItemStatus
                        spacing: Constants.spacing

                        readonly property color muted: Qt.alpha(Constants.bluetooth_color_ink_muted, 0.5)

                        ClickableWithIcon {
                            Layout.fillHeight: true
                            implicitWidth: implicitHeight

                            active: _DeviceItem.modelData.blocked

                            styles.icon_color_idle: _DeviceItemStatus.muted
                            styles.icon_color_active: Constants.bluetooth_color_critical

                            styles.border_width: 0
                            radius: Constants.radius

                            iconname: "Block.svg"

                            onClicked: _DeviceItem.modelData.blocked = !_DeviceItem.modelData.blocked
                        }

                        ClickableWithIcon {
                            Layout.fillHeight: true
                            implicitWidth: implicitHeight

                            active: _DeviceItem.modelData.wakeAllowed

                            styles.icon_color_idle: _DeviceItemStatus.muted
                            styles.icon_color_active: Constants.bluetooth_color_busy

                            styles.border_width: 0
                            radius: Constants.radius

                            iconname: "Bolt.svg"

                            onClicked: _DeviceItem.modelData.wakeAllowed = !_DeviceItem.modelData.wakeAllowed
                        }

                        ClickableWithIcon {
                            Layout.fillHeight: true
                            implicitWidth: implicitHeight

                            active: _DeviceItem.modelData.trusted

                            styles.icon_color_idle: _DeviceItemStatus.muted
                            styles.icon_color_active: Constants.bluetooth_color_secure

                            styles.border_width: 0
                            radius: Constants.radius

                            iconname: "Shield.svg"

                            onClicked: _DeviceItem.modelData.trusted = !_DeviceItem.modelData.trusted
                        }

                        ClickableWithIcon {
                            Layout.fillHeight: true
                            implicitWidth: implicitHeight

                            active: _DeviceItem.modelData.bonded

                            styles.icon_color_idle: (active) ? Constants.bluetooth_color_saved : _DeviceItemStatus.muted

                            styles.border_width: 0
                            radius: Constants.radius

                            iconname: (active) ? "Tag-Filled.svg" : "Tag-Outline.svg"                          
                            enabled: false
                        }
                    }

                    Row {
                        spacing: Constants.spacing
                        Layout.fillHeight: true
                        Layout.topMargin: _DeviceItem._padding * 2
                        Layout.bottomMargin: _DeviceItem._padding * 2

                        Loader {
                            Layout.preferredWidth: implicitWidth
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignVCenter

                            sourceComponent: (_DeviceItem.state_changing) ? _BusyActionComponent : _ConnectActionComponent

                            Component {
                                id: _ConnectActionComponent

                                ClickableButton {
                                    implicitWidth: 84

                                    topPadding: Constants.padding / 1.5
                                    bottomPadding: Constants.padding / 1.5

                                    colors.accent: (_DeviceItem.connected) ? Constants.bluetooth_color_critical : Constants.bluetooth_color_active
                                    colors.ink: Constants.bluetooth_color_ink_active
                                    text: (_DeviceItem.connected) ? "Disconnect" : (_DeviceItem.paired ? "Connect" : "Pair")

                                    onClicked: _DeviceItem.clicked()
                                }
                            }

                            Component {
                                id: _BusyActionComponent
                                Item {
                                    id: _BusyBox
                                    implicitWidth: 96
                                    Layout.fillHeight: true

                                    Rectangle {
                                        id: _BusyBoxBall
                                        anchors.verticalCenter: parent.verticalCenter

                                        implicitHeight: 10
                                        implicitWidth: implicitHeight

                                        color: Constants.bluetooth_color_busy
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

                        ClickableWithIcon {
                            Layout.fillHeight: true
                            implicitWidth: implicitHeight
                            padding: Constants.padding / 1.5

                            enabled: _DeviceItem.paired

                            readonly property color accent:
                                (!_DeviceItem.paired) ? Constants.bluetooth_color_inactive : 
                                    Constants.bluetooth_color_critical

                            styles.background_color_idle: Qt.alpha(accent, 0.05)
                            styles.background_color_active: accent

                            styles.border_width: 1
                            styles.border_color_idle: Qt.alpha(accent, 0.5)
                            styles.border_color_active: Qt.alpha(accent, 1)

                            styles.icon_color_idle: accent
                            styles.icon_color_active: Constants.bluetooth_color_ink_active

                            iconname: "Dismiss.svg"
                            radius: Constants.radius

                            onClicked: _DeviceItem.forget()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: _NoDeviceFoundComponent
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: _NoDeviceFoundLabel.implicitHeight + Constants.padding * 3
            radius: Constants.radius
            color: Qt.alpha(Constants.bluetooth_color_inactive, 0.15)
            border.width: 1
            border.color: Constants.bluetooth_color_inactive

            StyledText {
                id: _NoDeviceFoundLabel
                leftPadding: Constants.padding * 1.5
                rightPadding: Constants.padding * 1.5
                anchors.verticalCenter: parent.verticalCenter
                text: "No Bluetooth devices found"
                color: Constants.bluetooth_color_ink_muted
            }

            Behavior on opacity {
                NumberAnimation { duration: Constants.animation_duration }
            }
        }
    }

    Loader {
        Layout.fillWidth: true
        sourceComponent: (!root.adapter.enabled) ? _OfflineComponent :
            (root.page_size > 0) ? _DevicesFoundComponent : _NoDeviceFoundComponent
    }

    Component {
        id: _OfflineComponent
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: _OfflineLabel.implicitHeight + Constants.padding * 3
            radius: Constants.radius
            color:  Qt.alpha(Constants.bluetooth_color_inactive, 0.15)
            border.width: 1
            border.color: Qt.alpha(Constants.bluetooth_color_inactive, 0.5)

            StyledText {
                id: _OfflineLabel
                leftPadding: Constants.padding * 1.5
                rightPadding: Constants.padding * 1.5
                anchors.verticalCenter: parent.verticalCenter
                text: "Bluetooth adapter is turned off"
                color: Constants.bluetooth_color_ink_muted
            }

            Behavior on opacity {
                NumberAnimation { duration: Constants.animation_duration }
            }
        }
    }

    Timer {
        id: _DiscoveryTimeout

        property real starttime: -1
        readonly property int remaining: (running && starttime > 0) ? Math.max(0, interval - (_TimeoutTick.now - starttime)) : interval

        interval: 10000
        running: root.adapter?.discovering ?? false

        onTriggered: if (root.adapter) root.adapter.discovering = false
        onRunningChanged: starttime = running ? Date.now() : -1
    }

    Timer {
        id: _TimeoutTick

        property real now: Date.now()
        interval: 50
        running: _DiscoveryTimeout.running
        repeat: true
        onTriggered: now = Date.now()
    }
}