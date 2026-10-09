import QtQuick

import qs
import qs.Services
import qs.Components

import qs.Utilities

ClickableWithIcon {
    readonly property bool muted: PipewireService.defaultMicrophone?.audio?.muted ?? false

    size: Constants.icon_size
    padding: Constants.padding
    radius: Constants.radius

    iconname: (muted) ? "mic-off.svg" : "mic-on.svg"

    styles.background_color_idle: Constants.control_color_background_default

    styles.border_width: 1
    styles.border_color_idle: Constants.control_color_border_default
    styles.border_color_active: Qt.alpha(Constants.volume_control_color_ink_default, 0.20)

    styles.icon_color_idle: (muted) ? Constants.volume_control_color_ink_muted : Constants.volume_control_color_ink_default
    styles.icon_color_active: Constants.volume_control_color_ink_active

    onClicked: if (PipewireService.defaultMicrophone.audio) {
        PipewireService.defaultMicrophone.audio.muted = !muted;
    }
}