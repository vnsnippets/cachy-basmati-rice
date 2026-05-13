import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

//Audio
import Quickshell.Services.Pipewire

import qs.Styles
import qs.Controls
import qs.Utilities
import qs.Views.Cockpit.Controls

Loader {
    id: root
    // Keep active true or use a Timer to delay deactivation if you want 
    // the component to fully unmount after the "out" animation.
    active: false 

    required property var screen

    readonly property int animationDuration: 300
    property bool expand: false

    onExpandChanged: {
        if (!expand) {
            Stopwatch.create(root, false, true).begin(root.animationDuration, () => {
                root.active = false
            })
        } else {
            root.active = true
        }
    }

    sourceComponent: PanelWindow {
        screen: root.screen

        anchors { top: true; left: true; right: true; bottom: true; }
        margins { top: Style.margin; left: Style.margin; right: Style.margin; bottom: Style.margin; }

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "qs-basmati-canvas"

        color: "transparent"
        surfaceFormat.opaque: false
        focusable: false

        mask: Region { item: container; }
        
        Rectangle {
            id: container
            anchors.centerIn: parent
            
            // Use State-driven dimensions instead of static assignments
            property real targetWidth: Style.panel.width
            property real targetHeight: masterLayout.implicitHeight + Style.panel.padding * 2

            // Track active tab
            property int activeTab: 0

            radius: Style.panel.radius
            color: Style.panel.colors.background
            border.color: Style.colors.subtext
            border.width: 1
            antialiasing: true
            clip: true
            
            // Initial state (collapsed)
            opacity: 0
            scale: 0.9
            width: targetWidth
            height: 0

            states: [
                State {
                    name: "expanded"
                    when: root.expand
                    PropertyChanges {
                        target: container
                        opacity: 1
                        scale: 1.0
                        width: container.targetWidth  // Animate width
                        height: container.targetHeight // Animate height
                    }
                },
                State {
                    name: "collapsed"
                    when: !root.expand
                    PropertyChanges {
                        target: container
                        opacity: 0
                        scale: 0.9
                        width: container.targetWidth // Maintain target width context
                        height: 0
                    }
                }
            ]

            // Transitions will automatically catch changes to width/height 
            transitions: [
                Transition {
                    from: "*"; to: "expanded"
                    NumberAnimation { 
                        properties: "opacity,scale,width,height"
                        duration: root.animationDuration
                        easing.type: Easing.OutCubic 
                    }
                },
                Transition {
                    from: "expanded"; to: "*"
                    NumberAnimation { 
                        properties: "opacity,scale,width,height"
                        duration: root.animationDuration
                        easing.type: Easing.InCubic 
                    }
                }
            ]

            ColumnLayout {
                id: masterLayout
                spacing: Style.panel.padding
                width: container.width - (Style.panel.padding * 2)
                anchors.centerIn: parent
                
                // To prevent layout flickering during size animation
                visible: container.opacity > 0.1

                Behavior on implicitHeight { NumberAnimation { duration: root.animationDuration; easing.type: Easing.InCubic } }


                RowLayout {
                    Layout.fillWidth: true

                    AudioSlider {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                    }

                    BrightnessSlider {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    NetworkOverview { 
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        // implicitWidth: Style.panel.widget.width
                        implicitHeight: this.childrenRect.height
                        onClicked: container.activeTab = 1
                    }
                    
                    BatteryOverview {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        // implicitWidth: Style.panel.widget.width
                        implicitHeight: this.childrenRect.height
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        // implicitWidth: Style.panel.widget.width
                        implicitHeight: this.childrenRect.height
                        color: "transparent"
                    }
                }

                Item {
                    id: contentWrapper
                    Layout.fillWidth: true
                    Layout.preferredHeight: content.height

                    clip: true

                    Loader {
                        id: content
                        anchors.centerIn: parent

                        readonly property int activeTab: container.activeTab
                        readonly property Component component: switch(container.activeTab) {
                            case 1:  return networks;
                            case 2:  return settingsComponent;
                            default: return launchpad;
                        }

                        property int animationDuration: root.animationDuration/2

                        sourceComponent: component;

                        width: implicitWidth
                        height: implicitHeight

                        Behavior on width { NumberAnimation { duration: content.animationDuration; easing.type: Easing.OutBack } }
                        Behavior on height { NumberAnimation { duration: content.animationDuration; easing.type: Easing.OutBack } }
                        Behavior on opacity { NumberAnimation { duration: content.animationDuration; easing.type: Easing.OutBack } }

                        NumberAnimation {
                            id: entry
                            target: content
                            property: "opacity"
                            from: 0; to: 1
                            duration: content.animationDuration
                        }

                        NumberAnimation {
                            id: dismiss
                            target: content
                            property: "opacity"
                            from: 1; to: 0;
                            duration: content.animationDuration
                            onFinished: {
                                content.sourceComponent = content.component;
                                entry.restart();
                            }
                        }

                        onActiveTabChanged: {
                            dismiss.restart()
                        }
                    }
                }

                // Bottom Row: Tab Bar
                RowLayout {
                    id: tabBar
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Style.spacing

                    Repeater {
                        model: [
                            { icon: "󰀂", label: "Launchpad" },
                            { icon: "󰀂", label: "Network" },
                            { icon: "󰒓", label: "Settings" },
                        ]

                        delegate: Clickable {
                            id: tabButton                        
                            property bool isActive: container.activeTab === index

                            // Highlight Active Tab
                            colors.background.idle: isActive ? Style.colors.subtext : "transparent"
                            colors.border.idle: isActive ? Style.colors.subtext : Style.colors.subtext
                            opacity: isActive ? 1.0 : 0.6

                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            StyledText {
                                id: tabLabel
                                anchors.centerIn: parent
                                text: modelData.label
                                leftPadding: Style.panel.padding
                                rightPadding: Style.panel.padding
                                style.idle: tabButton.isActive ? Style.colors.base : Style.colors.text
                            }

                            onClicked: container.activeTab = index
                        }
                    }
                }
            }

            // Tab Components
            Component { id: launchpad; Rectangle { implicitWidth: container.width; implicitHeight: 300; color: Qt.alpha("#000000", 0.24); StyledText { text: "Launchpad"; anchors.centerIn: parent } } }
            Component { id: settingsComponent; Rectangle { implicitWidth: container.width; implicitHeight: 400; color: "transparent"; StyledText { text: "System Settings"; anchors.centerIn: parent } } }
            Component { id: networks; Rectangle { implicitWidth: container.width; implicitHeight: 400; color: "transparent"; StyledText { text: "Networks"; anchors.centerIn: parent } } }
        }
    }
}