pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs
import qs.Services
import qs.Utilities
import qs.Components

ColumnLayout {
    id: root

    required property string tarball_path
    required property string tarball_name
    required property string source_directory
    required property string destination_directory

    property bool is_completed: false

    signal completed

    spacing: Constants.spacing
    Layout.topMargin: Constants.padding * 2

    StyledText {
        font.pixelSize: Constants.font_size_lg
        color: root.is_completed ? Constants.color_green : Constants.color_yellow
        text: root.is_completed ? "Extraction completed successfully!" : "Extraction in progress..."
    }

    StyledText {
        color: Constants.spotlight_color_ink_muted
        text: `Package: ${root.tarball_name}/${root.source_directory} → ~/.local/apps`
    }

    Component.onCompleted: {
        const targetDirectory = "$HOME/.local/apps";
        const destinationPath = `${targetDirectory}/${destination_directory}`;
        const script = `
            mkdir -p "${targetDirectory}"
            rm -rf "${destinationPath}"
            mkdir -p "${destinationPath}"
            tar -xf "${tarball_path}" -C "${destinationPath}" --strip-components=1 "${source_directory}"
        `;
        
        Daemon.run("Tarball Installation", ["sh", "-c", script], (e) => {
            if (e.success) {
                Debug.log([ "Tarball Installation" ], "Installation completed successfully.");
                root.is_completed = true;
                timeout.start();
            }
        });
    }
    
    Timer {
        id: timeout
        interval: 2000
        repeat: false
        onTriggered: {
            NotificationService.push("Installation Completed", `Package: ${root.tarball_name}`);
            root.completed();
        }
    }
}