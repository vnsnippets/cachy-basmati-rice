pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

import qs
import qs.Services
import "../Components"

PanelWindow {
    id: _Container

    anchors.bottom: true
    anchors.right: true

    focusable: false
    color: "transparent"

    visible: NotificationService.items.count > 0

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
            model: NotificationService.items

            delegate: Clickable {
                id: _DelegateItem

                required property var modelData
                required property int index

                width: Constants.osd_width
                implicitWidth: Constants.osd_width
                implicitHeight: _CardBackground.implicitHeight

                onContainsMouseChanged: {
                    if (containsMouse) _DismissTimer.stop();
                    else _DismissTimer.restart();
                }

                onClicked: {
                    var actions = _DelegateItem.modelData ? _DelegateItem.modelData.actions : null;
                    var defaultAction = actions ? actions.find(a => (a.identifier || a.id) === "default") : null;
                    if (defaultAction) {
                        defaultAction.invoke(); // Fully preserved!
                    }
                }

                function dismiss() {
                    _DismissTimer.stop();
                    NotificationService.remove(_DelegateItem.modelData)
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

                            // Application Icon (Left of timestamp)
                            Image {
                                id: _AppIcon

                                readonly property string rawIcon: _DelegateItem.modelData.notification.appIcon ?? ""

                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                Layout.alignment: Qt.AlignVCenter

                                // Hide if no icon is supplied or if icon fails to resolve
                                visible: rawIcon.length > 0 && status === Image.Ready

                                source: {
                                    if (!rawIcon) return "";
                                    if (rawIcon.startsWith("/") || rawIcon.startsWith("file://")) {
                                        return rawIcon;
                                    }
                                    return "image://icon/" + rawIcon;
                                }

                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                            }

                            StyledText {
                                text: Qt.formatDateTime(_DelegateItem.modelData.createdAt, "HH:mm")
                                color: Constants.color_muted
                                font.pixelSize: Constants.font_size
                                horizontalAlignment: Text.AlignLeft
                            }

                            StyledText {
                                readonly property string appName: _DelegateItem.modelData.notification?.appName ?? ""
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

                            readonly property string summary: _DelegateItem.modelData.notification?.summary.trim() ?? ""
                            visible: summary.length > 0
                            text: summary
                            color: Constants.color_muted
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignLeft
                        }

                        StyledText {
                            id: _BodyText
                            Layout.fillWidth: true
                            text: _DelegateItem.modelData.notification.body
                            color: Constants.color_text
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignLeft
                        }

                        // Notification Actions
                        RowLayout {
                            id: _ActionsRow
                            Layout.fillWidth: true
                            Layout.topMargin: Constants.spacing / 2

                            visible: _DelegateItem.modelData.notification.actions.length > 0
                            spacing: Constants.spacing

                            Repeater {
                                model: _DelegateItem.modelData.notification.actions.filter((a => (a.identifier || a.id) !== "default")) ?? []

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
}