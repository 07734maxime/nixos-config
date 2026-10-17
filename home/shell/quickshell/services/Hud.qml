pragma Singleton

import QtQuick
import Quickshell

// Which overlays are open and on which output. Opening one closes the others.
Singleton {
  id: hud

  property bool ccOpen: false
  property bool osOpen: false
  property bool breachOpen: false
  property bool wallOpen: false
  property bool settingsOpen: false
  property bool pkgOpen: false
  property bool phoneOpen: false
  property bool scanOpen: false
  property string ccOutput: ""
  property string osOutput: ""
  property string breachOutput: ""
  property string wallOutput: ""
  property string settingsOutput: ""
  property string pkgOutput: ""
  property string phoneOutput: ""
  property string scanOutput: ""
  property bool dnd: false
  property bool caffeine: false
  property bool locked: false

  signal quickhackRequested()
  signal glitch()

  function here() {
    return Niri.focusedOutput || (Quickshell.screens.length > 0 ? Quickshell.screens[0].name : "")
  }

  function closeAll() {
    ccOpen = false
    osOpen = false
    breachOpen = false
    wallOpen = false
    settingsOpen = false
    pkgOpen = false
    phoneOpen = false
    scanOpen = false
  }

  function toggleCc(output) {
    const target = output || here()
    const reopen = !ccOpen || ccOutput !== target
    closeAll()
    if (reopen) {
      Niri.closeOverview()
      ccOutput = target
      ccOpen = true
    }
  }

  function toggleOs(output) {
    const target = output || here()
    const reopen = !osOpen || osOutput !== target
    closeAll()
    if (reopen) {
      Niri.closeOverview()
      osOutput = target
      osOpen = true
    }
  }

  function toggleWall(output) {
    const target = output || here()
    const reopen = !wallOpen || wallOutput !== target
    closeAll()
    if (reopen) {
      Niri.closeOverview()
      Theme.refreshWallpapers()
      wallOutput = target
      wallOpen = true
    }
  }

  function toggleSettings(output) {
    const target = output || here()
    const reopen = !settingsOpen || settingsOutput !== target
    closeAll()
    if (reopen) {
      Niri.closeOverview()
      settingsOutput = target
      settingsOpen = true
    }
  }

  function togglePkg(output) {
    const target = output || here()
    const reopen = !pkgOpen || pkgOutput !== target
    closeAll()
    if (reopen) {
      Niri.closeOverview()
      pkgOutput = target
      pkgOpen = true
    }
  }

  function togglePhone(output) {
    const target = output || here()
    const reopen = !phoneOpen || phoneOutput !== target
    closeAll()
    if (reopen) {
      Niri.closeOverview()
      phoneOutput = target
      phoneOpen = true
    }
  }

  function toggleScan(output) {
    const target = output || here()
    const reopen = !scanOpen || scanOutput !== target
    closeAll()
    if (reopen) {
      Niri.closeOverview()
      scanOutput = target
      scanOpen = true
    }
  }

  function openBreach(output) {
    closeAll()
    Niri.closeOverview()
    breachOutput = output || here()
    breachOpen = true
  }

  function screenNamed(name) {
    for (const screen of Quickshell.screens) if (screen.name === name) return screen
    return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
  }
}
