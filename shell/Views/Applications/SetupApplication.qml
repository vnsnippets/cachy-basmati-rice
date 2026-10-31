pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell.Io

import qs
import qs.Services
import qs.Utilities
import qs.Components

ColumnLayout {
    id: root

    spacing: Constants.spacing

    signal completed

    readonly property int item_height: Constants.size

    property string selected_tarball_name: ""
    property string selected_tarball_path: ""
    property string selected_tarball_folder: ""

    ListModel { id: model_tarballs }
    ListModel { id: model_tarball_folders }
    
    function scan() {
        Daemon.run("Tarball Scanning", [
            "bash", "-c", 
            "find $HOME/Downloads -maxdepth 2 -type f \\( -name '*.tar' -o -name '*.tar.gz' -o -name '*.tgz' -o -name '*.tar.bz2' -o -name '*.tbz2' -o -name '*.tar.xz' \\) 2>/dev/null | sort"
        ], (e) => {
            const log = e.output;
            const err = e.error;

            if (e.success) {
                let lines = log ? log.split("\n") : [];
                model_tarballs.clear();
                
                for (let line of lines) {
                    let path = line.trim();
                    if (path !== "") {
                        let name = path.substring(path.lastIndexOf("/") + 1);
                        model_tarballs.append({ name: name, path: path });
                    }
                }
            }
        })
    }

    Component.onCompleted: scan();

    // Step 0: Pick Tarball from Downloads
    ColumnLayout {
        Layout.topMargin: Constants.padding
        Layout.fillWidth: true
        visible: root.selected_tarball_path === "" || tarball_inspection.running
        spacing: Constants.spacing

        RowLayout {
            Layout.fillWidth: true

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
            Layout.preferredHeight: 180
            model: model_tarballs
            clip: true
            spacing: 4

            delegate: Clickable {
                id: tarball

                implicitWidth: tarball_listview.width
                implicitHeight: root.item_height

                enabled: !tarball_inspection.running

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
                        
                        StyledText {
                            Layout.alignment: Qt.AlignVCenter

                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter

                            visible: (root.selected_tarball_path === tarball.path)

                            color: Constants.spotlight_color_ink_muted
                            text: "Inspecting..."
                        }    
                    }
                }

                onClicked: {
                    root.selected_tarball_path = path;
                    root.selected_tarball_name = name;
                    tarball_inspection.run(path);
                }               
            }

            Item {
                anchors.centerIn: parent
                visible: model_tarballs.count === 0

                Text {
                    anchors.centerIn: parent
                    color: Constants.spotlight_color_ink_muted
                    text: "No tarballs found in Downloads"
                }
            }
        }
    }

    // Step 1: Select Root Folder & Set Destination Name
    ColumnLayout {
        Layout.fillWidth: true
        spacing: root.spacing
        visible: root.selected_tarball_path !== "" && !tarball_inspection.running

        RowLayout {
            Layout.fillWidth: true
            spacing: Constants.spacing

            StyledText {
                color: Constants.spotlight_color_ink_active
                font.pixelSize: Constants.font_size_lg
                text: "Select folder from tarball"
            }
            
            Item { Layout.fillWidth: true }

            ClickableWithIcon {
                readonly property color accent: (enabled) ? Constants.color_red : Constants.color_overlay

                enabled: !tarball_installation.running

                padding: Constants.padding / 1.5
                leftPadding: Constants.padding
                rightPadding: Constants.padding

                styles.background_color_idle: Qt.alpha(accent, 0.05)
                styles.background_color_active: Qt.alpha(accent, 1)

                styles.icon_color_idle: accent
                styles.icon_color_active: Constants.color_base

                styles.border_width: 1
                styles.border_color_idle: Qt.alpha(accent, 0.5)
                styles.border_color_active: Qt.alpha(accent, 1)

                styles.text_color_idle: accent
                styles.text_color_active: Constants.color_base

                font.family: Constants.font_family
                text: "Cancel"

                radius: Constants.radius

                onClicked: root.selected_tarball_folder = root.selected_tarball_path = root.selected_tarball_name = ""
            }
        }

        ListView {
            id: tarball_folder_listview
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            model: model_tarball_folders
            clip: true
            spacing: 4

            delegate: Clickable {
                id: tarball_folder

                implicitWidth: tarball_folder_listview.width
                implicitHeight: root.item_height

                enabled: !tarball_installation.running

                required property string name
                readonly property bool active: enabled && tarball_folder.containsMouse
                readonly property bool is_selected: root.selected_tarball_folder === tarball_folder.name

                StyledBox {
                    anchors.fill: parent

                    radius: Constants.radius
                    colors.background: (tarball_folder.active) ? Constants.spotlight_color_background_active : Constants.spotlight_color_background_default
                    colors.border: (tarball_folder.is_selected) ? Qt.alpha(Constants.color_green, 0.5) : 
                        Qt.alpha(Constants.spotlight_color_border, (tarball_folder.active) ? 0.5 : 0.25)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Constants.padding
                        anchors.rightMargin: Constants.padding

                        spacing: Constants.spacing

                        IconControl {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            size: 16
                            source: "Folder.svg"
                            tint: (tarball_folder.is_selected) ? Constants.color_green : 
                                (tarball_folder.active) ? Constants.spotlight_color_ink_active : Constants.spotlight_color_ink_muted
                        }

                        StyledText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter

                            color: (tarball_folder.is_selected) ? Constants.color_green : Constants.spotlight_color_ink_active
                            text: tarball_folder.name
                        }
                    }
                }

                onClicked: root.selected_tarball_folder = tarball_folder.name
            }
        }

        StyledText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.leftMargin: 2
            Layout.rightMargin: 2

            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            
            color: Constants.spotlight_color_ink_muted
            text: `[Tarball]/${root.selected_tarball_folder} → ~/.local/apps/${target_folder_text_field.text}`
        }        

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: root.item_height

            TextField {
                id: target_folder_text_field

                enabled: !tarball_installation.running

                Layout.fillWidth: true
                Layout.fillHeight: true

                leftPadding: Constants.padding
                rightPadding: Constants.padding

                verticalAlignment: TextInput.AlignVCenter
                
                color: Constants.spotlight_color_ink_active
                font.pixelSize: Constants.font_size
                focus: true
                
                placeholderTextColor: Qt.alpha(color, 0.5)
                placeholderText: "Enter preferred folder name in ~/.local/apps"

                text: root.selected_tarball_folder

                background: Rectangle {
                    color: (target_folder_text_field.activeFocus) ? Constants.spotlight_color_background_active : Constants.spotlight_color_background_default
                    border.color: Qt.alpha(Constants.spotlight_color_border, (target_folder_text_field.activeFocus) ? 0.50: 0.15)
                    radius: Constants.radius
                }
            }


            ClickableWithIcon {
                readonly property color accent: (enabled) ? Constants.color_green : Constants.color_overlay

                enabled: root.selected_tarball_folder !== "" && target_folder_text_field.text !== "" && !tarball_installation.running

                padding: Constants.padding / 1.5
                leftPadding: Constants.padding
                rightPadding: Constants.padding

                styles.background_color_idle: Qt.alpha(accent, 0.05)
                styles.background_color_active: Qt.alpha(accent, 1)

                styles.icon_color_idle: accent
                styles.icon_color_active: Constants.color_base

                styles.border_width: 1
                styles.border_color_idle: Qt.alpha(accent, 0.5)
                styles.border_color_active: Qt.alpha(accent, 1)

                styles.text_color_idle: accent
                styles.text_color_active: Constants.color_base

                font.family: Constants.font_family
                text: "Install"

                radius: Constants.radius

                onClicked: tarball_installation.run(target_folder_text_field.text)
            }
        }

        StyledText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.leftMargin: 2
            Layout.rightMargin: 2

            visible: tarball_installation.running

            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            
            color: Constants.color_yellow
            text: "Extraction in progress..."
        }  
    }

    Process {
        id: tarball_inspection
        
        stdout: StdioCollector { id: inspection_stdout }
        stderr: StdioCollector { id: inspection_stderr }

        running: false

        function run(path) {
            command = ["tar", "-tf", path];
            running = true;
        }

        onRunningChanged: {
            if (running) return;

            command = [];

            let log = inspection_stdout.text.trim();
            let err = inspection_stderr.text.trim();

            if (err.length === 0) {
                let lines = log ? log.split("\n") : [];
                
                model_tarball_folders.clear();
                let rootDirs = new Set();
                for (let line of lines) {
                    let parts = line.split("/");
                    if (parts.length > 0 && parts[0] !== "") {
                        rootDirs.add(parts[0]);
                    }
                }

                for (let dir of rootDirs) {
                    model_tarball_folders.append({ name: dir });
                }
            } else {
                Debug.log([ "Tarball Installation" ], `Tarball inspection failed: ${err}`);
            }
        }
    }

    Process {
        id: tarball_installation
        
        stderr: StdioCollector { id: installation_stderr }
        running: false

        function run(targetFolder) {
            if (!root.selected_tarball_path || !root.selected_tarball_folder) return;

            const targetDirectory = "$HOME/.local/apps";
            const destinationFolder = `${targetDirectory}/${targetFolder}`;

            const script = `
                mkdir -p "${targetDirectory}"
                rm -rf "${destinationFolder}"
                mkdir -p "${destinationFolder}"
                
                tar -xf "${root.selected_tarball_path}" -C "${destinationFolder}" --strip-components=1 "${root.selected_tarball_folder}"
            `;

            command = ["bash", "-c", script];
            running = true;
        }

        onRunningChanged: {
            if (running) return;

            let err = installation_stderr.text.trim();

            command = [];

            if (err.length === 0) {
                Debug.log([ "Tarball Installation" ], "Installation completed successfully.");
                NotificationService.push("Installation Completed", `Package: ${root.selected_tarball_name}`);
                root.completed()
            } else {
                Debug.log([ "Tarball Installation" ], `Install process failed: ${err}`);
            }
        }
    }
}