pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs
import qs.Services
import qs.Components

ColumnLayout {
    id: root
    spacing: Constants.padding
    
    property string title: ""
    property var tabs: []

    property int currentIndex: 0
    property int _pendingIndex: -1

    component Options: QtObject {
        property string icon: "settings.svg"
        property Component view: null
    }

    property Options options: Options {}

    implicitHeight: tab_bar_flickable.implicitHeight + swipe_view.implicitHeight + spacing
    
    RowLayout {
        Layout.topMargin: Constants.padding * 1.5

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            visible: root.title.trim().length > 0
            text: root.title.toUpperCase()
            color: Constants.tab_color_ink_muted
            font.weight: 600
        }

        Item { Layout.fillWidth: true }

        ClickableIcon {
            id: special_view_toggle
            Layout.alignment: Qt.AlignVCenter   
            visible: root.options.view !== null
            padding: 0
            size: Constants.icon_size
            iconname: root.options.icon

            styles.icon_color_idle: Constants.color_subtext
            styles.icon_color_active: Constants.color_text

            onClicked: {}
        }
    }

    // --- TAB BAR ---
    Flickable {
        id: tab_bar_flickable

        Layout.fillWidth: true
        Layout.topMargin: Constants.padding

        implicitHeight: tab_row.implicitHeight

        contentWidth: tab_row.implicitWidth
        contentHeight: tab_row.implicitHeight

        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalFlick
        clip: true

        Row {
            id: tab_row
            spacing: Constants.spacing

            Repeater {
                model: root.tabs

                delegate: Clickable {
                    id: tab_item
                    required property int index
                    required property string name

                    readonly property bool is_selected: root.currentIndex === index

                    implicitWidth: tab_text.implicitWidth
                    implicitHeight: tab_text.implicitHeight

                    StyledText {
                        id: tab_text
                        anchors.centerIn: parent
                        text: tab_item.name.toUpperCase() ?? ""
                        styles.color_idle: Constants.tab_color_ink_inactive
                        styles.color_active: Constants.tab_color_ink_active
                        active: tab_item.is_selected
                        font.weight: (active) ? 800 : 600
                    }

                    onClicked: {
                        if (root.currentIndex !== index && !tabTransitionAnim.running) {
                            root._pendingIndex = index;
                            tabTransitionAnim.start();
                        }
                    }
                }
            }
        }
    }

    // --- SWIPE VIEW ---
    SwipeView {
        id: swipe_view

        Layout.fillWidth: true
        clip: true

        interactive: false
        currentIndex: 0

        Behavior on implicitHeight {
            NumberAnimation {
                duration: Constants.animation_duration
                easing.type: Easing.OutCubic
            }
        }

        Repeater {
            model: root.tabs

            delegate: Loader {
                id: tab_content
                
                required property int index
                required property Component template
                required property var context

                // Load active and pending targets
                active: swipe_view.currentIndex === index || root._pendingIndex === index
                sourceComponent: template
                
                // Pass properties cleanly to the loaded component
                Binding {
                    target: tab_content.item
                    property: "context"
                    value: tab_content.context ?? null
                    when: tab_content.status === Loader.Ready && tab_content.item !== null
                }
            }
        }
    }

    // --- SEQUENCED TAB TRANSITION (Gives clean gap between tabs) ---
    SequentialAnimation {
        id: tabTransitionAnim

        // Step 1: Fade and slightly slide OUT current tab
        ParallelAnimation {
            NumberAnimation {
                target: swipe_view
                property: "opacity"
                to: 0.0
                duration: Constants.animation_duration / 2
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: swipe_view
                property: "scale"
                to: 0.98
                duration: Constants.animation_duration / 2
                easing.type: Easing.InCubic
            }
        }

        // Step 2: Swap tab index instantly while hidden
        ScriptAction {
            script: {
                if (root._pendingIndex !== -1) {
                    root.currentIndex = root._pendingIndex;
                    swipe_view.currentIndex = root._pendingIndex;
                    root._pendingIndex = -1;
                }
            }
        }

        // Step 3: Fade and slide IN new tab
        ParallelAnimation {
            NumberAnimation {
                target: swipe_view
                property: "opacity"
                to: 1.0
                duration: Constants.animation_duration
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: swipe_view
                property: "scale"
                to: 1.0
                duration: Constants.animation_duration
                easing.type: Easing.OutCubic
            }
        }
    }

    // --- DISMISSAL HANDLING ---
    Connections {
        target: EventOrchestrator
        function onConsoleDismissContentEvent() {
            dismissAnimation.start();
        }
    }

    SequentialAnimation {
        id: dismissAnimation
        NumberAnimation {
            target: swipe_view
            property: "opacity"
            to: 0.0
            duration: Constants.animation_duration
            easing.type: Easing.Linear
        }
        ScriptAction {
            script: EventOrchestrator.consoleCloseEvent()
        }
    }
}