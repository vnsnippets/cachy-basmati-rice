import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell.Widgets

import qs.Assets
import qs.Components

ColumnLayout {
    id: root
    width: parent ? parent.width : implicitWidth
    spacing: Style.spacing * 4

    // Expects a list of objects: { label: string, content: Component }
    property var tabs: []
    property int activeTab: 0
    readonly property int duration: 300

    // Tab Selector
    RowLayout {
        Layout.leftMargin: Style.padding
        Layout.rightMargin: Style.padding
        Layout.fillWidth: true
        spacing: Style.spacing * 4
        
        Repeater {
            model: root.tabs
            delegate: WrapperMouseArea {
                id: tabButton
                Layout.fillWidth: false
                height: tabLabel.implicitHeight
                width: tabLabel.implicitWidth
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                StyledText {
                    id: tabLabel
                    anchors.centerIn: parent
                    text: modelData.label
                    color: root.activeTab === index ? 
                           Style.colors.text : Qt.alpha(Style.colors.text, 0.5)
                    font.bold: tabButton.containsMouse || root.activeTab === index
                }
                
                onClicked: {
                    if (root.activeTab !== index) {
                        let oldIndex = root.activeTab;
                        root.activeTab = index;
                        
                        // Determine slide direction
                        if (index > oldIndex) {
                            stack.replace(modelData.content, StackView.PushTransition);
                        } else {
                            stack.replace(modelData.content, StackView.PopTransition);
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
        // clip: true
        
        // Match height of the current item in the stack
        implicitWidth: currentItem ? currentItem.implicitWidth : 0
        implicitHeight: currentItem ? currentItem.implicitHeight : 0
        
        Behavior on implicitHeight {
            NumberAnimation { duration: root.duration; easing.type: Easing.OutQuad }
        }

        initialItem: tabs[0].content
    }
}