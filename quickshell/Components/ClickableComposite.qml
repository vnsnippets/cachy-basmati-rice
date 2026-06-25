import QtQuick
import QtQuick.Layouts

import qs.Types
import qs.Utilities
import qs.Components

Clickable {
    id: root

    signal toggleClicked

    property bool enabled: false
    readonly property bool active: enabled || containsMouse

    property StateStyle containerstyle: StateStyle {}
    property StateStyle togglestyle: StateStyle {}
    property StateStyle textstyle: StateStyle {}
    property StateStyle iconstyle: StateStyle {}

    property int iconradius: radius / 1.5

    required property string iconname
    required property string title
    property string caption: ""

    property real faderatio: 0.8

    styles.background.idle: (enabled) ? containerstyle.active : containerstyle.idle
    styles.background.active: containerstyle.active

    RowLayout {
        id: row
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Styles.spacing

        ClickableWithIcon {
            Layout.margins: Styles.padding
            Layout.rightMargin: 0

            backgroundstyle.idle: (root.active) ? root.togglestyle.active : root.togglestyle.idle
            backgroundstyle.active: root.togglestyle.active

            iconstyle.idle: (root.active) ? root.iconstyle.active : root.iconstyle.idle
            iconstyle.active: root.iconstyle.active

            enablebackground: true
            iconname: root.iconname
            size: 32
            padding: 10

            radius: root.iconradius

            onClicked: root.toggleClicked()
        }

        ColumnLayout {
            id: details
            Layout.fillWidth: true
            Layout.margins: Styles.padding
            Layout.leftMargin: 0

            StyledText {
                style.idle: (root.active) ? root.textstyle.active : root.textstyle.idle
                style.active: root.textstyle.active
                text: root.title
            }
        }
    }
}