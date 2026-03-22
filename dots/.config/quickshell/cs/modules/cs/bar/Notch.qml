import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.services
import qs.modules.common
import qs.modules.functions

Rectangle {
    id: root

    property string mode: "idle"
    property int collapsedHeight: 40
    property int expandedHeight: 460

    signal closeRequested()

    property Toplevel activeToplevel: HyprlandData.isWorkspaceOccupied(HyprlandData.focusedWorkspaceId)
        ? HyprlandData.activeToplevel
        : null

    property string cleanTitle: {
        if (!activeToplevel)
            return "Desktop"
        var raw = activeToplevel?.title
        if (!raw || raw === "" || raw === "Workspace")
            return "Desktop"
        var parts = raw.split(" - ")
        if (parts.length > 1)
            return parts[0]
        return raw
    }

    width: {
        if (mode !== "idle")
            return 800
        var base = 160
        var textWidth = titleText.implicitWidth
        var calculated = base + textWidth
        return Math.min(Math.max(calculated, 240), screen.width * 0.7)
    }

    height: mode === "idle" ? collapsedHeight : expandedHeight
    radius: mode === "idle" ? 20 : 28
    color: "#000000"
    clip: true

    Behavior on width {
        NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
    }
    Behavior on height {
        NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
    }
    Behavior on radius {
        NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
    }

    Keys.onEscapePressed: { if (mode !== "idle") mode = "idle" }
    focus: true

    // IDLE CONTENT
    Item {
        anchors.fill: parent
        opacity: mode === "idle" ? 1 : 0
        visible: opacity > 0
        Behavior on opacity {
            NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
        }

        Row {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                id: timeText
                text: Qt.formatTime(new Date(), "hh:mm")
                color: Appearance.colors.colPrimary
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                height: parent.height
            }

            Item {
                width: parent.width - timeText.width - titleText.width - 32
                height: 1
            }

            Text {
                id: titleText
                text: root.cleanTitle
                color: Appearance.colors.colPrimary
                font.pixelSize: 14
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                height: parent.height
            }
        }

        Timer {
            interval: 60000
            running: true
            repeat: true
            onTriggered: timeText.text = Qt.formatTime(new Date(), "hh:mm")
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.mode = "dashboard"
        }
    }

    // EXPANDED CONTENT
    Item {
        anchors.fill: parent
        anchors.margins: 32
        opacity: mode === "dashboard" ? 1 : 0
        scale: mode === "dashboard" ? 1 : 0.94
        visible: opacity > 0
        transformOrigin: Item.Top
        Behavior on opacity {
            NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
        }
        Behavior on scale {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }

        Rectangle {
            anchors.fill: parent
            radius: 22
            color: "#151515"
            Text {
                anchors.centerIn: parent
                text: "Dashboard"
                color: "white"
                font.pixelSize: 22
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.mode = "idle"
        }
    }
}
