import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell.Widgets

import qs.Utilities
import qs.Components

ColumnLayout {
    id: root
    width: parent ? parent.width : implicitWidth
    spacing: Styles.spacing

    required property string title
    required property var tabs
    required property Component template
    property Component options: null

    property int currentindex: 0
    property int minheight: 0
    
    readonly property int duration: 300

    // Keep an explicit track of the active instance so we can manually kill it if StackView misses it
    property Item currentTabInstance: template.createObject(stack, tabs[0]?.content ?? null)

    RowLayout {
        StyledText {
            Layout.topMargin: Styles.padding
            text: title
            color: Styles.colors.text
            font.pixelSize: 16
        }

        Item { Layout.fillWidth: true }

        Loader {
            active: root.options !== null
            visible: active
            sourceComponent: root.options
        }
    }

    // Tab Selector
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: Styles.padding / 2
        spacing: Styles.spacing

        visible: root.tabs.length > 1
        
        Repeater {
            model: root.tabs
            delegate: WrapperMouseArea {
                id: tabindicator
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignTop
                height: tabLabel.implicitHeight
                width: tabLabel.implicitWidth
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                readonly property var tabdata: modelData
                
                StyledText {
                    id: tabLabel
                    text: tabdata.name
                    color: root.currentindex === index ? Styles.colors.text : Qt.alpha(Styles.colors.text, 0.5)
                    font.bold: tabindicator.containsMouse || root.currentindex === index
                }
                
                onClicked: {
                    if (root.currentindex !== index) {
                        let oldIndex = root.currentindex;
                        root.currentindex = index;

                        // 1. Capture the old reference to destroy after transition
                        let oldInstance = root.currentTabInstance;

                        // 2. Instantiate the new tab layout content
                        const nextTabContent = root.template.createObject(stack, tabdata.content);
                        root.currentTabInstance = nextTabContent;
                        
                        // 3. Execute the replace transition
                        if (index > oldIndex) {
                            stack.replace(nextTabContent, StackView.PushTransition);
                        } else {
                            stack.replace(nextTabContent, StackView.PopTransition);
                        }

                        // 4. Clean up the old instance to prevent "ghosting"
                        if (oldInstance) {
                            oldInstance.destroy();
                        }
                    }
                }
            }
        }
    }

    // Animated Content Container
    StackView {
        id: stack
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
        
        implicitWidth: currentItem ? currentItem.implicitWidth : 0
        implicitHeight: Math.max(root.minheight, currentItem ? currentItem.implicitHeight : 0)
        
        Behavior on implicitHeight {
            NumberAnimation { 
                duration: root.duration
                easing.type: Easing.OutQuad 
            }
        }
        
        initialItem: root.currentTabInstance
    }
}