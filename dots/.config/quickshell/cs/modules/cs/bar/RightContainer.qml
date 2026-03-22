pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Row {
    id: root
    spacing: 8

    // SysTray pill
    Rectangle {
        height: 32; width: Math.max(trayRow.implicitWidth + 20, 36)
        radius: 16
        color: Appearance.m3colors.m3surfaceContainerLow
        Row {
            id: trayRow; anchors.centerIn: parent; spacing: 6
            SysTray { height: 20; invertSide: false }
        }
    }

    // System pill: battery · wifi · notif dot
    Rectangle {
        height: 32; width: sysRow.implicitWidth + 20
        radius: 16
        color: Appearance.m3colors.m3surfaceContainerLow
        MouseArea {
            anchors.fill: parent
            onClicked: GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen
        }
        Row {
            id: sysRow; anchors.centerIn: parent; spacing: 8

            // End-4's BatteryIndicator (bolt+progress bar style)
            BatteryIndicator {
                anchors.verticalCenter: parent.verticalCenter
                visible: Battery.available
            }

            // Network icon
            MaterialSymbol {
                anchors.verticalCenter: parent.verticalCenter
                text: Network.materialSymbol
                iconSize: 15
                color: Appearance.m3colors.m3onSurface
            }

            // Notification dot
            Rectangle {
                width: 7; height: 7; radius: 4
                anchors.verticalCenter: parent.verticalCenter
                color: Notifications.unread > 0
                    ? Appearance.m3colors.m3error
                    : Appearance.m3colors.m3outline
                visible: Notifications.unread > 0
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
    }
}
