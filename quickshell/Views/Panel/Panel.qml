pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import qs.Types
import qs.Styles
import qs.Utilities

Loader {
    id: root
    y: Style.dock.height

    active: content !== null
    property Component content: null

    readonly property var stopwatch: Stopwatch.create(root, false, false);
    function showAsync(component) {
        // --- Cold Start ---
        if (content === null || item === null) {
            content = component;
            return;
        }

        // --- Same component clicked ---
        if (content && content.url === component.url) {
            item.active = !item.active;
            if (item.active) stopwatch.stop()
            else {
                stopwatch.begin(300, () => {
                     if (item && !item.active) content = null
                })
            }
            return;
        }

        // --- Parallel Swap Logic ---
        if (item.active) {
            item.active = false;
            stopwatch.begin(300, () => {
                content = component
            })
        }
    }

    sourceComponent: content
}