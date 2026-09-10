pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

import qs
import qs.Services
import qs.Utilities
import "../Components"

PanelWindow {
    id: _Container

    anchors.bottom: true
    anchors.right: true

    focusable: false
    color: "transparent"

    // Use a JS Array instead of ListModel to preserve C++ QObjects and their methods
    property var notificationList: []

    visible: notificationList.length > 0

    mask: Region { item: _NotificationColumn }

    readonly property int _padding: Constants.padding * 2

    implicitWidth: Constants.osd_width + (_padding * 2)
    implicitHeight: _NotificationColumn.implicitHeight + (_padding * 2)

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: Constants.namespace
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Column {
        id: _NotificationColumn

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: _Container._padding

        spacing: Constants.padding

        Repeater {
            model: _Container.notificationList

            delegate: Clickable {
                id: _DelegateItem

                required property var modelData
                required property int index

                readonly property var notifObj: _DelegateItem.modelData.notification
                readonly property int timestamp: _DelegateItem.modelData.timestamp

                Component.onCompleted: Debug.json(notifObj);

                width: Constants.osd_width
                implicitWidth: Constants.osd_width
                implicitHeight: _CardBackground.implicitHeight

                onContainsMouseChanged: {
                    if (containsMouse) _DismissTimer.stop();
                    else _DismissTimer.restart();
                }

                onClicked: _DelegateItem.dismiss();

                function dismiss() {
                    _DismissTimer.stop();
                    if (index >= 0 && index < _Container.notificationList.length) {
                        var list = _Container.notificationList.slice();
                        list.splice(index, 1);
                        _Container.notificationList = list;
                    }
                }

                Timer {
                    id: _DismissTimer
                    interval: Constants.osd_timeout
                    running: true
                    repeat: false
                    onTriggered: _DelegateItem.dismiss();
                }

                Rectangle {
                    id: _CardBackground

                    readonly property int item_padding: Constants.padding * 3 

                    width: Constants.osd_width
                    implicitHeight: _ContentColumn.implicitHeight + item_padding

                    color: Constants.color_base
                    radius: Constants.radius
                    border.width: 1
                    border.color: Constants.color_overlay

                    ColumnLayout {
                        id: _ContentColumn
                        width: parent.width - _CardBackground.item_padding
                        anchors.centerIn: parent
                        spacing: Constants.spacing / 2

                        RowLayout {
                            id: _HeadingText
                            spacing: Constants.spacing

                            StyledText {
                                text: Qt.formatDateTime(new Date(_DelegateItem.timestamp), "hh:mm AP")
                                color: Constants.color_muted
                                font.pixelSize: Constants.font_size
                                horizontalAlignment: Text.AlignLeft
                            }

                            StyledText {
                                readonly property string appName: _DelegateItem.notifObj.appName
                                visible: appName !== "notify-send" && appName.length > 0
                                text: appName
                                color: Constants.color_muted
                                font.pixelSize: Constants.font_size
                                horizontalAlignment: Text.AlignLeft
                            }

                            Item { Layout.fillWidth: true }

                            ClickableWithIcon {
                                size: 16
                                iconname: "dismiss.svg"
                                styles.icon.color.idle: Constants.color_muted
                                styles.icon.color.active: Constants.color_red
                                onClicked: _DelegateItem.dismiss()
                            }
                        }

                        StyledText {
                            id: _SummaryText
                            Layout.fillWidth: true

                            readonly property string summary: _DelegateItem.notifObj.summary.trim()
                            visible: summary.length > 0
                            text: summary
                            color: Constants.color_muted
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignLeft
                        }

                        StyledText {
                            id: _BodyText
                            Layout.fillWidth: true
                            text: _DelegateItem.notifObj.body
                            color: Constants.color_text
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignLeft
                        }

                        // Notification Actions
                        RowLayout {
                            id: _ActionsRow
                            Layout.fillWidth: true
                            Layout.topMargin: Constants.spacing / 2

                            visible: _DelegateItem.notifObj.actions.length > 0
                            spacing: Constants.spacing

                            Repeater {
                                model: _DelegateItem.notifObj.actions ?? []

                                delegate: Clickable {
                                    id: _ActionButton
                                    required property var modelData

                                    implicitHeight: _ActionText.implicitHeight + Constants.padding

                                    StyledText {
                                        id: _ActionText
                                        anchors.centerIn: parent
                                        text: _ActionButton.modelData.text
                                        colors.idle: Constants.color_muted
                                        colors.active: Constants.color_text
                                        font.pixelSize: Constants.font_size
                                        active: _ActionButton.containsMouse
                                    }

                                    onClicked: {
                                        _ActionButton.modelData.invoke();
                                        _DelegateItem.dismiss();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Scope {
        NotificationServer {
            id: _NotificationServer

            bodySupported: true
            bodyMarkupSupported: true
            actionsSupported: true
            imageSupported: true

            onNotification: (notification) => {
                var list = _Container.notificationList.slice();
                list.push({
                    timestamp: Date.now(),
                    notification: notification
                });
                _Container.notificationList = list;

                Debug.log(_Container.screen.name, "[Notification]", "Received:", notification.appName, notification.body);
            }
        }
    }
}