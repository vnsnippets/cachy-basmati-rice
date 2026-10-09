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

    required property int page_size

    readonly property int result_item_height: Constants.spotlight_item_height //+ Constants.spacing
    readonly property int max_height: ((result_item_height + spacing) * page_size) - spacing
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
                id: app.id,
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
            if (list_filtered_apps.count > 0 && app_list_view.currentIndex >= 0) {
                list_filtered_apps.get(app_list_view.currentIndex).app.execute();
                EventOrchestrator.consoleDismissContentEvent();
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

        spacing: spotlight.spacing
        clip: true
        currentIndex: 0
        keyNavigationEnabled: false

        Component.onCompleted: spotlight.updateSearchResults()

        delegate: Clickable {
            id: item

            width: ListView.view.width
            implicitHeight: spotlight.result_item_height

            required property int index
            required property string id
            required property string name
            required property string icon
            required property var app

            readonly property bool is_selected: app_list_view.currentIndex === item.index
            readonly property bool active: item.containsMouse || is_selected

            Rectangle {
                id: item_container
                
                anchors.fill: parent
                radius: Constants.radius
                color: (item.is_selected) ? Constants.spotlight_color_background_active : Constants.color_transparent

                border.width: 1
                border.color: Qt.alpha(Constants.spotlight_color_border, (item.active) ? 0.25 : 0)

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
                        implicitSize: Constants.spotlight_item_height - Constants.padding * 2
                        source: "image://icon/" + item.icon
                        mipmap: true
                    }

                    StyledText {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter

                        styles.color_idle: Constants.spotlight_color_ink_muted
                        styles.color_active: Constants.spotlight_color_ink_active

                        active: item.active

                        text: item.name
                    }

                    StyledText {
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter

                        styles.color_idle: Constants.spotlight_color_ink_muted
                        styles.color_active: Constants.spotlight_color_ink_active

                        active: item.active
                        opacity: (active) ? 0.70 : 0.50

                        text: (Constants.spotlight_show_appid) ? item.id : item.app.genericName ? item.app.genericName : ""

                        Behavior on opacity { NumberAnimation { duration: Constants.animation_duration } }
                    }
                }
            }

            onClicked: {
                app_list_view.currentIndex = item.index;
                item.app.execute();
                EventOrchestrator.consoleDismissContentEvent();
            }
        }

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