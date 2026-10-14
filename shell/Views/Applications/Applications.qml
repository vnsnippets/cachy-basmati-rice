pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import qs
import qs.Services
import qs.Components

ListView {
    id: root

    required property int page_size
    required property int item_height
    readonly property int max_height: ((item_height + spacing) * page_size) - spacing

    implicitHeight: max_height

    clip: true
    currentIndex: 0
    keyNavigationEnabled: false

    delegate: Clickable {
        id: item

        width: ListView.view.width
        implicitHeight: root.item_height

        required property int index
        required property string id
        required property string name
        required property string icon
        required property var app

        readonly property bool is_selected: root.currentIndex === item.index
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
                    source: Quickshell.iconPath(item.icon, true)
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
            root.currentIndex = item.index;
            item.app.execute();
            EventOrchestrator.consoleDismissContentEvent();
        }
    }

    add: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150; easing.type: Easing.OutQuad }
        NumberAnimation { property: "y"; from: root.height; duration: 200; easing.type: Easing.OutQuad }
    }

    displaced: Transition {
        NumberAnimation { properties: "x,y"; duration: 200; easing.type: Easing.OutQuad }
    }

    remove: Transition {
        NumberAnimation { property: "opacity"; to: 0.0; duration: 150 }
        NumberAnimation { property: "scale"; to: 0.8; duration: 150 }
    }
}