pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import qs
import qs.Services
import "../Components"

PanelWindow {
    id: _Container

    anchors.bottom: true
    anchors.right: true

    focusable: false
    color: "transparent"

    // Use count or values.length for visibility without resetting model delegates
    visible: NotificationService.notifications.values.length > 0

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
            // Bind directly to the model to preserve existing delegate instances and timers
            model: NotificationService.notifications

            delegate: Clickable {
                id: _DelegateItem

                // Capture timestamp at delegate creation so clock doesn't tick forward on re-render
                readonly property date createdAt: new Date()

                required property var modelData

                width: Constants.osd_width
                implicitWidth: Constants.osd_width
                implicitHeight: _CardBackground.implicitHeight

                onContainsMouseChanged: {
                    if (containsMouse) _DismissTimer.stop();
                    else _DismissTimer.restart();
                }

                onClicked: {
                    const defaultAction = modelData.actions.find(a => a && (a.identifier === "default" || a.id === "default"));
                    if (defaultAction) {
                        defaultAction.invoke();
                        _DismissTimer.stop();
                        modelData.dismiss();
                    }
                }

                Timer {
                    id: _DismissTimer
                    interval: Constants.notification_timeout
                    running: true
                    repeat: false
                    onTriggered: _DelegateItem.modelData.dismiss();
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

                            Image {
                                id: _AppIcon

                                readonly property string rawIcon: _DelegateItem.modelData.appIcon ?? ""

                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                Layout.alignment: Qt.AlignVCenter

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
                                text: _DelegateItem.createdAt.toLocaleTimeString(Qt.locale(), "HH:mm")
                                color: Constants.color_muted
                                font.pixelSize: Constants.font_size
                                horizontalAlignment: Text.AlignLeft
                            }

                            StyledText {
                                readonly property string appName: _DelegateItem.modelData?.appName ?? ""
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
                                onClicked: {
                                    _DismissTimer.stop();
                                    _DelegateItem.modelData.dismiss();
                                }
                            }
                        }

                        StyledText {
                            id: _SummaryText
                            Layout.fillWidth: true

                            readonly property string summary: _DelegateItem.modelData.summary.trim() ?? ""
                            visible: summary.length > 0
                            text: summary
                            color: Constants.color_muted
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignLeft
                        }

                        StyledText {
                            id: _BodyText
                            Layout.fillWidth: true
                            text: _DelegateItem.modelData.body
                            color: Constants.color_text
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignLeft
                        }

                        RowLayout {
                            id: _ActionsRow
                            Layout.fillWidth: true
                            Layout.topMargin: Constants.spacing / 2

                            visible: _DelegateItem.modelData.actions.length > 0
                            spacing: Constants.spacing

                            Repeater {
                                model: [ ..._DelegateItem.modelData.actions].filter((a => (a.identifier || a.id) !== "default")) ?? []

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
                                        _DismissTimer.stop();
                                        _ActionButton.modelData.invoke();
                                        _DelegateItem.modelData.dismiss();
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