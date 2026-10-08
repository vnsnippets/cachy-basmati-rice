pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs
import qs.Services
import qs.Components

ColumnLayout {
    id: container
    spacing: Constants.spacing * 1.5
    
    property string title: ""
    property Component toolbar: null
    property var tabs: []

    property int currentIndex: 0
    property int _pendingIndex: -1

    implicitHeight: tab_bar_flickable.implicitHeight + swipe_view.implicitHeight + spacing
    
    RowLayout {
        StyledText {
            visible: container.title.trim().length > 0
            text: container.title
            color: Constants.color_text
            font.pixelSize: Constants.font_size_lg
        }

        Item { Layout.fillWidth: true }

        Loader {
            active: container.toolbar !== null
            visible: active
            sourceComponent: container.toolbar
        }
    }

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
                    required property string name

                    readonly property bool is_selected: container.currentIndex === index

                    implicitWidth: tab_text.implicitWidth
                    implicitHeight: tab_text.implicitHeight

                    StyledText {
                        id: tab_text
                        anchors.centerIn: parent
                        text: tab_item.name.toUpperCase() ?? ""
                        styles.color_idle: Constants.tab_color_ink_inactive
                        styles.color_active: Constants.tab_color_ink_active
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
                id: tab_content
                
                required property int index
                required property var modelData

                // Load active and pending targets
                active: swipe_view.currentIndex === index || container._pendingIndex === index
                sourceComponent: modelData.delegate
                
                // Pass properties cleanly to the loaded component
                Binding {
                    target: tab_content.item
                    property: "context"
                    value: tab_content.modelData.context ?? null
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