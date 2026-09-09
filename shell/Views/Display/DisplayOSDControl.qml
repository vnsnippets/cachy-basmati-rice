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
        if (!payload) return;

        const known = payload.previous || [];
        const current = payload.current || [];
        const getKey = s => s.description || s.name;

        const knownMap = new Map(known.map(s => [getKey(s), s]));
        const currentKeys = new Set(current.map(getKey));
        const events = [];

        // Process current screens directly into the event array
        for (const scr of current) {
            const prev = knownMap.get(getKey(scr));

            if (scr.enabled && (!prev || !prev.enabled)) {
                events.push({ screen: scr, connected: true });
            } else if (!scr.enabled && (!prev || prev.enabled)) {
                events.push({ screen: scr, connected: false });
            }
        }

        // Missing screens that were previously enabled
        for (const prev of known) {
            if (prev.enabled && !currentKeys.has(getKey(prev))) {
                events.push({ screen: prev, connected: false });
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
                    iconname: item.modelData.connected ? "desktop-on.svg" : "desktop-off.svg"
                    styles.icon.color.idle: item.modelData.connected ? Constants.color_accent : Constants.color_muted
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