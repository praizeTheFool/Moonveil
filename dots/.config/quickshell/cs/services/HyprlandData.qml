pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

Singleton {
    id: root

    readonly property bool isHyprland: true

    signal stateChanged()
    readonly property var toplevels: isHyprland ? Hyprland.toplevels : []
    readonly property var workspaces: isHyprland ? Hyprland.workspaces : []
    readonly property var monitors: isHyprland ? Hyprland.monitors : []
    readonly property Toplevel activeToplevel: isHyprland ? ToplevelManager.activeToplevel : null
    readonly property HyprlandWorkspace focusedWorkspace: isHyprland ? Hyprland.focusedWorkspace : null
    readonly property HyprlandMonitor focusedMonitor: isHyprland ? Hyprland.focusedMonitor : null
    readonly property int focusedWorkspaceId: focusedWorkspace?.id ?? 1
    property real screenW: focusedMonitor ? focusedMonitor.width : 0
    property real screenH: focusedMonitor ? focusedMonitor.height : 0
    property real screenScale: focusedMonitor ? focusedMonitor.scale : 1

    property var windowList: []
    property var windowByAddress: ({})
    property var addresses: []
    property var layers: ({})
    property var monitorsInfo: []
    property var workspacesInfo: []
    property var workspaceById: ({})
    property var workspaceIds: []
    property var activeWorkspaceInfo: null
    property string keyboardLayout: "?"

    readonly property var workspaceWindowMap: {
        const map = {}
        const list = windowList
        for (let i = 0; i < list.length; ++i) {
            const wsId = list[i].workspace.id
            if (!map[wsId]) map[wsId] = 0
            map[wsId]++
        }
        return map
    }

    property var workspaceOccupationMap: ({})
    property var workspaceWindowsMap: ({})

    Timer {
        id: updateDebounce
        interval: 100
        onTriggered: root.updateAll()
    }

    function updateWindowList() { updateDebounce.restart() }

    function updateMaps() {
        let occupationMap = {}
        let windowsMap = {}
        for (var i = 0; i < root.windowList.length; ++i) {
            var win = root.windowList[i]
            let wsId = win.workspace.id
            occupationMap[wsId] = true
            if (!windowsMap[wsId]) windowsMap[wsId] = []
            windowsMap[wsId].push(win)
        }
        root.workspaceOccupationMap = occupationMap
        root.workspaceWindowsMap = windowsMap
    }

    function dispatch(request) {
        if (!isHyprland) return
        Hyprland.dispatch(request)
    }

    function changeWorkspace(targetWorkspaceId) {
        if (!isHyprland || !targetWorkspaceId) return
        root.dispatch("workspace " + targetWorkspaceId)
    }

    function focusedWindowForWorkspace(workspaceId) {
        if (!isHyprland) return null
        const wsWindows = root.windowList.filter(w => w.workspace.id === workspaceId)
        if (wsWindows.length === 0) return null
        return wsWindows.reduce((best, win) => {
            const bestFocus = best?.focusHistoryID ?? Infinity
            const winFocus = win?.focusHistoryID ?? Infinity
            return winFocus < bestFocus ? win : best
        }, null)
    }

    function isWorkspaceOccupied(id) {
        if (!isHyprland) return false
        return workspaceWindowMap[id] > 0
    }

    function updateAll() {
        if (!isHyprland) return
        getClients.running = true
        getLayers.running = true
        getMonitors.running = true
        getWorkspaces.running = true
        getActiveWorkspace.running = true
    }

    function biggestWindowForWorkspace(workspaceId) {
        if (!isHyprland) return null
        const windowsInThisWorkspace = root.windowList.filter(w => w.workspace.id === workspaceId)
        return windowsInThisWorkspace.reduce((maxWin, win) => {
            const maxArea = (maxWin?.size?.[0] ?? 0) * (maxWin?.size?.[1] ?? 0)
            const winArea = (win?.size?.[0] ?? 0) * (win?.size?.[1] ?? 0)
            return winArea > maxArea ? win : maxWin
        }, null)
    }

    function refreshKeyboardLayout() {
        if (!isHyprland) return
        hyprctlDevices.running = true
    }

    Component.onCompleted: {
        if (isHyprland) {
            updateAll()
            refreshKeyboardLayout()
        }
    }

    Process {
        id: hyprctlDevices
        running: false
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const devices = JSON.parse(this.text)
                    const keyboard = devices.keyboards.find(k => k.main) || devices.keyboards[0]
                    root.keyboardLayout = keyboard?.active_keymap?.toUpperCase()?.slice(0, 2) ?? "?"
                } catch (err) { root.keyboardLayout = "?" }
            }
        }
    }

    Process {
        id: getClients
        running: false
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.windowList = JSON.parse(this.text)
                    let tempWinByAddress = {}
                    for (let win of root.windowList)
                        tempWinByAddress[win.address] = win
                    root.windowByAddress = tempWinByAddress
                    root.addresses = root.windowList.map(w => w.address)
                    root.updateMaps()
                } catch (e) {}
            }
        }
    }

    Process {
        id: getMonitors
        running: false
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.monitorsInfo = JSON.parse(this.text) }
                catch (e) {}
            }
        }
    }

    Process {
        id: getLayers
        running: false
        command: ["hyprctl", "layers", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.layers = JSON.parse(this.text) }
                catch (e) {}
            }
        }
    }

    Process {
        id: getWorkspaces
        running: false
        command: ["hyprctl", "workspaces", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.workspacesInfo = JSON.parse(this.text)
                    let map = {}
                    for (let ws of root.workspacesInfo) map[ws.id] = ws
                    root.workspaceById = map
                    root.workspaceIds = root.workspacesInfo.map(ws => ws.id)
                } catch (e) {}
            }
        }
    }

    Process {
        id: getActiveWorkspace
        running: false
        command: ["hyprctl", "activeworkspace", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.activeWorkspaceInfo = JSON.parse(this.text) }
                catch (e) {}
            }
        }
    }

    Connections {
        target: isHyprland ? Hyprland : null
        function onRawEvent(event) {
            if (!isHyprland || event.name.endsWith("v2")) return
            if (event.name.includes("activelayout"))
                refreshKeyboardLayout()
            else if (event.name.includes("mon"))
                Hyprland.refreshMonitors()
            else if (event.name.includes("workspace") || event.name.includes("window"))
                Hyprland.refreshWorkspaces()
            else
                Hyprland.refreshToplevels()
            updateWindowList()
            root.stateChanged()
        }
    }
}
