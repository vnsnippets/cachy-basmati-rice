pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Widgets

import qs
import qs.Services
import qs.Components

ColumnLayout {
    id: spotlight

    required property int max_height
    readonly property string default_app_icon: "application-x-executable"

    spacing: Constants.spacing

    function updateSearchResults() {
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
        list_filtered_apps.clear();
        for (const app of matches) {
            list_filtered_apps.append({
                name: app.name,
                icon: app.icon ? app.icon : spotlight.default_app_icon,
                app: app
            });
        }

        app_list_view.currentIndex = 0;
    }

    ListModel { id: list_filtered_apps }

    TextField {
        id: search_text_field
        
        Layout.fillWidth: true
        Layout.preferredHeight: Constants.spotlight_search_height

        leftPadding: icon.size + icon.padding + Constants.padding
        rightPadding: Constants.padding
        verticalAlignment: TextInput.AlignVCenter
        
        color: Constants.spotlight_search_color_text
        font.pixelSize: 14
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
            icon_color: Constants.spotlight_search_color_icon
        }

        background: Rectangle {
            color: (search_text_field.activeFocus) ? Constants.spotlight_search_color_background_active : Constants.spotlight_search_color_background
            border.color: (search_text_field.activeFocus) ? Constants.spotlight_search_color_border_active : Constants.spotlight_search_color_border
            radius: Constants.radius
        }

        Keys.onEscapePressed: EventOrchestrator.consoleCloseEvent()

        Keys.onReturnPressed: {
            if (list_filtered_apps.count > 0 && app_list_view.currentIndex >= 0) {
                list_filtered_apps.get(app_list_view.currentIndex).app.execute();
                EventOrchestrator.consoleCloseEvent();
            }
        }

        Keys.onUpPressed: {
            if (app_list_view.currentIndex > 0) {
                app_list_view.currentIndex -= 1;
            }
        }

        Keys.onDownPressed: {
            if (app_list_view.currentIndex < list_filtered_apps.count - 1) {
                app_list_view.currentIndex += 1;
            } else {
                app_list_view.currentIndex = 0;
            }
        }

        Component.onCompleted: search_text_field.forceActiveFocus();
        
        HoverHandler { cursorShape: Qt.IBeamCursor }
    }

    ListView {
        id: app_list_view
        model: list_filtered_apps

        Layout.fillWidth: true
        implicitHeight: spotlight.max_height

        spacing: Constants.padding
        clip: true
        currentIndex: 0
        keyNavigationEnabled: false

        // Perform initial alphabetical sort on completion
        Component.onCompleted: spotlight.updateSearchResults()

        delegate: Clickable {
            id: item

            width: ListView.view.width
            implicitHeight: Constants.spotlight_app_height

            required property int index
            required property string name
            required property string icon
            required property var app

            readonly property bool is_selected: app_list_view.currentIndex === item.index
            readonly property bool active: item.containsMouse || is_selected

            Rectangle {
                id: item_container
                
                anchors.fill: parent
                radius: Constants.radius
                color: (item.active) ? Constants.spotlight_app_background_color_active : Constants.spotlight_app_background_color

                border.width: 1
                border.color: (item.active) ? Constants.spotlight_app_border_color_active : Constants.spotlight_app_border_color

                Behavior on radius { NumberAnimation { duration: Constants.animation_duration } }
                Behavior on color { ColorAnimation { duration: Constants.animation_duration } }
                Behavior on border.color { ColorAnimation { duration: Constants.animation_duration } }

                RowLayout {
                    id: item_details
                    
                    anchors.fill: parent
                    anchors.leftMargin: Constants.padding
                    anchors.rightMargin: Constants.padding
                    spacing: Constants.padding

                    IconImage {
                        implicitSize: Constants.spotlight_app_height - Constants.padding * 1.5
                        source: "image://icon/" + item.icon
                        mipmap: true
                    }

                    StyledText {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter

                        styles.color_idle: Constants.spotlight_app_color_text
                        styles.color_active: Constants.spotlight_app_color_text_active

                        active: item.active

                        text: item.name
                    }

                    StyledText {
                        visible: item.app.genericName != item.name
                        Layout.fillWidth: false
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter

                        styles.color_idle: Constants.spotlight_app_color_text
                        styles.color_active: Constants.spotlight_app_color_text_active

                        active: item.active

                        text: item.app.genericName ? item.app.genericName : ""
                    }
                }
            }

            onClicked: {
                app_list_view.currentIndex = item.index;
                item.app.execute();
                EventOrchestrator.consoleCloseEvent();
            }
        }

        // --- ANIMATIONS ---
        add: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150; easing.type: Easing.OutQuad }
            NumberAnimation { property: "y"; from: app_list_view.height; duration: 200; easing.type: Easing.OutQuad }
        }

        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 200; easing.type: Easing.OutQuad }
        }

        remove: Transition {
            NumberAnimation { property: "opacity"; to: 0.0; duration: 150 }
            NumberAnimation { property: "scale"; to: 0.8; duration: 150 }
        }
    }

    Connections {
        target: search_text_field
        function onTextChanged() { spotlight.updateSearchResults(); }
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { spotlight.updateSearchResults(); }
    } 
}