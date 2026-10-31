pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs
import qs.Utilities
import qs.Components

ColumnLayout {
    id: root

    signal tarballSelected(path: string, name: string)

    ListModel { id: list_tarballs }

    spacing: Constants.spacing

    RowLayout {
        Layout.fillWidth: true
        spacing: Constants.spacing

        StyledText {
            color: Constants.spotlight_color_ink_active
            font.pixelSize: Constants.font_size_lg
            text: "Select package"
        }

        Item { Layout.fillWidth: true }

        ClickableWithIcon {
            implicitHeight: Constants.size - (Constants.padding / 2)
            padding: Constants.padding

            readonly property color accent: Constants.spotlight_color_ink_active

            styles.background_color_idle: Qt.alpha(accent, 0.05)
            styles.background_color_active: accent
            styles.border_width: 1
            styles.border_color_idle: Qt.alpha(accent, 0.5)
            styles.border_color_active: Qt.alpha(accent, 1)
            styles.text_color_idle: accent
            styles.text_color_active: Constants.color_base

            font.family: Constants.font_family
            text: "Refresh"
            radius: Constants.radius

            onClicked: root.scan()
        }
    }

    ListView {
        id: tarball_listview
        Layout.fillWidth: true
        Layout.preferredHeight: 250
        model: list_tarballs
        clip: true
        spacing: Constants.spacing

        delegate: Clickable {
            id: tarball

            implicitWidth: tarball_listview.width
            implicitHeight: Constants.size

            required property string name
            required property string path

            readonly property bool active: tarball.containsMouse && enabled

            StyledBox {
                anchors.fill: parent

                radius: Constants.radius
                colors.background: (tarball.active) ? Constants.spotlight_color_background_active : Constants.spotlight_color_background_default
                colors.border: Qt.alpha(Constants.spotlight_color_border, (tarball.active) ? 0.5 : 0.25)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Constants.padding
                    anchors.rightMargin: Constants.padding
                    spacing: Constants.spacing

                    IconControl {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        size: 16
                        source: "Package.svg"
                        tint: (tarball.active) ? Constants.spotlight_color_ink_active : Constants.spotlight_color_ink_muted
                    }

                    StyledText {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        color: (tarball.enabled) ? Constants.spotlight_color_ink_active : Constants.spotlight_color_ink_muted
                        text: tarball.name
                    }
                }
            }

            onClicked: root.tarballSelected(path, name)
        }

        StyledBox {
            implicitWidth: tarball_listview.width
            implicitHeight: Constants.size
            visible: list_tarballs.count === 0

            radius: Constants.radius
            colors.background: Constants.spotlight_color_background_default
            colors.border: Qt.alpha(Constants.spotlight_color_border, 0.25)

            StyledText {
                anchors.centerIn: parent
                color: Constants.spotlight_color_ink_muted
                text: "No tarballs found in Downloads"
            }
        }
    }

    function scan() {
        Daemon.run("Tarball Scanning", [
            "sh", "-c",
            "find $HOME/Downloads -maxdepth 2 -type f \\( -name '*.tar' -o -name '*.tar.gz' -o -name '*.tgz' -o -name '*.tar.bz2' -o -name '*.tbz2' -o -name '*.tar.xz' \\) 2>/dev/null | sort"
        ], (e) => {
            const log = e.output;
            if (e.success) {
                let lines = log ? log.split("\n") : [];
                for (let line of lines) {
                    let path = line.trim();
                    if (path !== "") {
                        let name = path.substring(path.lastIndexOf("/") + 1);
                        list_tarballs.append({ name: name, path: path });
                    }
                }
            }
        })
    }

    Component.onCompleted: scan();
}