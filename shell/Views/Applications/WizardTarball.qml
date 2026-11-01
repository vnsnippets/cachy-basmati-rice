pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Io

import qs
import qs.Layouts
import qs.Services
import qs.Utilities
import qs.Components

ColumnLayout {
    id: root

    spacing: Constants.spacing

    signal completed

    readonly property int itemHeight: Constants.size
    readonly property int listViewHeight: 200

    component Context: QtObject {
        property string packagePath: ""
        property string packageDirectory: ""
        property string extractionDirectory: packageDirectory
    }

    property Context context: Context {}
    readonly property string extractionPath: `${Constants.wizard_tarball_extraction_directory}/${context.extractionDirectory}`
     
    function getPackageName(path) { return path.substring(path.lastIndexOf("/") + 1); }

    property bool success: false

    ListModel { id: _TarballList }
    ListModel { id: _TarballDirectoryList }

    ContentContainer {
        id: container
        Layout.fillWidth: true
        Layout.preferredHeight: container.implicitHeight
        content: (root.context.packagePath === "" || _InspectionProcess.running) ? _TarballSelectionComponent : _TarballExtractionComponent
    }

    Component {
        id: _TarballSelectionComponent
        
        ColumnLayout {
            spacing: Constants.spacing

            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    color: Constants.spotlight_color_ink_active
                    font.pixelSize: Constants.font_size_lg
                    text: "Select package"
                }

                Item { Layout.fillWidth: true }

                ClickableButton {
                    enabled: !_InspectionProcess.running
                    padding: Constants.padding / 1.5
                    leftPadding: Constants.padding
                    rightPadding: Constants.padding
                    colors.accent: Constants.color_sky
                    text: "Refresh"
                    onClicked: _FolderScanProcess.run()
                }
            }

            ListView {
                id: _ListViewTarballs

                Layout.fillWidth: true
                Layout.preferredHeight: root.listViewHeight

                model: _TarballList
                clip: true
                spacing: 4

                delegate: Clickable {
                    id: _TarballItem

                    implicitWidth: _ListViewTarballs.width
                    implicitHeight: root.itemHeight
                    enabled: !_InspectionProcess.running

                    required property string path
                    readonly property bool active: _TarballItem.containsMouse && enabled
                    readonly property bool inspecting: root.context.packagePath === path && _InspectionProcess.running

                    StyledBox {
                        anchors.fill: parent

                        radius: Constants.radius
                        colors.background: _TarballItem.active ? Constants.spotlight_color_background_active : Constants.spotlight_color_background_default
                        colors.border: Qt.alpha(Constants.spotlight_color_border, _TarballItem.active ? 0.5 : 0.25)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Constants.padding
                            anchors.rightMargin: Constants.padding
                            spacing: Constants.spacing

                            IconControl {
                                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                size: 16
                                source: "Package.svg"
                                tint: _TarballItem.active ? Constants.spotlight_color_ink_active : Constants.spotlight_color_ink_muted
                            }

                            StyledText {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter

                                color: _TarballItem.enabled ? Constants.spotlight_color_ink_active : Constants.spotlight_color_ink_muted
                                text: root.getPackageName(_TarballItem.path) 
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter

                                visible: _TarballItem.inspecting
                                color: Constants.spotlight_color_ink_muted

                                text: "Inspecting..."
                            }
                        }
                    }

                    onClicked: _InspectionProcess.run(path)
                }

                StyledBox {
                    implicitWidth: _ListViewTarballs.width
                    implicitHeight: Constants.size + Constants.padding
                    visible: !_FolderScanProcess.running && _TarballList.count === 0

                    radius: Constants.radius
                    colors.background: Constants.spotlight_color_background_default
                    colors.border: Qt.alpha(Constants.spotlight_color_border, 0.25)

                    StyledText {
                        anchors.centerIn: parent
                        color: Constants.spotlight_color_ink_muted
                        text: "No tarballs found in " + Constants.wizard_tarball_scan_directory
                    }
                }
            }

            Component.onCompleted: _FolderScanProcess.run()
        }
    }

    Component {
        id: _TarballExtractionComponent

        ColumnLayout {
            spacing: root.spacing

            RowLayout {
                Layout.fillWidth: true
                spacing: Constants.spacing

                StyledText {
                    color: Constants.spotlight_color_ink_active
                    font.pixelSize: Constants.font_size_lg
                    text: "Select folder from tarball"
                }
                
                Item { Layout.fillWidth: true }

                ClickableButton {
                    enabled: !_ExtractionProcess.running && !root.success
                    topPadding: Constants.padding / 1.5
                    bottomPadding: Constants.padding / 1.5
                    colors.accent: Constants.color_red
                    colors.muted: Constants.color_overlay
                    colors.ink: Constants.color_base
                    text: "Cancel"

                    onClicked: {
                        root.context.packagePath = "";
                        root.context.packageDirectory = "";
                        root.context.extractionDirectory = root.context.packageDirectory;
                    }
                }
            }

            ListView {
                id: _ListViewTarballDirectories
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                model: _TarballDirectoryList
                clip: true
                spacing: 4

                delegate: Clickable {
                    id: _TarballDirectoryItem

                    implicitWidth: _ListViewTarballDirectories.width
                    implicitHeight: root.itemHeight
                    enabled: !_ExtractionProcess.running

                    required property string name
                    readonly property bool active: enabled && _TarballDirectoryItem.containsMouse
                    readonly property bool selected: root.context.packageDirectory === name

                    StyledBox {
                        anchors.fill: parent

                        radius: Constants.radius
                        colors.background: _TarballDirectoryItem.active ? Constants.spotlight_color_background_active : Constants.spotlight_color_background_default
                        colors.border: _TarballDirectoryItem.selected ? Qt.alpha(Constants.color_green, 0.5) : 
                            Qt.alpha(Constants.spotlight_color_border, _TarballDirectoryItem.active ? 0.5 : 0.25)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Constants.padding
                            anchors.rightMargin: Constants.padding
                            spacing: Constants.spacing

                            IconControl {
                                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                size: 16
                                source: "Folder.svg"
                                tint: _TarballDirectoryItem.selected ? Constants.color_green : 
                                        _TarballDirectoryItem.active ? Constants.spotlight_color_ink_active : 
                                            Constants.spotlight_color_ink_muted
                            }

                            StyledText {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter

                                color: _TarballDirectoryItem.selected ? Constants.color_green : Constants.spotlight_color_ink_active
                                text: _TarballDirectoryItem.name
                            }
                        }
                    }

                    onClicked: root.context.packageDirectory = _TarballDirectoryItem.name
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
                text: `[Tarball]/${root.context.packageDirectory} → ${root.extractionPath}`
            }        

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: root.itemHeight

                TextField {
                    id: _TextFieldDestinationFolder

                    enabled: !_ExtractionProcess.running

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    leftPadding: Constants.padding
                    rightPadding: Constants.padding
                    
                    verticalAlignment: TextInput.AlignVCenter
                    
                    color: Constants.spotlight_color_ink_active
                    font.pixelSize: Constants.font_size
                    focus: true
                    
                    placeholderTextColor: Qt.alpha(color, 0.5)
                    placeholderText: "Enter preferred directory for extraction"

                    text: root.context.packageDirectory
                    onTextChanged: root.context.extractionDirectory = text

                    background: Rectangle {
                        color: _TextFieldDestinationFolder.activeFocus ? Constants.spotlight_color_background_active : Constants.spotlight_color_background_default
                        border.color: Qt.alpha(Constants.spotlight_color_border, _TextFieldDestinationFolder.activeFocus ? 0.50 : 0.15)
                        radius: Constants.radius
                    }
                }

                ClickableButton {
                    enabled: root.context.packageDirectory !== "" && _TextFieldDestinationFolder.text !== "" && !_ExtractionProcess.running && !root.success

                    Layout.fillHeight: true

                    colors.accent: enabled ? Constants.color_green : Constants.color_overlay
                    colors.muted: Constants.color_overlay
                    colors.ink: Constants.color_base
                    
                    text: "Install"
                    onClicked: _ExtractionProcess.run()
                }
            }

            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                Layout.leftMargin: 2
                Layout.rightMargin: 2
                visible: _ExtractionProcess.running || root.success
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                
                color: root.success ? Constants.color_green : Constants.color_yellow
                text: root.success ? "Extraction completed!" : "Extraction in progress..."
            }  
        }
    }
    
    Process {
        id: _FolderScanProcess
        
        stdout: StdioCollector { id: scan_stdout }
        stderr: StdioCollector { id: scan_stderr }

        running: false

        function run() {
            command = [ "sh", `${Quickshell.shellDir}/Scripts/ExtractTarball.sh`, "--scan", Constants.wizard_tarball_scan_directory ]
            running = true;
        }

        onRunningChanged: {
            if (running) return;

            command = [];
            const log = scan_stdout.text.trim();
            const err = scan_stderr.text.trim();

            if (err.length > 0) {
                Debug.log(["Wizard", "Tarball", "Folder Scanning" ], `Folder scanning for tarballs failed: ${err}`);
                return;
            }

            const lines = log ? log.split("\n") : [];
            _TarballList.clear();

            const items = [];
            for (const line of lines) {
                const path = line.trim();
                if (path !== "") items.push({ path: path });
            }

            if (items.length > 0) _TarballList.append(items);
        }
    }

    Process {
        id: _InspectionProcess
        
        stdout: StdioCollector { id: inspection_stdout }
        stderr: StdioCollector { id: inspection_stderr }
        running: false

        function run(_path) {
            root.context.packagePath = _path;
            command = ["tar", "-tf", _path];
            running = true;
        }

        onRunningChanged: {
            if (running) return;

            command = [];
            const log = inspection_stdout.text.trim();
            const err = inspection_stderr.text.trim();

            if (err.length > 0) {
                Debug.log(["Wizard", "Tarball", "Inspection" ], `Tarball inspection failed: ${err}`);
                root.context.packagePath = "";
                return;
            }

            const lines = log ? log.split("\n") : [];
            _TarballDirectoryList.clear();

            const directories = new Set();
            for (const line of lines) {
                let parts = line.split("/");
                if (parts.length > 0 && parts[0] !== "") {
                    directories.add(parts[0]);
                }
            }

            const folders = [];
            for (const dir of directories) folders.push({ name: dir });
            if (folders.length > 0) _TarballDirectoryList.append(folders);
        }
    }

    Process {
        id: _ExtractionProcess
        
        stdout: StdioCollector { id: extraction_stdout }
        stderr: StdioCollector { id: extraction_stderr }
        running: false

        function run() {
            if (!root.context.packagePath || !root.context.packageDirectory || !root.context.extractionDirectory) return;

            let args = [
                "sh", `${Quickshell.shellDir}/Scripts/ExtractTarball.sh`,
                "--package", root.context.packagePath,
                "--folder", root.context.packageDirectory,
                "--destination", root.extractionPath
            ];

            if (Constants.wizard_tarball_delete_original_packages) {
                args.push("--delete");
            }

            command = args;
            running = true;
        }

        onRunningChanged: {
            if (running) return;

            const log = extraction_stdout.text.trim();
            const err = extraction_stderr.text.trim();

            command = [];

            if (err.length > 0) {
                Debug.log(["Wizard", "Tarball", "Extraction" ], `Failed: ${err}`);
                return;
            }

            Debug.log(["Wizard", "Tarball", "Extraction" ], `Completed:\n${log}`);
            root.success = true;
            _SuccessTimeout.start();
        }
    }

    Timer {
        id: _SuccessTimeout
        interval: 1000
        repeat: false

        readonly property string packageName: root.getPackageName(root.context.packagePath)

        onTriggered: {
            NotificationService.push(
                "Installation Completed",
                `Package: ${packageName}\nExtracted ${root.context.extractionDirectory} to ${root.extractionPath}`
            );
            root.completed();
        }
    }
}