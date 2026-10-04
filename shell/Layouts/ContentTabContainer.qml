pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs
import qs.Types
import qs.Services
import qs.Components

ColumnLayout {
    id: container

    // 2. Strongly-typed list of Tab objects
    property list<TabItem> tabs: []

    property int currentIndex: 0
    property int _pendingIndex: -1

    spacing: Constants.padding
    implicitHeight: tab_bar_flickable.implicitHeight + swipe_view.implicitHeight + spacing

    // --- TAB BAR ---
    Flickable {
        id: tab_bar_flickable

        Layout.fillWidth: true
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
                model: container.tabs

                delegate: Clickable {
                    id: tab_item
                    required property int index
                    required property string label

                    readonly property bool is_selected: container.currentIndex === index

                    implicitWidth: tab_text.implicitWidth
                    implicitHeight: tab_text.implicitHeight

                    StyledText {
                        id: tab_text
                        anchors.centerIn: parent
                        text: tab_item.label.toUpperCase() ?? ""
                        styles.color_idle: Constants.console_tab_color_text_inactive
                        styles.color_active: Constants.console_tab_color_text_active
                        active: tab_item.is_selected
                        font.bold: true
                    }

                    onClicked: {
                        if (container.currentIndex !== index && !tabTransitionAnim.running) {
                            container._pendingIndex = index;
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
            model: container.tabs

            delegate: Loader {
                required property int index
                required property Component content

                // Load active and pending targets
                active: swipe_view.currentIndex === index || container._pendingIndex === index
                sourceComponent: content
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
            NumberAnimation {
                target: swipe_view
                property: "x"
                from: 0
                to: (container.currentIndex > container._pendingIndex) ? 50 : -50
                duration: Constants.animation_duration / 2
                easing.type: Easing.InCubic
            }
        }

        // Step 2: Swap tab index instantly while hidden
        ScriptAction {
            script: {
                if (container._pendingIndex !== -1) {
                    container.currentIndex = container._pendingIndex;
                    swipe_view.currentIndex = container._pendingIndex;
                    container._pendingIndex = -1;
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