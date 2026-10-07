pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import qs
import qs.Services
import qs.Utilities
import qs.Components

// qmllint disable
PanelWindow {
// qmllint enable
    id: container

    anchors.bottom: true
    anchors.top: true
    anchors.right: true

    focusable: false
    color: "transparent"

    visible: NotificationService.notifications.values.length > 0

    mask: Region { item: _NotificationList }

    readonly property int _padding: Constants.notification_offset
    readonly property int _animationDuration: Constants.animation_duration

    implicitWidth: Constants.notification_width + (_padding * 2)

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: Constants.namespace
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    ListView {
        id: _NotificationList
        model: NotificationService.notifications

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: container._padding

        width: Constants.notification_width
        implicitWidth: Constants.notification_width
        implicitHeight: contentHeight

        spacing: Constants.padding
        interactive: false
        verticalLayoutDirection: ListView.BottomToTop

        HoverHandler { id: _ListViewHoverHandler }
        property alias hovered: _ListViewHoverHandler.hovered

        displaced: Transition {
            NumberAnimation {
                properties: "y"
                duration: container._animationDuration
                easing.type: Easing.OutCubic
            }
        }

        delegate: Clickable {
            id: delegate_item

            readonly property date createdAt: new Date()
            required property var modelData
            required property int index

            property real dismissProgress: 1.0
            NumberAnimation on dismissProgress {
                from: 1.0
                to: 0.0
                duration: dismiss_timeout.interval
                running: dismiss_timeout.running
            }

            readonly property bool appNameIsSummary: modelData?.appName.toLowerCase().trim() === modelData?.summary.toLowerCase().trim()

            width: Constants.notification_width
            implicitWidth: Constants.notification_width
            implicitHeight: _CardBackground.implicitHeight

            onClicked: {
                dismiss_timeout.stop();
                const defaultAction = modelData.actions.find(a => a && (a.identifier === "default" || a.id === "default"));
                Debug.log(container.screen.name, "[Notification]", delegate_item.modelData.appName, "", "Default Action");

                if (defaultAction) {
                    MangoIPCService.clients((clients) => {
                        try {
                            const target = NotificationService.target(clients, delegate_item.modelData);
                            if (target && target.id) {
                                Daemon.execute(["mmsg", "dispatch", "focusid", `client, ${target.id}`]);
                                defaultAction.invoke();
                            } else {
                                Debug.log(container.screen.name, "[Notification]", "Could not match notification to an active Mango client");
                            }
                        } catch (err) {
                            Debug.log(container.screen.name, "[Notification]", "Failed open target client:", err);
                        }
                    });
                    return;
                }

                dismiss_timeout.restart();
            }

            Timer {
                id: dismiss_timeout
                interval: Constants.notification_timeout
                running: !_NotificationList.hovered
                repeat: false
                onRunningChanged: {
                    if (!_NotificationList.hovered && delegate_item.state !== "hidden") {
                        dismiss_timeout.interval = Constants.notification_timeout / 2 * (delegate_item.index + 1)
                        delegate_item.dismissProgress = 1.0;
                    }
                }
                onTriggered: delegate_item.state = "hidden"
            }

            Rectangle {
                id: _CardBackground

                readonly property int item_padding: Constants.padding * 3

                width: Constants.notification_width
                implicitHeight: _ContentColumn.implicitHeight + item_padding

                color: Constants.notification_color_background
                radius: Constants.radius
                border.width: 1
                border.color: delegate_item.containsMouse ? Constants.notification_color_border_active : Constants.notification_color_border

                Behavior on border.color { ColorAnimation { duration: Constants.animation_duration } }

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

                            readonly property string rawIcon: delegate_item.modelData.appIcon ?? ""

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
                            text: delegate_item.createdAt.toLocaleTimeString(Qt.locale(), "HH:mm")
                            color: Constants.notification_color_subtext
                            font.pixelSize: Constants.font_size
                            horizontalAlignment: Text.AlignLeft
                        }

                        StyledText {
                            readonly property string appName: (delegate_item.appNameIsSummary) ? delegate_item.modelData?.summary : delegate_item.modelData?.appName
                            visible: appName !== "notify-send" && appName.length > 0
                            text: appName
                            color: Constants.notification_color_subtext
                            font.pixelSize: Constants.font_size
                            horizontalAlignment: Text.AlignLeft
                        }

                        Item { Layout.fillWidth: true }

                        ArcControl {
                            id: _ArcControl
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            Layout.alignment: Qt.AlignVCenter

                            ratio: delegate_item.dismissProgress
                            stroke: 2
                            colors.arc: Constants.notification_color_ticker_foreground
                            colors.track: Constants.notification_color_ticker_background

                            visible: opacity > 0
                            opacity: (delegate_item.containsMouse) ? 0 : 1

                            Behavior on opacity { NumberAnimation { duration: container._animationDuration / 2 } }
                        }

                        ClickableWithIcon {
                            size: 16
                            iconname: "dismiss.svg"
                            styles.icon_color_idle: Constants.notification_color_subtext
                            styles.icon_color_active: Constants.notification_color_dismiss

                            visible: _ArcControl.opacity === 0
                            opacity: (_ArcControl.opacity === 0) ? 1 : 0

                            onClicked: {
                                dismiss_timeout.stop();
                                delegate_item.modelData.dismiss();
                            }

                            Behavior on opacity { NumberAnimation { duration: container._animationDuration / 2 } }
                        }
                    }

                    StyledText {
                        id: _SummaryText
                        Layout.fillWidth: true

                        readonly property string summary: delegate_item.modelData.summary.trim() ?? ""
                        visible: summary.length > 0 && !delegate_item.appNameIsSummary
                        text: summary
                        color: Constants.notification_color_subtext
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignLeft
                    }

                    StyledText {
                        id: _BodyText
                        Layout.fillWidth: true
                        textFormat: Text.StyledText
                        text: (delegate_item.modelData.body || "").replace(/\r?\n/g, "<br>")
                        color: Constants.notification_color_text
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignLeft
                    }

                    RowLayout {
                        id: _ActionsRow
                        Layout.fillWidth: true
                        Layout.topMargin: Constants.spacing / 2

                        visible: delegate_item.modelData.actions.length > 0
                        spacing: Constants.spacing

                        Repeater {
                            model: [ ...delegate_item.modelData.actions].filter((a => (a.identifier || a.id) !== "default")) ?? []

                            delegate: Clickable {
                                id: _ActionButton
                                required property var modelData

                                implicitHeight: _ActionText.implicitHeight + Constants.padding

                                StyledText {
                                    id: _ActionText
                                    anchors.centerIn: parent
                                    text: _ActionButton.modelData.text
                                    styles.color_idle: Constants.notification_color_subtext
                                    styles.color_active: Constants.notification_color_text
                                    font.pixelSize: Constants.font_size
                                    active: _ActionButton.containsMouse
                                }

                                onClicked: {
                                    dismiss_timeout.stop();
                                    _ActionButton.modelData.invoke();
                                    delegate_item.modelData.dismiss();
                                }
                            }
                        }
                    }
                }
            }

            transform: Translate { id: _DelegateOffset; x: Constants.notification_width / 4 }

            state: "hidden"

            states: [
                State {
                    name: "visible"
                    PropertyChanges { delegate_item.opacity: 1 }
                    PropertyChanges { _DelegateOffset.x: 0 }
                },
                State {
                    name: "hidden"
                    PropertyChanges { delegate_item.opacity: 0 }
                    PropertyChanges { _DelegateOffset.x: Constants.notification_width / 4 }
                }
            ]

            transitions: [
                Transition {
                    from: "*"
                    to: "visible"
                    ParallelAnimation {
                        NumberAnimation {
                            target: delegate_item
                            property: "opacity"
                            duration: container._animationDuration
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: _DelegateOffset
                            property: "x"
                            duration: container._animationDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                },
                Transition {
                    id: _ExitTransition
                    from: "visible"
                    to: "hidden"
                    ParallelAnimation {
                        NumberAnimation {
                            target: delegate_item
                            property: "opacity"
                            duration: container._animationDuration
                            easing.type: Easing.InCubic
                        }
                        NumberAnimation {
                            target: _DelegateOffset
                            property: "x"
                            duration: container._animationDuration
                            easing.type: Easing.InCubic
                        }
                    }
                    onRunningChanged: {
                        if (!running && delegate_item.state === "hidden") {
                            delegate_item.modelData?.expire?.();
                        }
                    }
                }
            ]

            Component.onCompleted: {
                Debug.log(container.screen.name, "[Notification]", delegate_item.modelData.appName, "| ID:", delegate_item.modelData.id);
                state = "visible"
            }
        }
    }
}