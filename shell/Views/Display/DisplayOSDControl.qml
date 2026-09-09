pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs
import qs.Utilities
import "../../Components"

Rectangle {
    id: control

    property var payload: null

    // Store the processed screen change events
    property var screenEvents: []

    readonly property int _animationDuration: Constants.animation_duration

    // Adjust height dynamically based on the number of display items
    implicitHeight: mainLayout.implicitHeight + (Constants.padding * 2)
    implicitWidth: mainLayout.implicitWidth + (Constants.padding * 2)

    onPayloadChanged: {
        var events = [];

        const knownScreens = control.payload.previous;
        const currentScreens = control.payload.current

        Debug.json(knownScreens.map(s => `${s.description}: ${s.enabled}`));
        Debug.json(currentScreens.map(s => `${s.description}: ${s.enabled}`));

        // Map previous screens by unique description (or fallback to name)
        const knownMap = new Map(knownScreens.map(s => [s.description || s.name, s]));
        const currentKeys = new Set(currentScreens.map(s => s.description || s.name));

        const connected = [];
        const disconnected = [];

        for (const current of currentScreens) {
            const key = current.description || current.name;
            const previous = knownMap.get(key);

            if (current.enabled) {
                // Connected: went from false -> true, OR newly added as enabled
                if (!previous || !previous.enabled) {
                    connected.push(current);
                }
            } else {
                // Disconnected: went from true -> false, OR newly added as disabled
                if (!previous || previous.enabled) {
                    disconnected.push(current);
                }
            }
        }

        // Edge case: screen was previously enabled but is now completely missing
        for (const prev of knownScreens) {
            const key = prev.description || prev.name;
            if (prev.enabled && !currentKeys.has(key)) {
                disconnected.push(prev);
            }
        }

        if (connected && connected.length > 0) {
            for (var i = 0; i < connected.length; i++) {
                events.push({ screen: connected[i], type: "connected" });
            }
        }

        if (disconnected && disconnected.length > 0) {
            for (var j = 0; j < disconnected.length; j++) {
                events.push({ screen: disconnected[j], type: "disconnected" });
            }
        }

        control.screenEvents = events;
    }

    ColumnLayout {
        id: mainLayout
        anchors.centerIn: parent

        Repeater {
            model: control.screenEvents

            delegate: RowLayout {
                id: item
                required property var modelData

                Layout.fillWidth: true
                spacing: Constants.spacing

                // Static icon using ClickableWithIcon
                ClickableWithIcon {
                    size: Constants.size - Constants.padding * 2
                    iconname: item.modelData.type === "connected" ? "desktop-on.svg" : "desktop-off.svg"
                    styles.icon.color.idle: item.modelData.type === "connected" ? Constants.color_accent : Constants.color_muted
                }

                StyledText {
                    Layout.fillWidth: true
                    text: {
                        var scr = item.modelData.screen;
                        if (!scr) return "Unknown Display";
                        if (typeof scr === "string") return scr;

                        var makeModel = [scr.make, scr.model].filter(Boolean).join(" ");
                        return makeModel.length > 0 ? makeModel : (scr.name || "Display");
                    }
                    colors.idle: Constants.color_text
                    horizontalAlignment: Text.AlignLeft
                }
            }
        }
    }
}