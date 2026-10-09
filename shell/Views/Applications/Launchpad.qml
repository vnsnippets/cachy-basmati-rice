pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs
import qs.Services
import qs.Components
import qs.Views.Applications

ColumnLayout {
    id: root

    required property int page_size
    readonly property string default_app_icon: "application-x-executable"

    spacing: Constants.spacing

    ListModel { 
        id: results
        function update() {
            const filterText = search_text_field.text.toLowerCase().trim();
            
            // Collect all matching applications
            const matches = [];
            for (const app of DesktopEntries.applications.values) {
                if (app.noDisplay) continue;
                
                if (filterText === "" || app.name.toLowerCase().includes(filterText)) {
                    matches.push(app);
                }
            }

            // Sort matching apps alphabetically by name
            matches.sort((a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase()));

            // Rebuild model content in alphabetical order
            results.clear();
            for (const app of matches) {
                results.append({
                    id: app.id,
                    name: app.name,
                    icon: app.icon ? app.icon : root.default_app_icon,
                    app: app
                });
            }

            apps.currentIndex = 0;
        }
    }

    TextField {
        id: search_text_field
        
        Layout.fillWidth: true
        Layout.preferredHeight: Constants.spotlight_item_height

        leftPadding: icon.size + icon.padding + Constants.padding
        rightPadding: Constants.padding
        verticalAlignment: TextInput.AlignVCenter
        
        color: Constants.spotlight_color_ink_active
        font.pixelSize: Constants.font_size
        focus: true
        
        placeholderText: Constants.spotlight_search_placeholder
        placeholderTextColor: Qt.alpha(color, 0.5)

        ClickableWithIcon {
            id: icon
            size: 20
            padding: 12
            anchors.verticalCenter: parent.verticalCenter
            iconname: "search.svg"
            enabled: false
            icon_color: Qt.alpha(Constants.spotlight_color_ink_muted, (search_text_field.activeFocus) ? 0.60: 0.20)
        }

        background: Rectangle {
            color: (search_text_field.activeFocus) ? Constants.spotlight_color_background_active : Constants.spotlight_color_background_default
            border.color: Qt.alpha(Constants.spotlight_color_border, (search_text_field.activeFocus) ? 0.50: 0.15)
            radius: Constants.radius
        }

        Keys.onEscapePressed: EventOrchestrator.consoleDismissContentEvent()

        Keys.onReturnPressed: {
            if (results.count > 0 && apps.currentIndex >= 0) {
                results.get(apps.currentIndex).app.execute();
                EventOrchestrator.consoleDismissContentEvent();
            }
        }

        Keys.onUpPressed: {
            if (apps.currentIndex > 0) {
                apps.currentIndex -= 1;
            }
        }

        Keys.onDownPressed: {
            if (apps.currentIndex < results.count - 1) {
                apps.currentIndex += 1;
            } else {
                apps.currentIndex = 0;
            }
        }

        Component.onCompleted: search_text_field.forceActiveFocus();
        
        HoverHandler { cursorShape: Qt.IBeamCursor }
    }

    ListApplications {
        id: apps
        model: results        
        spacing: root.spacing
        Layout.fillWidth: true

        item_height: Constants.spotlight_item_height
        page_size: root.page_size

        Component.onCompleted: results.update()
    }

    Connections {
        target: search_text_field
        function onTextChanged() { results.update(); }
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { results.update(); }
    } 
}