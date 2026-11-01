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

    property bool showHiddenApps: false

    spacing: Constants.spacing

    ListModel { 
        id: _SearchResults
        function update() {
            const filterText = _SearchTextField.text.toLowerCase().trim();
            
            // Collect all matching applications
            const matches = [];
            for (const app of DesktopEntries.applications.values) {
                if (app.noDisplay) continue;
                
                // Exclude hidden apps if showHiddenApps is false
                if (!root.showHiddenApps && Constants.spotlight_hidden_apps && Constants.spotlight_hidden_apps.includes(app.id)) {
                    continue;
                }
                
                if (filterText === "" || app.name.toLowerCase().includes(filterText)) {
                    matches.push(app);
                }
            }

            // Sort matching _ApplicationsView alphabetically by name
            matches.sort((a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase()));

            // Rebuild model content in alphabetical order
            _SearchResults.clear();
            for (const app of matches) {
                _SearchResults.append({
                    id: app.id,
                    name: app.name,
                    icon: app.icon ? app.icon : root.default_app_icon,
                    app: app
                });
            }

            _ApplicationsView.currentIndex = 0;
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Constants.spacing

        TextField {
            id: _SearchTextField
            
            Layout.fillWidth: true
            Layout.preferredHeight: Constants.spotlight_item_height

            readonly property int iconSize: 20
            readonly property int iconPadding: 12

            leftPadding: iconSize + iconPadding + Constants.padding
            rightPadding: iconSize + iconPadding + Constants.padding

            verticalAlignment: TextInput.AlignVCenter
            
            color: Constants.spotlight_color_ink_active
            font.pixelSize: Constants.font_size
            focus: true
            
            placeholderText: Constants.spotlight_search_placeholder
            placeholderTextColor: Qt.alpha(color, 0.5)

            ClickableWithIcon {
                size: _SearchTextField.iconSize
                padding: _SearchTextField.iconPadding
                anchors.verticalCenter: parent.verticalCenter
                iconname: "Search.svg"
                enabled: false
                icon_color: Qt.alpha(Constants.spotlight_color_ink_muted, (_SearchTextField.activeFocus) ? 0.60: 0.20)
            }

            ClickableWithIcon {
                size: _SearchTextField.iconSize
                padding: _SearchTextField.iconPadding
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                iconname: root.showHiddenApps ? "Eye.svg" : "Eye-Off.svg"
                styles.icon_color_idle: Constants.spotlight_color_ink_muted
                styles.icon_color_active: Constants.spotlight_color_ink_active
                active: root.showHiddenApps
                onClicked: {
                    root.showHiddenApps = !root.showHiddenApps;
                    _SearchTextField.forceActiveFocus();
                    _SearchResults.update();
                }
            }

            background: Rectangle {
                color: (_SearchTextField.activeFocus) ? Constants.spotlight_color_background_active : Constants.spotlight_color_background_default
                border.color: Qt.alpha(Constants.spotlight_color_border, (_SearchTextField.activeFocus) ? 0.50: 0.15)
                radius: Constants.radius
            }

            Keys.onEscapePressed: EventOrchestrator.consoleDismissContentEvent()

            Keys.onReturnPressed: {
                if (_SearchResults.count > 0 && _ApplicationsView.currentIndex >= 0) {
                    _SearchResults.get(_ApplicationsView.currentIndex).app.execute();
                    EventOrchestrator.consoleDismissContentEvent();
                }
            }

            Keys.onUpPressed: {
                if (_ApplicationsView.currentIndex > 0) {
                    _ApplicationsView.currentIndex -= 1;
                }
            }

            Keys.onDownPressed: {
                if (_ApplicationsView.currentIndex < _SearchResults.count - 1) {
                    _ApplicationsView.currentIndex += 1;
                } else {
                    _ApplicationsView.currentIndex = 0;
                }
            }

            Component.onCompleted: _SearchTextField.forceActiveFocus();
            
            HoverHandler { cursorShape: Qt.IBeamCursor }
        }
    }

    Applications {
        id: _ApplicationsView
        model: _SearchResults
        spacing: root.spacing
        Layout.fillWidth: true

        item_height: Constants.spotlight_item_height
        page_size: root.page_size

        Component.onCompleted: _SearchResults.update()
    }

    Connections {
        target: _SearchTextField
        function onTextChanged() { _SearchResults.update(); }
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { _SearchResults.update(); }
    } 
}