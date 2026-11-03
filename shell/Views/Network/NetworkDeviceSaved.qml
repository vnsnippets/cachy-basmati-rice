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
    spacing: Constants.padding

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
        Layout.topMargin: (Constants.padding * 1.5)
        Layout.alignment: Qt.AlignVCenter
        text: "PREVIOUSLY SAVED NETWORKS"
        color: Constants.tab_color_ink_muted
        font.weight: 600
    }

    // --- Content Loader ---
    Loader {
        Layout.fillWidth: true
        sourceComponent: (root.networks.length > 0) ? _NetworksFoundComponent : _NoNetworkComponent
    }

    // --- Networks ListView ---
    Component {
        id: _NetworksFoundComponent

        ListView {
            id: _ListViewNetworks
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
                id: _NetworkItem
                width: _ListViewNetworks.width
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
                        text: (Constants.network_scramble_ssid) ? NetworkService.scramble(_NetworkItem.ssid) : _NetworkItem.ssid
                        color: Constants.network_color_ink_default
                        elide: Text.ElideRight
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    StyledText {
                        text: _NetworkItem.type.toUpperCase()
                        color: Constants.network_color_ink_muted
                        font.pixelSize: Constants.font_size_sm
                    }

                    ClickableButton {
                        implicitWidth: 76

                        topPadding: Constants.padding / 1.5
                        bottomPadding: Constants.padding / 1.5

                        colors.accent: Constants.network_color_critical
                        colors.ink: Constants.network_color_ink_active
                        text: "Forget"

                        onClicked: root.forget(_NetworkItem.uuid)
                    }
                }
            }
        }
    }

    // --- Empty State ---
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
                text: "No saved disconnected networks found"
                color: Constants.network_color_ink_muted
            }
        }
    }
}