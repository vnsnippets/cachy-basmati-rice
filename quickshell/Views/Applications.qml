import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland

import qs.Utilities
import qs.Components

ColumnLayout {
    id: root

    required property int maxheight
    readonly property int itemheight: Styles.applications.item.height + Styles.padding
    readonly property string defaultappicon: "application-x-executable"

    spacing: Styles.spacing

    function updateSearchResults() {
        const filterText = searchInput.text.toLowerCase();
        
        const matchingAppNames = new Set();
        for (const app of DesktopEntries.applications.values) {
            if (app.noDisplay) continue;
            
            if (app.name.toLowerCase().includes(filterText)) {
                matchingAppNames.add(app.name);
                
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

        for (let i = filteredApps.count - 1; i >= 0; i--) {
            const currentItemName = filteredApps.get(i).name;
            if (!matchingAppNames.has(currentItemName)) {
                filteredApps.remove(i);
            }
        }

        appListView.currentIndex = 0;
    }

    function insertAlphabetically(app) {
        const appName = app.name.toLowerCase();
        let insertIndex = filteredApps.count;

        for (let i = 0; i < filteredApps.count; i++) {
            if (filteredApps.get(i).name.toLowerCase().localeCompare(appName) > 0) {
                insertIndex = i;
                break;
            }
        }

        filteredApps.insert(insertIndex, {
            name: app.name,
            icon: app.icon ? app.icon : root.defaultappicon,
            app: app
        });
    }

    ListModel { id: filteredApps }

    TextField {
        id: searchInput
        
        Layout.fillWidth: true
        Layout.preferredHeight: root.itemheight

        leftPadding: icon.size + icon.padding + Styles.padding
        rightPadding: Styles.padding
        verticalAlignment: TextInput.AlignVCenter
        
        color: Styles.applications.searchbox.text
        font.pixelSize: 14
        focus: true
        
        placeholderText: Styles.applications.searchbox.placeholder
        placeholderTextColor: Qt.alpha(color, 0.5)

        ClickableWithIcon {
            id: icon
            size: 20
            padding: 12
            anchors.verticalCenter: parent.verticalCenter
            iconname: Styles.applications.searchbox.icon
            enabled: false
            iconstyle.idle: Qt.alpha(searchInput.color, 0.5)
            iconstyle.active: Qt.alpha(searchInput.color, 0.5)
        }

        background: Rectangle {
            color: searchInput.activeFocus ? Qt.alpha(Styles.applications.searchbox.background, 0.9) : Qt.alpha(Styles.applications.searchbox.background, 0.75)
            radius: Styles.radius
            border.color: searchInput.activeFocus ? Styles.applications.searchbox.border.active : Styles.applications.searchbox.border.idle
            border.width: 1
        }

        Keys.onEscapePressed: canvas.dismiss()
        Keys.onReturnPressed: {
            if (filteredApps.count > 0) {
                filteredApps.get(appListView.currentIndex).app.execute();
                canvas.dismiss();
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
        
        HoverHandler { cursorShape: Qt.IBeamCursor }
    }

    ListView {
        id: appListView
        model: filteredApps

        Layout.fillWidth: true
        implicitHeight: root.maxheight

        spacing: Styles.spacing
        clip: true
        currentIndex: 0
        keyNavigationEnabled: false

        Component.onCompleted: DesktopEntries.applications.values.forEach((app) => filteredApps.append({
            name: app.name,
            icon: app.icon ? app.icon : root.defaultappicon,
            app: app
        }))

        delegate: Clickable {
            id: appItem
            anchors.left: parent?.left
            anchors.right: parent?.right
            height: root.itemheight
            radius: Styles.radius

            readonly property bool isSelected: appListView.currentIndex === model.index
            active: appItem.containsMouse || isSelected

            styles.background.idle: Styles.applications.item.background.idle
            styles.background.active: Styles.applications.item.background.active
            styles.border.idle: Styles.applications.item.border.idle
            styles.border.active: Styles.applications.item.border.active

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Styles.padding
                anchors.rightMargin: Styles.padding
                spacing: Styles.padding

                IconImage {
                    implicitSize: Styles.applications.item.height - Styles.padding * 1.5
                    source: "image://icon/" + model.icon
                    mipmap: true
                }

                StyledText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter

                    style.idle: Styles.applications.item.text.idle
                    style.active: Styles.applications.item.text.active
                    active: appItem.containsMouse || appItem.isSelected

                    text: model.name
                }

                StyledText {
                    visible: model.app.genericName != model.name
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter

                    style.idle: Styles.applications.item.text.idle
                    style.active: Styles.applications.item.text.active
                    active: appItem.containsMouse || appItem.isSelected

                    text: model.app.genericName
                }
            }

            onClicked: {
                appListView.currentIndex = model.index;
                model.app.execute();
                canvas.dismiss();
            }
        }

        // --- ANIMATIONS ---
        add: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150; easing.type: Easing.OutQuad }
            NumberAnimation { property: "y"; from: appListView.height; duration: 200; easing.type: Easing.OutQuad }
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
        target: searchInput
        function onTextChanged() { root.updateSearchResults(); }
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { root.updateSearchResults(); }
    } 
}