import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import qs
import qs.Styles
import qs.Utilities

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: Scope {
            id: root
            required property var modelData

            // ── Reserved Space ───────────────────────────────────────────────
            // Registers a fixed window in wayland at the top of the screen.
            // Wayland uses rest of screen for tiling.
            PanelWindow {
                id: barSpace
                screen: modelData

                anchors { top: true; left: true; right: true }
                implicitHeight: Style.dock.height + Style.dock.margin

                color: "transparent"
            }

            PanelWindow {
                id: canvas
                screen: modelData

                property Item activeWidget: null
                readonly property bool expanded: activeWidget !== null

                // Full screen — anchored to all four edges
                anchors { top: true; left: true; right: true; bottom: true }

                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "qs-basmati-canvas"

                color: "transparent"
                surfaceFormat.opaque: false
                focusable: false

                // ── Input mask ────────────────────────────────────────────────
                // Collapsed: input is restricted to just the bar strip so that
                //            mouse events elsewhere pass through to windows below.
                // Expanded:  mask is null so the whole canvas can catch clicks
                //            (used for the click-outside-to-close MouseArea).
                mask: Region {
                    Region { item: dockMask }
                    Region { item: (canvas.expanded) ? popupContainer : null }
                }

                Item {
                    id: dockMask
                    anchors {
                        top:   parent.top
                        left:  parent.left
                        right: parent.right
                    }
                    implicitHeight: Style.dock.height                    
                }

                // ── Status bar  ───────────────────────────────────────────────
                Dock {
                    id: dock
                    anchors {
                        top:   parent.top
                        left:  parent.left
                        right: parent.right
                    }
                    implicitHeight: Style.dock.height

                    z: 10
                }

                // ── Popup Logic  ───────────────────────────────────────────────
                // Connections {
                //     target: Hyprland
                //     enabled: canvas.activeWidget !== null

                //     function onRawEvent(event) {
                //         if (event.name === "activewindowv2") {
                //             canvas.handleWidgetPopup(canvas.activeWidget);
                //         }
                //     }
                // }

                Loader {
                    id: popupContainer
                    active: canvas.activeWidget !== null
                    anchors.top: parent.top
                    anchors.topMargin: Style.dock.height + Style.dock.margin * 2

                    property bool enableGlide: false

                    // AUTOMATIC CENTERING WITH CLAMPING
                    x: if (canvas.activeWidget) {
                        var widgetX = canvas.activeWidget.mapToItem(null, 0, 0).x + Style.dock.margin;
                        var centerX = widgetX + (canvas.activeWidget.width / 2) - (implicitWidth / 2);
                        
                        // --- CLAMP LOGIC ---
                        var margin = Style.dock.margin;
                        var minX = margin;
                        var maxX = canvas.width - implicitWidth - margin;
                        
                        return Math.max(minX, Math.min(centerX, maxX));
                    } else {
                        return 0;
                    }

                    // THE GLIDE: Any change to 'x' will now slide over 300ms
                    // Only animate x if we're switching between widgets
                    Behavior on x {
                        enabled: popupContainer.enableGlide
                        SpringAnimation { spring: 5.0; damping: 0.375; epsilon: 0.25; }
                    }

                    sourceComponent: canvas.activeWidget?.popup
                }

                readonly property var popupDestroyStopwatch: Stopwatch.create(popupContainer, false, false);
                function handleWidgetPopup(source) {
                    if (!source || !source.popup) return;

                    if (activeWidget === source) {
                        // Toggle the active state
                        // If it was animating out (false), this brings it back in (true)
                        popupContainer.item.active = !popupContainer.item.active;
                        
                        if (popupContainer.item.active) {
                            // If we brought it back, we don't want it to disappear anymore
                            popupDestroyStopwatch.stop()
                        } else {
                            // If we are starting the close, set the timer
                            popupDestroyStopwatch.begin(Style.popup.animations.duration, () => {
                                // CRITICAL: Only nullify if the widget is STILL inactive 
                                // after the timer finishes (prevents accidental closing)
                                if (popupContainer.item && !popupContainer.item.active) {
                                    canvas.activeWidget = null;
                                }
                            });
                        }
                    }

                    popupContainer.enableGlide = (activeWidget !== null); 
                    activeWidget = source;
                    return;
                }
            }
        }
    }
}
