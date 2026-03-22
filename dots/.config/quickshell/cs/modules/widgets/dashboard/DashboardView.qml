import QtQuick
import qs.modules.services
import qs

Item {
    implicitWidth:  900
    implicitHeight: 560

    readonly property int leftPanelWidth: 270

    Dashboard {
        id: dashboardItem
        anchors.fill: parent
        leftPanelWidth: parent.leftPanelWidth

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                GlobalStates.dashboardOpen = false
                try { Visibilities.setActiveModule("") } catch(e) {}
                event.accepted = true
            }
        }

        Component.onCompleted: Qt.callLater(() => forceActiveFocus())
    }
}
