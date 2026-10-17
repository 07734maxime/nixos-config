pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// The Militech "Apogee" Sandevistan: for a few seconds the world slows down.
// niri's animations run several times slower (a KDL include it hot reloads,
// see home/niri/default.nix) while overlays/SandevistanFx.qml tints the
// screens. Then the implant needs to cool down.
Singleton {
  id: sandy

  readonly property string path: Theme.stateDir + "/sandevistan.kdl"
  readonly property int duration: 8000
  readonly property int cooldown: 20000
  // how much slower niri animates while it runs
  readonly property real dilation: 4

  property bool active: false
  property bool cooling: false
  property real startedAt: 0
  property real cooledAt: 0
  // 1 when it engages, 0 when it runs out
  property real charge: 0
  // 0 when the cooldown starts, 1 once it can run again
  property real heat: 1

  signal engaged()

  function activate() {
    if (active || cooling) {
      Sounds.play("lock-denied")
      return
    }
    active = true
    startedAt = Date.now()
    write(true)
    Sounds.play("deck-switch")
    engaged()
    run.restart()
  }

  function stop() {
    if (!active) return
    active = false
    write(false)
    Sounds.play("menu-close")
    cooling = true
    cooledAt = Date.now()
    rest.restart()
  }

  function write(on) {
    store.setText(on
      ? "// SANDEVISTAN // ENGAGED, written by the shell\nanimations {\n    slowdown " + dilation.toFixed(1) + "\n}\n"
      : "// SANDEVISTAN // OFFLINE, written by the shell\n")
  }

  Timer {
    id: run
    interval: sandy.duration
    onTriggered: sandy.stop()
  }

  Timer {
    id: rest
    interval: sandy.cooldown
    onTriggered: sandy.cooling = false
  }

  // the gauges of the HUD
  Timer {
    interval: 50
    repeat: true
    running: sandy.active || sandy.cooling
    onTriggered: {
      const now = Date.now()
      sandy.charge = sandy.active ? Math.max(0, 1 - (now - sandy.startedAt) / sandy.duration) : 0
      sandy.heat = sandy.cooling ? Math.min(1, (now - sandy.cooledAt) / sandy.cooldown) : 1
    }
  }

  FileView {
    id: store
    path: sandy.path
  }

  // a shell that died mid-effect must not leave niri in slow motion
  Component.onCompleted: write(false)
}
