pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs
import qs.Components

ColumnLayout {
    id: root
    spacing: Constants.padding

    property var tabs: []
    property int _current_index: 0
    property int _pending_index: -1

    function next() {
        const nextIndex = (_current_index + 1) % tabs.length;
        root._pending_index = nextIndex;
        tab_transition.start();
    }

    function previous() {
        const prevIndex = (_current_index - 1 + tabs.length) % tabs.length;

        root._pending_index = prevIndex;
        tab_transition.start();
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
                    required property bool active

                    enabled: active

                    readonly property bool is_selected: root._current_index === index

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
                        if (!enabled) return;

                        if (root._current_index !== index && !tab_transition.running) {
                            root._pending_index = index;
                            tab_transition.start();
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
                active: swipe_view.currentIndex === index || root._pending_index === index
                sourceComponent: template
                
                // Pass properties cleanly to the loaded component
                Binding {
                    target: tab_content.item
                    property: "context"
                    value: tab_content.context ?? null
                    when: tab_content.status === Loader.Ready && tab_content.item !== null && tab_content.context !== null
                }
            }
        }
    }

    // --- SEQUENCED TAB TRANSITION (Gives clean gap between tabs) ---
    SequentialAnimation {
        id: tab_transition
        readonly property int anim_duration: Constants.animation_duration / 4

        // Step 1: Fade and slightly slide OUT current tab
        ParallelAnimation {
            NumberAnimation {
                target: swipe_view
                property: "opacity"
                to: 0.0
                duration: tab_transition.anim_duration
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: swipe_view
                property: "scale"
                to: 0.98
                duration: tab_transition.anim_duration
                easing.type: Easing.InCubic
            }
        }

        // Step 2: Swap tab index instantly while hidden
        ScriptAction {
            script: {
                if (root._pending_index !== -1) {
                    root._current_index = root._pending_index;
                    swipe_view.currentIndex = root._pending_index;
                    root._pending_index = -1;
                }
            }
        }

        // Step 3: Fade and slide IN new tab
        ParallelAnimation {
            NumberAnimation {
                target: swipe_view
                property: "opacity"
                to: 1.0
                duration: tab_transition.anim_duration
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: swipe_view
                property: "scale"
                to: 1.0
                duration: tab_transition.anim_duration
                easing.type: Easing.OutCubic
            }
        }
    }
}