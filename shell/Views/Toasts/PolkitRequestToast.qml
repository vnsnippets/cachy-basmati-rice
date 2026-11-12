pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell.Services.Polkit

import qs
import qs.Components

StyledBox {
    id: control
    signal dismiss

    required property PolkitAgent agent

    // qmllint disable
    readonly property AuthFlow flow: agent?.flow ?? null
    // qmllint enable

    visible: agent && agent.isActive
    enabled: agent && agent.isActive

    implicitHeight: content.implicitHeight + Constants.padding * 2
    implicitWidth: Math.max(content.implicitWidth + Constants.padding * 2, 350)

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Constants.padding
        spacing: Constants.padding

        RowLayout {
            Layout.fillWidth: true
            spacing: Constants.padding

            IconControl {
                source: "Key.svg"
                size: Constants.icon_size
                tint: Constants.default_color_accent
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Qt.AlignLeft
                text: (control.flow?.failed) ? "Authentication Failed" : "Authentication Required"
                color: (control.flow?.failed) ? Constants.color_red : Constants.color_text
                wrapMode: Text.WordWrap
                font.pixelSize: Constants.font_size ?? 14
            }

            // RowLayout {
            //     spacing: 2

            //     ClickableIcon {
            //         enabled: control.agent && control.agent.isActive && control.flow != null
            //         size: Constants.icon_size
            //         iconname: "Check.svg"
            //         radius: Constants.radius / 2
            //         padding: Constants.padding / 1.5

            //         styles.icon_color_idle: Constants.color_subtext
            //         styles.icon_color_active: Constants.default_color_accent
            //         styles.background_color_idle: Qt.alpha(Constants.color_surface, 0)
            //         styles.background_color_active: Qt.alpha(Constants.color_surface, 1)

            //         onClicked: {
            //             if (control.flow) {
            //                 control.flow.submit(_PolkitTextField.text);
            //                 _PolkitTextField.text = "";
            //             }
            //         }
            //     }

            //     ClickableIcon {
            //         enabled: control.agent && control.agent.isActive && control.flow != null
            //         size: Constants.icon_size
            //         iconname: "Dismiss.svg"
            //         radius: Constants.radius / 2
            //         padding: Constants.padding / 1.5

            //         styles.icon_color_idle: Constants.color_subtext
            //         styles.icon_color_active: Constants.default_color_accent
            //         styles.background_color_idle: Qt.alpha(Constants.color_surface, 0)
            //         styles.background_color_active: Qt.alpha(Constants.color_surface, 1)

            //         onClicked: {
            //             _PolkitTextField.text = "";
            //             control.dismiss();
            //         }
            //     }
            // }
        }

        StyledText {
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignLeft
            text: control.flow?.message ?? ""
            color: Constants.color_text
            wrapMode: Text.WordWrap
            font.pixelSize: Constants.font_size ?? 14
        }

        TextField {
            id: _PolkitTextField

            Layout.fillWidth: true
            implicitHeight: Constants.size - (Constants.padding)
            padding: Constants.padding/2
            echoMode: TextInput.Password
            placeholderText: "Enter password..."
            placeholderTextColor: Constants.polkit_color_ink_muted
            font.family: Constants.font_family
            color: Constants.polkit_color_ink_default

            background: Rectangle {
                color: Constants.polkit_color_background
                radius: Constants.radius / 2
                border.color: (control.flow?.failed) ? Constants.color_red : _PolkitTextField.activeFocus ? Constants.polkit_color_ink_muted : Constants.polkit_color_border
                border.width: 1
            }

            onAccepted: if (control.flow) {
                control.flow.submit(_PolkitTextField.text);
                _PolkitTextField.text = "";
            }

            Keys.onEscapePressed: {
                _PolkitTextField.text = "";
                control.dismiss()
            }
        }
    }

    Component.onCompleted: {
        _PolkitTextField.forceActiveFocus();
    }
}