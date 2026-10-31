pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell.Io

import qs
import qs.Layouts
import qs.Services
import qs.Utilities

ColumnLayout {
    id: root

    spacing: Constants.spacing

    signal completed

    ListModel { id: tarball_folders_listmodel }

    QtObject {
        id: context
        property string selected_tarball_name: ""
        property string selected_tarball_path: ""
        property string selected_tarball_folder: ""
        property string destination_folder: ""
    }

    ContentContainerForTabs {
        id: container

        Layout.fillWidth: true
        Layout.fillHeight: true

        Component {
            id: tarball_selection_step
            WizardTarballSelection {
                Layout.fillWidth: true                
                onTarballSelected: (path, name) => {
                    context.selected_tarball_path = path;
                    context.selected_tarball_name = name;
                    container.next();
                }
            }
        }

        Component {
            id: tarball_extraction_step
            WizardTarballExtraction {
                Layout.fillWidth: true
                selected_tarball_path: context.selected_tarball_path
                onBackPressed: {
                    context.selected_tarball_name = context.selected_tarball_path = context.selected_tarball_folder = "";
                    container.previous();
                }

                onExtractionStart: (source, target) => {
                    context.selected_tarball_folder = source;
                    context.destination_folder = target;
                    container.next();
                }
            }
        }

        Component {
            id: tarball_completed_step
            WizardTarballCompleted {
                Layout.fillWidth: true
                tarball_name: context.selected_tarball_name
                tarball_path: context.selected_tarball_path
                source_directory: context.selected_tarball_folder
                destination_directory: context.destination_folder

                onCompleted: root.completed()
            }
        }

        tabs: [
            {
                name: "Select",
                template: tarball_selection_step,
                context: null,
                active: true
            },
            {
                name: "Configure",
                template: tarball_extraction_step,
                context: null,
                active: context.selected_tarball_path !== ""
            },
            {
                name: "Install",
                template: tarball_completed_step,
                context: null,
                active: context.selected_tarball_path !== "" && context.selected_tarball_folder !== ""
            }
        ]
    }
}