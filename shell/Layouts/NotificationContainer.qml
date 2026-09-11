pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import qs
import qs.Services
import qs.Utilities
import "../Components"

PanelWindow {
    id: _Container

    anchors.bottom: true
    anchors.top: true
    anchors.right: true

    focusable: false
    color: "transparent"

    visible: NotificationService.notifications.values.length > 0

    mask: Region { item: _NotificationList }

    readonly property int _padding: Constants.padding * 2
    readonly property int _animationDuration: Constants.animation_duration

    implicitWidth: Constants.osd_width + (_padding * 2)

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: Constants.namespace
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    ListView {
        id: _NotificationList
        model: NotificationService.notifications

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: _Container._padding

        width: Constants.osd_width
        implicitWidth: Constants.osd_width
        implicitHeight: contentHeight
        
        spacing: Constants.padding
        interactive: false
        verticalLayoutDirection: ListView.BottomToTop

        HoverHandler { id: _ListViewHoverHandler }
        property alias hovered: _ListViewHoverHandler.hovered

        delegate: Clickable {
            id: _DelegateItem

            readonly property date createdAt: new Date()
            required property var modelData
            required property int index

            property real dismissProgress: 1.0
            NumberAnimation on dismissProgress {
                from: 1.0
                to: 0.0
                duration: _DismissTimer.interval
                running: _DismissTimer.running
            }

            readonly property bool appNameIsSummary: modelData?.appName.toLowerCase().trim() === modelData?.summary.toLowerCase().trim()

            width: Constants.osd_width
            implicitWidth: Constants.osd_width
            implicitHeight: _CardBackground.implicitHeight

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
                running: !_NotificationList.hovered
                repeat: false
                onRunningChanged: {
                    if (!_NotificationList.hovered && _DelegateItem.state !== "hidden") {
                        _DismissTimer.interval = Constants.notification_timeout / 2 * (_DelegateItem.index + 1)
                        _DelegateItem.dismissProgress = 1.0;
                    }
                }
                onTriggered: _DelegateItem.state = "hidden"
            }

            Rectangle {
                id: _CardBackground

                readonly property int item_padding: Constants.padding * 3

                width: Constants.osd_width
                implicitHeight: _ContentColumn.implicitHeight + item_padding

                color: Constants.color_base
                radius: Constants.radius
                border.width: 1
                border.color: _DelegateItem.containsMouse ? Qt.alpha(Constants.color_muted, 0.5) : Qt.alpha(Constants.color_muted, 0.25)

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
                            readonly property string appName: (_DelegateItem.appNameIsSummary) ? _DelegateItem.modelData?.summary : _DelegateItem.modelData?.appName
                            visible: appName !== "notify-send" && appName.length > 0
                            text: appName
                            color: Constants.color_muted
                            font.pixelSize: Constants.font_size
                            horizontalAlignment: Text.AlignLeft
                        }

                        Item { Layout.fillWidth: true }

                        RowLayout {
                            spacing: Constants.spacing

                            ArcControl {
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                Layout.alignment: Qt.AlignVCenter

                                ratio: _DelegateItem.dismissProgress
                                stroke: 2
                                arcColor: Constants.color_muted
                                trackColor: Constants.color_overlay
                            }

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
                    }

                    StyledText {
                        id: _SummaryText
                        Layout.fillWidth: true

                        readonly property string summary: _DelegateItem.modelData.summary.trim() ?? ""
                        visible: summary.length > 0 && !_DelegateItem.appNameIsSummary
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
                        maximumLineCount: 2
                        elide: Text.ElideRight
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

            transform: Translate { id: _DelegateOffset; x: Constants.osd_offset }

            state: "hidden"

            states: [
                State {
                    name: "visible"
                    PropertyChanges { _DelegateItem.opacity: 1 }
                    PropertyChanges { _DelegateOffset.x: 0 }
                },
                State {
                    name: "hidden"
                    PropertyChanges { _DelegateItem.opacity: 0 }
                    PropertyChanges { _DelegateOffset.x: Constants.osd_offset }
                }
            ]

            transitions: [
                Transition {
                    from: "*"
                    to: "visible"
                    ParallelAnimation {
                        NumberAnimation {
                            target: _DelegateItem
                            property: "opacity"
                            duration: _Container._animationDuration
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: _DelegateOffset
                            property: "x"
                            duration: _Container._animationDuration
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
                            target: _DelegateItem
                            property: "opacity"
                            duration: _Container._animationDuration
                            easing.type: Easing.InCubic
                        }
                        NumberAnimation {
                            target: _DelegateOffset
                            property: "x"
                            duration: _Container._animationDuration
                            easing.type: Easing.InCubic
                        }
                    }
                    onRunningChanged: {
                        if (!running && _DelegateItem.state === "hidden") {
                            _DelegateItem.modelData.expire();
                        }
                    }
                }
            ]

            Component.onCompleted: {
                Debug.log(_DelegateItem.modelData.id, "Rendered")
                state = "visible"
            }
        }
    }
}