import QtQuick
import QtQuick.Layouts

import qs
import qs.Components
import "../Views/System"

StyledBox {
    id: root
    readonly property int _gap: Constants.spacing / 1.5

    radius: Constants.radius * 2
    
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    ColumnLayout {
        id: content
        anchors.fill: parent
        spacing: root._gap * 2
        visible: root.opacity > 0.1
        
        // // Use margins within Layout instead of bottomMargin anchor
        // Layout.bottomMargin: root._padding
        
        // --- Header Row ---
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Constants.padding * 2
            Layout.alignment: Qt.AlignVCenter
            spacing: root._gap

            ClockControl {}
            Item { Layout.fillWidth: true; }
            BatteryControl {}
        }
    }
}