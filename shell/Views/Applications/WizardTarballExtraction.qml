pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell.Io

import qs
import qs.Utilities
import qs.Components

ColumnLayout {
    id: root

    signal backPressed
    signal extractionStart(source: string, target: string)

    required property string selected_tarball_path

    ListModel { id: model_tarball_folders }
    
    property string selected_tarball_folder: ""

    spacing: Constants.spacing

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

            // enabled: !root.context.isInstalling
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
            text: "Back"
            radius: Constants.radius

            onClicked: root.backPressed()
        }
    }

    StyledText {
        color: Constants.spotlight_color_ink_muted
        font.pixelSize: Constants.font_size_sm
        text: root.selected_tarball_path
    }

    ListView {
        id: tarball_folder_listview
        
        Layout.fillWidth: true
        Layout.preferredHeight: 250
        model: model_tarball_folders
        
        spacing: Constants.spacing

        delegate: Clickable {
            id: tarball_folder

            implicitWidth: tarball_folder_listview.width
            implicitHeight: Constants.size

            required property string name
            
            readonly property bool active: enabled && tarball_folder.containsMouse
            readonly property bool is_selected: root.selected_tarball_folder === name

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

        StyledBox {
            implicitWidth: tarball_folder_listview.width
            implicitHeight: Constants.size
            visible: tarball_inspection.running

            radius: Constants.radius
            colors.background: Constants.spotlight_color_background_default
            colors.border: Qt.alpha(Constants.spotlight_color_border, 0.25)

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: Constants.padding
                rightPadding: Constants.padding

                color: Constants.spotlight_color_ink_muted
                text: "Inspecting package for directories..."
            }
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
        Layout.preferredHeight: Constants.size

        TextField {
            id: target_folder_text_field

            // enabled: !root.context.isInstalling
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

            enabled: root.selected_tarball_folder !== "" && target_folder_text_field.text !== ""
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

            onClicked: root.extractionStart(root.selected_tarball_folder, target_folder_text_field.text)
        }
    }
    
    Process {
        id: tarball_inspection

        stdout: StdioCollector { id: inspection_stdout }
        stderr: StdioCollector { id: inspection_stderr }

        running: true

        function run(path) {
            command = [ "tar", "-tf", path ]
            running = true;
        }

        command: [ "tar", "-tf", root.selected_tarball_path ]

        onRunningChanged: {
            if (running) return;
            command = [];

            let log = inspection_stdout.text.trim();
            let err = inspection_stderr.text.trim();

            if (err.length === 0) {
                let lines = log ? log.split("\n") : [];
                
                let rootDirs = new Set();
                model_tarball_folders.clear();

                for (let line of lines) {
                    let parts = line.split("/");
                    if (parts.length > 0 && parts[0] !== "") {
                        rootDirs.add(parts[0]);
                    }
                }
                
                for (const dir of rootDirs) {
                    model_tarball_folders.append({ name: dir })
                }

            } else {
                Debug.log([ "Tarball Installation" ], `Tarball inspection failed: ${err}`);
            }
        }
    }
}