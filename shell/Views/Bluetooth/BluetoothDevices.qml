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

            value: 1.0 - (timeout_discovery.remaining / timeout_discovery.interval)
            blink: false
            length: 25
            radius: Constants.radius / 2
            spacing: Constants.spacing / 2

            styles.color_idle: Qt.alpha(Constants.bluetooth_color_inactive, 0.5)
            styles.color_active: Constants.bluetooth_color_busy
        }

        // Scan / Discovery Toggle Button
        ClickableWithIcon {
            implicitHeight: Constants.size - (Constants.padding / 2)
            implicitWidth: 108
            padding: Constants.padding

            enabled: root.adapter.enabled

            readonly property color accent: 
                (!root.adapter.enabled) ? Constants.bluetooth_color_inactive :
                    (root.adapter.discovering) ? Constants.bluetooth_color_critical : Constants.bluetooth_color_active

            styles.background_color_idle: Qt.alpha(accent, 0.05)
            styles.background_color_active: accent

            styles.border_width: 1
            styles.border_color_idle: Qt.alpha(accent, 0.5)
            styles.border_color_active: Qt.alpha(accent, 1)

            styles.text_color_idle: accent
            styles.text_color_active: Constants.bluetooth_color_ink_active

            font.family: Constants.font_family
            text: root.adapter.discovering ? "Stop Scan" : "Scan Devices"

            radius: Constants.radius

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

            iconname: "power.svg"

            onClicked: if (root.adapter) {
                root.adapter.discovering = false;
                root.adapter.enabled = !root.adapter.enabled;
            }
            
            radius: (active) ? Constants.icon_size : Constants.radius
            Behavior on radius { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
        }
    }

    Component {
        id: component_with_devices
        ListView {
            id: device_list
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
                id: device
                width: ListView.view.width
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
                    if (device.pairing) {
                        device.cancel()
                    } else if (device.connected) {
                        device.disconnect();
                    } else if (device.paired) {
                        device.connect();
                    } else {
                        device.modelData.trusted = true
                        // device.pair();
                        Quickshell.execDetached([
                            "foot", "sh", "-c", 
                            `(echo 'agent on'; echo 'default-agent'; echo 'pair ${device.address}'; cat) | bluetoothctl`
                        ]);
                    }
                }

                color: Constants.bluetooth_color_background
                border.color:  (modelData.blocked) ? Qt.alpha(Constants.bluetooth_color_critical, 0.5) :
                    (connected) ? Qt.alpha(accent, 0.5) : Constants.bluetooth_color_border
                border.width: 1

                Behavior on border.color { ColorAnimation { duration: Constants.animation_duration } }

                RowLayout {
                    id: device_content
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: device._padding
                    anchors.rightMargin: device._padding

                    spacing: Constants.spacing

                    // IconControl {
                    //     size: Constants.icon_size * 1.25
                    //     source: "bluetooth/" + device.icon + ".svg"
                    //     tint: (device.connected) ? Constants.bluetooth_color_active : Constants.bluetooth_color_ink_muted
                    // }

                    Column {
                        spacing: 1
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                        StyledText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            text: device.device_name
                            color: device.connected ? device.accent : Constants.bluetooth_color_ink_default
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            text: device.connection_state + (device.modelData.batteryAvailable ? ` | Battery: ${(device.modelData.battery * 100).toFixed(0)}%` : "") 
                            color: Constants.bluetooth_color_ink_muted
                            font.pixelSize: Constants.font_size - 1
                            visible: device.connection_state !== ""
                        }
                    }

                    Row {
                        id: device_status
                        spacing: Constants.spacing

                        readonly property color muted: Qt.alpha(Constants.bluetooth_color_ink_muted, 0.5)

                        ClickableWithIcon {
                            Layout.fillHeight: true
                            implicitWidth: implicitHeight

                            active: device.modelData.blocked

                            styles.icon_color_idle: device_status.muted
                            styles.icon_color_active: Constants.bluetooth_color_critical

                            styles.border_width: 0
                            radius: Constants.radius

                            iconname: "block.svg"

                            onClicked: device.modelData.blocked = !device.modelData.blocked
                        }

                        ClickableWithIcon {
                            Layout.fillHeight: true
                            implicitWidth: implicitHeight

                            active: device.modelData.bonded

                            styles.icon_color_idle: (active) ? Constants.bluetooth_color_saved : device_status.muted

                            styles.border_width: 0
                            radius: Constants.radius

                            iconname: "bookmark-filled.svg"                            
                            enabled: false
                        }

                        ClickableWithIcon {
                            Layout.fillHeight: true
                            implicitWidth: implicitHeight

                            active: device.modelData.wakeAllowed

                            styles.icon_color_idle: device_status.muted
                            styles.icon_color_active: Constants.bluetooth_color_busy

                            styles.border_width: 0
                            radius: Constants.radius

                            iconname: "bolt.svg"

                            onClicked: device.modelData.wakeAllowed = !device.modelData.wakeAllowed
                        }

                        ClickableWithIcon {
                            Layout.fillHeight: true
                            implicitWidth: implicitHeight

                            active: device.modelData.trusted

                            styles.icon_color_idle: device_status.muted
                            styles.icon_color_active: Constants.bluetooth_color_secure

                            styles.border_width: 0
                            radius: Constants.radius

                            iconname: "shield.svg"

                            onClicked: device.modelData.trusted = !device.modelData.trusted
                        }
                    }

                    Row {
                        spacing: Constants.spacing
                        Layout.fillHeight: true
                        Layout.topMargin: device._padding * 2
                        Layout.bottomMargin: device._padding * 2

                        Loader {
                            Layout.preferredWidth: implicitWidth
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignVCenter

                            sourceComponent: (device.state_changing) ? action_busy : action_connect

                            Component {
                                id: action_connect

                                ClickableWithIcon {
                                    implicitWidth: 96

                                    readonly property color accent: 
                                        (device.connected) ? Constants.bluetooth_color_critical : 
                                            Constants.bluetooth_color_active

                                    padding: Constants.padding / 1.5
                                    leftPadding: Constants.padding
                                    rightPadding: Constants.padding

                                    styles.background_color_idle: Qt.alpha(accent, 0.05)
                                    styles.background_color_active: Qt.alpha(accent, 1)

                                    styles.icon_color_idle: accent
                                    styles.icon_color_active: Constants.bluetooth_color_ink_active

                                    styles.border_width: 1
                                    styles.border_color_idle: Qt.alpha(accent, 0.5)
                                    styles.border_color_active: Qt.alpha(accent, 1)

                                    styles.text_color_idle: accent
                                    styles.text_color_active: Constants.bluetooth_color_ink_active

                                    font.family: Constants.font_family
                                    text: (device.connected) ? "Disconnect" : (device.paired ? "Connect" : "Pair")

                                    radius: Constants.radius

                                    onClicked: device.clicked()
                                }
                            }

                            Component {
                                id: action_busy
                                Item {
                                    id: busy_box
                                    implicitWidth: 96
                                    Layout.fillHeight: true

                                    Rectangle {
                                        id: rect_ball
                                        anchors.verticalCenter: parent.verticalCenter

                                        implicitHeight: 10
                                        implicitWidth: implicitHeight

                                        color: Constants.bluetooth_color_busy
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

                        ClickableWithIcon {
                            Layout.fillHeight: true
                            implicitWidth: implicitHeight
                            padding: Constants.padding / 1.5

                            enabled: device.paired

                            readonly property color accent:
                                (!device.paired) ? Constants.bluetooth_color_inactive : 
                                    Constants.bluetooth_color_critical

                            styles.background_color_idle: Qt.alpha(accent, 0.05)
                            styles.background_color_active: accent

                            styles.border_width: 1
                            styles.border_color_idle: Qt.alpha(accent, 0.5)
                            styles.border_color_active: Qt.alpha(accent, 1)

                            styles.icon_color_idle: accent
                            styles.icon_color_active: Constants.bluetooth_color_ink_active

                            iconname: "dismiss.svg"
                            radius: Constants.radius

                            onClicked: device.forget()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: component_no_device
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: no_device_label.implicitHeight + Constants.padding * 3
            radius: Constants.radius
            color: Qt.alpha(Constants.bluetooth_color_inactive, 0.15)
            border.width: 1
            border.color: Constants.bluetooth_color_inactive

            StyledText {
                id: no_device_label
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
        sourceComponent: (!root.adapter.enabled) ? component_powered_off :
            (root.page_size > 0) ? component_with_devices : component_no_device
    }

    Component {
        id: component_powered_off
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: powered_off_label.implicitHeight + Constants.padding * 3
            radius: Constants.radius
            color:  Qt.alpha(Constants.bluetooth_color_inactive, 0.15)
            border.width: 1
            border.color: Qt.alpha(Constants.bluetooth_color_inactive, 0.5)

            StyledText {
                id: powered_off_label
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
        id: timeout_discovery

        property real starttime: -1
        readonly property int remaining: (running && starttime > 0) ? Math.max(0, interval - (timeout_tick.now - starttime)) : interval

        interval: 10000
        running: root.adapter?.discovering ?? false

        onTriggered: if (root.adapter) root.adapter.discovering = false
        onRunningChanged: starttime = running ? Date.now() : -1
    }

    Timer {
        id: timeout_tick

        property real now: Date.now()
        interval: 50
        running: timeout_discovery.running
        repeat: true
        onTriggered: now = Date.now()
    }
}