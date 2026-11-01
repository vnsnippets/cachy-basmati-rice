pragma ComponentBehavior: Bound

import QtQuick

import qs
import qs.Components

ClickableWithIcon {
    component Styles: QtObject {
        property color accent: Constants.color_yellow
        property color muted: Constants.color_overlay
        property color ink: Constants.color_base
    }

    property Styles colors: Styles {}
    readonly property color _accent: (enabled) ? colors.accent : colors.muted

    padding: Constants.padding / 1.5
    leftPadding: Constants.padding
    rightPadding: Constants.padding

    styles.background_color_idle: Qt.alpha(_accent, 0.05)
    styles.background_color_active: Qt.alpha(_accent, 1)

    styles.icon_color_idle: _accent
    styles.icon_color_active: colors.ink

    styles.border_width: 1
    styles.border_color_idle: Qt.alpha(_accent, 0.5)
    styles.border_color_active: Qt.alpha(_accent, 1)

    styles.text_color_idle: _accent
    styles.text_color_active: colors.ink

    font.family: Constants.font_family
    radius: Constants.radius
}