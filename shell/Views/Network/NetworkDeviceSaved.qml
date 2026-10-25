pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs
import qs.Services
import qs.Utilities
import qs.Components

ColumnLayout {
    id: root
    spacing: Constants.spacing

    property var networks: []
    property bool isLoading: false

    readonly property int item_height: Constants.size * 1.5
    property int page_size: Math.min(5, root.networks.length)
    readonly property int capped_height: (item_height * page_size) + (Constants.spacing * Math.max(0, page_size - 1))

    function getnetworks() {
        if (root.isLoading) return;
        root.isLoading = true;

        // Query saved connections filtering for ones with no active device assigned (empty or '--')
        Daemon.execute(["sh", "-c", "nmcli -t -f NAME,UUID,TYPE,DEVICE connection show"], (e) => {
            const lines = (e.output || "").split("\n");
            const inactiveNetworks = [];

            for (let i = 0; i < lines.length; i++) {
                const line = lines[i].trim();
                if (!line) continue;

                const parts = line.split(":");
                if (parts.length < 4) continue;

                const name = parts[0].trim().replace(/\\:/g, ":");
                const uuid = parts[1].trim();
                const type = parts[2].trim();
                const device = parts[3].trim();

                // Keep only disconnected profiles (no active hardware device bound)
                if ((!device || device === "--") && name && uuid) {
                    inactiveNetworks.push({
                        name: name,
                        uuid: uuid,
                        type: type
                    });
                }
            }

            root.networks = inactiveNetworks;
            root.isLoading = false;
        });
    }

    function forget(uuid) {
        if (!uuid) return;

        Daemon.execute(["sh", "-c", `nmcli connection delete uuid ${uuid}`], (e) => {
            if (e.success) root.getnetworks();
        });
    }

    Component.onCompleted: root.getnetworks();

    StyledText {
        text: "PREVIOUSLY SAVED (" + root.networks.length + ")"
        color: Constants.tab_color_ink_muted
        font.pixelSize: Constants.font_size_sm
    }

    // --- Content Loader ---
    Loader {
        Layout.fillWidth: true
        sourceComponent: (root.networks.length > 0) ? component_with_networks : component_no_network
    }

    // --- Networks ListView ---
    Component {
        id: component_with_networks

        ListView {
            id: network_list
            Layout.fillWidth: true

            implicitHeight: root.capped_height
            Layout.preferredHeight: root.capped_height

            spacing: Constants.spacing
            clip: true

            model: root.networks.sort((a, b) => {
                return a.name.localeCompare(b.name, undefined, { sensitivity: 'accent', numeric: true });
            });

            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOff; }

            delegate: StyledBox {
                id: network_item
                width: ListView.view.width
                radius: Constants.radius

                required property var modelData

                readonly property string ssid: modelData.name || "Unknown Network"
                readonly property string uuid: modelData.uuid || ""
                readonly property string type: modelData.type || "unknown"

                implicitHeight: root.item_height

                color: Constants.network_color_background
                border.color: Constants.network_color_border
                border.width: 1

                RowLayout {
                    spacing: Constants.padding
                    anchors.fill: parent
                    anchors.leftMargin: Constants.padding * 1.25
                    anchors.rightMargin: Constants.padding * 1.25

                    StyledText {
                        text: (Constants.network_scramble_ssid) ? NetworkService.scramble(network_item.ssid) : network_item.ssid
                        color: Constants.network_color_ink_default
                        elide: Text.ElideRight
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    StyledText {
                        text: network_item.type.toUpperCase()
                        color: Constants.network_color_ink_muted
                        font.pixelSize: Constants.font_size_sm
                    }

                    ClickableWithIcon {
                        readonly property color accent: Constants.network_color_critical

                        padding: Constants.padding / 1.5
                        leftPadding: Constants.padding
                        rightPadding: Constants.padding

                        styles.background_color_idle: Qt.alpha(accent, 0.05)
                        styles.background_color_active: Qt.alpha(accent, 1)

                        styles.icon_color_idle: accent
                        styles.icon_color_active: Constants.network_color_ink_active

                        styles.border_width: 1
                        styles.border_color_idle: Qt.alpha(accent, 0.5)
                        styles.border_color_active: Qt.alpha(accent, 1)

                        styles.text_color_idle: accent
                        styles.text_color_active: Constants.network_color_ink_active

                        font.family: Constants.font_family
                        text: "Forget"
                        radius: Constants.radius

                        onClicked: root.forget(network_item.uuid)
                    }
                }
            }
        }
    }

    // --- Empty State ---
    Component {
        id: component_no_network
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: no_network_label.implicitHeight + Constants.padding * 3
            radius: Constants.radius
            color: Qt.alpha(Constants.network_color_inactive, 0.15)
            border.width: 1
            border.color: Constants.network_color_inactive

            StyledText {
                id: no_network_label
                leftPadding: Constants.padding * 1.5
                rightPadding: Constants.padding * 1.5
                anchors.verticalCenter: parent.verticalCenter
                text: "No saved disconnected networks found"
                color: Constants.network_color_ink_muted
            }
        }
    }
}