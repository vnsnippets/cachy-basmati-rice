import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland

import qs.Assets
import qs.Components

ColumnLayout {
    id: root
    spacing: Style.spacing * 4

    function dismiss() {
        panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None;
        shell.monitor = null;
    }

    function updateSearchResults() {
        const filterText = searchInput.text.toLowerCase();
        
        // 1. Create a Set of application names that currently match the search input
        const matchingAppNames = new Set();
        for (const app of DesktopEntries.applications.values) {
            if (app.noDisplay) continue;
            
            if (app.name.toLowerCase().includes(filterText)) {
                matchingAppNames.add(app.name);
                
                // If it's a match but NOT in the list yet, insert it alphabetically
                let alreadyExists = false;
                for (let i = 0; i < filteredApps.count; i++) {
                    if (filteredApps.get(i).name === app.name) {
                        alreadyExists = true;
                        break;
                    }
                }
                
                if (!alreadyExists) {
                    insertAlphabetically(app);
                }
            }
        }

        // 2. Remove items from the list that no longer match the search input
        // (Iterating backwards prevents index shifting bugs during removal)
        for (let i = filteredApps.count - 1; i >= 0; i--) {
            const currentItemName = filteredApps.get(i).name;
            if (!matchingAppNames.has(currentItemName)) {
                filteredApps.remove(i);
            }
        }

        // 3. Always reset selection to the first item after results change
        appListView.currentIndex = 0;
    }

    function insertAlphabetically(app) {
        const appName = app.name.toLowerCase();
        let insertIndex = filteredApps.count;

        // Find the correct alphabetical position
        for (let i = 0; i < filteredApps.count; i++) {
            if (filteredApps.get(i).name.toLowerCase().localeCompare(appName) > 0) {
                insertIndex = i;
                break;
            }
        }

        filteredApps.insert(insertIndex, {
            name: app.name,
            icon: app.icon ? app.icon : "application-x-executable",
            app: app
        });
    }

    ListModel { id: filteredApps }

    TextField {
        id: searchInput
        
        // Layout constraints transferred from the old Rectangle wrapper
        Layout.fillWidth: true
        Layout.leftMargin: Style.padding
        Layout.rightMargin: Style.padding
        implicitHeight: Style.clickable.dimensions.height + Style.padding

        // Padding inside the text field area
        leftPadding: (Style.padding * 2)  + 16
        rightPadding: Style.padding
        verticalAlignment: TextInput.AlignVCenter
        
        color: "#CDD6F4"
        font.pixelSize: 14
        focus: true
        
        placeholderText: "Search..."
        placeholderTextColor: Qt.alpha("#CDD6F4", 0.5)

        StyledText {
            anchors.left: parent.left
            anchors.leftMargin: Style.padding * 1.2
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 16
            text: ""
            color: Style.colors.text
            opacity: searchInput.activeFocus ? 0.8 : 0.4
        }

        // Custom styling goes directly into the background property
        background: Rectangle {
            color: searchInput.activeFocus ?
                Qt.alpha(Style.colors.surface, 0.4) : Qt.alpha(Style.colors.surface, 0.2)
            radius: 8
            border.color: searchInput.activeFocus ?
                Qt.alpha(Style.colors.overlay, 0.4) : "transparent"
            border.width: 1
        }

        Keys.onEscapePressed: root.dismiss()
        Keys.onReturnPressed: {
            if (filteredApps.count > 0) {
                filteredApps.get(appListView.currentIndex).app.execute();
                root.dismiss();
            }
        }
        Keys.onUpPressed: {
            if (appListView.currentIndex > 0) {
                appListView.currentIndex -= 1;
            }
        }
        Keys.onDownPressed: {
            if (appListView.currentIndex < filteredApps.count - 1) {
                appListView.currentIndex += 1;
            } else {
                appListView.currentIndex = 0;
            }
        }

        Component.onCompleted: {
            searchInput.forceActiveFocus();
        }
        
        HoverHandler {
            cursorShape: Qt.IBeamCursor
        }
    }

    ListView {
        id: appListView
        model: filteredApps

        Layout.fillWidth: true
        Layout.leftMargin: Style.padding
        Layout.rightMargin: Style.padding

        spacing: Style.spacing
        implicitHeight: 300

        clip: true
        currentIndex: 0
        keyNavigationEnabled: false  // Navigation handled manually via searchInput key events

        Component.onCompleted: DesktopEntries.applications.values.forEach((app) => filteredApps.append({
            name: app.name,
            icon: app.icon ? app.icon : "application-x-executable",
            app: app
        }))

        delegate: Clickable {
            id: appItem
            anchors.left: parent?.left
            anchors.right: parent?.right
            height: Style.clickable.dimensions.height + Style.padding
            radius: 4

            readonly property bool isSelected: appListView.currentIndex === model.index

            colors.background.idle: isSelected
                ? Qt.alpha(Style.colors.surface, 0.25)
                : Qt.alpha(Style.colors.surface, 0)
            colors.background.active: Qt.alpha(Style.colors.surface, 0.3)
            colors.border.idle: isSelected
                ? Qt.alpha(Style.colors.overlay, 0.3)
                : "transparent"
            colors.border.active: Qt.alpha(Style.colors.overlay, 0.2)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Style.padding
                anchors.rightMargin: Style.padding
                spacing: Style.padding

                IconImage {
                    implicitSize: Style.clickable.dimensions.height - Style.padding * 1.5
                    source: "image://icon/" + model.icon
                    mipmap: true
                }

                StyledText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter

                    style.idle: appItem.isSelected ? Style.colors.text : Style.colors.subtext
                    style.active: Style.colors.text
                    active: appItem.containsMouse || appItem.isSelected

                    text: model.name
                }
            }

            onClicked: {
                appListView.currentIndex = model.index;
                // model.app.execute();

                // For UWSM
                // 1. Take the app's native executable array (e.g., ["firefox", "--new-window"])
                let nativeCommand = model.app.command;
                
                // 2. Build the UWSM prefixed command array
                let uwsmCommand = ["uwsm", "app", "--"].concat(nativeCommand);
                
                // 3. Launch it detached so it safely breaks off into its own systemd scope
                Quickshell.execDetached({
                    command: uwsmCommand,
                    workingDirectory: model.app.workingDirectory
                });
                            
                root.dismiss();
            }
        }

        // --- ANIMATIONS ---
        // 1. When an item is added / appears
        add: Transition {
            NumberAnimation { 
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: 150
                easing.type: Easing.OutQuad
            }
            NumberAnimation { 
                property: "y"
                from: appListView.height // Slides up from the bottom of the list
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        // 2. When existing items shift positions around adding/removing items
        displaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        // 3. When an item is removed / hidden
        remove: Transition {
            NumberAnimation { 
                property: "opacity"
                to: 0.0
                duration: 150
            }
            // Keeps the layout stable while fading out
            NumberAnimation { 
                property: "scale"
                to: 0.8
                duration: 150
            }
        }
        // ------------------
    }

    Connections {
        target: searchInput
        function onTextChanged() { root.updateSearchResults(); }
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { root.updateSearchResults(); }
    } 
}