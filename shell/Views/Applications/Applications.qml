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
        id: _ApplicationItem

        width: root.width
        implicitHeight: root.item_height

        required property int index
        required property string id
        required property string name
        required property string icon
        required property var app

        readonly property bool is_selected: root.currentIndex === _ApplicationItem.index
        readonly property bool active: _ApplicationItem.containsMouse || is_selected

        StyledBox {
            anchors.fill: parent
            radius: Constants.radius

            colors.background: (_ApplicationItem.is_selected) ? Constants.spotlight_color_background_active : Constants.color_transparent
            colors.border: Qt.alpha(Constants.spotlight_color_border, (_ApplicationItem.active) ? 0.25 : 0)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Constants.padding
                anchors.rightMargin: Constants.padding
                spacing: Constants.padding

                IconImage {
                    implicitSize: Constants.spotlight_item_height - Constants.padding * 2
                    source: Quickshell.iconPath(_ApplicationItem.icon, true)
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

                    active: _ApplicationItem.active

                    text: _ApplicationItem.name
                }

                StyledText {
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter

                    styles.color_idle: Constants.spotlight_color_ink_muted
                    styles.color_active: Constants.spotlight_color_ink_active

                    active: _ApplicationItem.active
                    opacity: (active) ? 0.70 : 0.50

                    text: (Constants.spotlight_show_appid) ? _ApplicationItem.id : _ApplicationItem.app.genericName ? _ApplicationItem.app.genericName : ""

                    Behavior on opacity { NumberAnimation { duration: Constants.animation_duration } }
                }
            }
        }

        onClicked: {
            root.currentIndex = _ApplicationItem.index;
            _ApplicationItem.app.execute();
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