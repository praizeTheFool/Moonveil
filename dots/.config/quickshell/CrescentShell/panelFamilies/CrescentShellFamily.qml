import QtQuick
import Quickshell

import qs.modules.common
import qs.modules.cs.bar
import qs.modules.cs.background
import qs.modules.cs.cheatsheet
import qs.modules.cs.dock
import qs.modules.cs.lock
import qs.modules.cs.mediaControls
import qs.modules.cs.notificationPopup
import qs.modules.cs.onScreenDisplay
import qs.modules.cs.onScreenKeyboard
import qs.modules.cs.overview
import qs.modules.cs.polkit
import qs.modules.cs.regionSelector
import qs.modules.cs.screenCorners
import qs.modules.cs.sessionScreen
import qs.modules.cs.sidebarLeft
import qs.modules.cs.sidebarRight
import qs.modules.cs.overlay
import qs.modules.cs.verticalBar
import qs.modules.cs.wallpaperSelector

Scope {
    PanelLoader { extraCondition: !Config.options.bar.vertical; component: Bar {} }
    PanelLoader { component: Background {} }
    PanelLoader { component: Cheatsheet {} }
    PanelLoader { extraCondition: Config.options.dock.enable; component: Dock {} }
    PanelLoader { component: Lock {} }
    PanelLoader { component: MediaControls {} }
    PanelLoader { component: NotificationPopup {} }
    PanelLoader { component: OnScreenDisplay {} }
    PanelLoader { component: OnScreenKeyboard {} }
    PanelLoader { component: Overlay {} }
    PanelLoader { component: Overview {} }
    PanelLoader { component: Polkit {} }
    PanelLoader { component: RegionSelector {} }
    PanelLoader { component: ScreenCorners {} }
    PanelLoader { component: SessionScreen {} }
    PanelLoader { component: SidebarLeft {} }
    PanelLoader { component: SidebarRight {} }
    PanelLoader { extraCondition: Config.options.bar.vertical; component: VerticalBar {} }
    PanelLoader { component: WallpaperSelector {} }
}
