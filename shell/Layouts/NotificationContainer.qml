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

    visible: _NotificationModel.count > 0

    mask: Region { item: _NotificationColumn }

    readonly property int _padding: Constants.padding * 2

    implicitWidth: Constants.osd_width + (_padding * 2)
    implicitHeight: _NotificationColumn.implicitHeight + (_padding * 2)

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: Constants.namespace
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    ListModel { id: _NotificationModel; }

    Column {
        id: _NotificationColumn

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: _Container._padding

        spacing: Constants.padding

        Repeater {
            model: _NotificationModel

            delegate: Clickable {
                id: _DelegateItem

                required property var notification
                required property int timestamp
                required property int index

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
                    if (index >= 0 && index < _NotificationModel.count) {
                        _NotificationModel.remove(index);
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
                                readonly property string appName: _DelegateItem.notification.appName.trim()
                                Layout.fillWidth: true
                                visible: appName !== "notify-send" && appName.length > 0
                                text: appName
                                color: Constants.color_muted
                                font.pixelSize: Constants.font_size
                                horizontalAlignment: Text.AlignLeft
                            }
                        }

                        StyledText {
                            id: _BodyText
                            Layout.fillWidth: true
                            text: _DelegateItem.notification.body
                            color: Constants.color_text
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignLeft
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
                _NotificationModel.append({
                    timestamp: Date.now(),
                    notification: {
                        appName: notification.appName,
                        body: notification.body,
                        summary: notification.summary,
                        urgency: notification.urgency,
                        obj: notification
                    }
                });
                
                Debug.log(_Container.screen.name, "[Notification]", "Received:", notification.appName, notification.body);
                Debug.json(notification);
            }
        }
    }
}