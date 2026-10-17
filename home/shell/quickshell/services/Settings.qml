pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// What the SHELL SETTINGS menu changes, kept in the state folder so it survives
// rebuilds. Every value has a default: no file is a factory-fresh deck.
Singleton {
  id: settings

  readonly property string path: Theme.stateDir + "/settings.json"

  // the clone nixos-rebuild runs from; empty keeps `dotfiles` of flake.nix
  property string repo: ""
  property int barHeight: 40
  // "top" or "bottom"
  property string barPosition: "top"
  // frost behind the floating panels: niri blurs the wallpaper under them
  property bool blur: true
  property bool shadows: true
  // backing drawn under the panels, the frost shows through what is left
  property real panelOpacity: 0.6
  // darkens the desktop behind the control center and the menus
  property real dim: 0.25
  // empty: located from the IP by wttr.in
  property string weatherLocation: ""
  property bool clockSeconds: false
  property bool clock24: true
  // eddies and BREACH buttons on the right of the bar
  property bool barBreach: true
  // speed factor of every panel animation, 0 snaps them open
  property real motion: 1
  // scan lines, tick marks and micro captions over the panels
  property bool hudDecor: true
  // "right" or "left"
  property string ccSide: "right"
  property bool ccMedia: true
  property bool ccAudio: true
  property bool ccWeather: true
  property bool ccDeck: true
  property bool ccMessages: true
  // seconds a notification stays up, critical ones wait to be dismissed
  property int notifTimeout: 7
  // "C" or "F"
  property string tempUnit: "C"
  // the Blackwall whispering in the bar now and then
  property bool whispers: true
  // the power-on sequence on the first login after a boot
  property bool bootSequence: true
  // contacts of the holocall simulator calling on their own
  property bool randomCalls: true
  // "rare", "sometimes" or "often"
  property string callFrequency: "rare"
  // the braindance screensaver, after this many idle minutes (the lock comes at 5)
  property bool screensaver: true
  property int screensaverDelay: 2

  readonly property var defaults: ({
    repo: "", barHeight: 40, barPosition: "top", blur: true, shadows: true, panelOpacity: 0.6, dim: 0.25,
    weatherLocation: "", clockSeconds: false, clock24: true, barBreach: true, motion: 1, hudDecor: true,
    ccSide: "right", ccMedia: true, ccAudio: true, ccWeather: true, ccDeck: true, ccMessages: true,
    notifTimeout: 7, tempUnit: "C", whispers: true, bootSequence: true, randomCalls: true, callFrequency: "rare",
    screensaver: true, screensaverDelay: 2
  })
  readonly property int minBar: 32
  readonly property int maxBar: 56

  readonly property string defaultRepo: Theme.config.repo || ""
  readonly property string rebuildRepo: repo !== "" ? repo : defaultRepo
  readonly property bool barBottom: barPosition === "bottom"
  readonly property bool ccLeft: ccSide === "left"
  readonly property string clockFormat: (clock24 ? "HH:mm" : "hh:mm") + (clockSeconds ? ":ss" : "")
  // the frost only shows through translucent panels; without it they go
  // near opaque again so windows never bleed through the text
  readonly property color backing: Theme.alpha(Theme.bg, blur ? panelOpacity : Math.max(panelOpacity, 0.92))
  // the sections drawn on top of the backing
  readonly property real plateAlpha: blur ? 0.4 : 0.9
  readonly property color plate: Theme.alpha(Theme.bg, plateAlpha)

  // a duration scaled by the motion setting
  function ms(base) {
    return Math.round(base * motion)
  }

  function set(key, value) {
    if (settings[key] === value) return
    settings[key] = value
    save()
  }

  function reset() {
    for (const key in defaults) settings[key] = defaults[key]
    save()
  }

  function save() {
    const out = {}
    for (const key in defaults) out[key] = settings[key]
    store.setText(JSON.stringify(out, null, 1) + "\n")
  }

  function load(text) {
    let data = {}
    try {
      data = JSON.parse(text)
    } catch (error) {
      console.warn("cyberdeck: unreadable settings " + settings.path + ": " + error)
      return
    }
    for (const key in defaults) {
      if (data[key] === undefined || typeof data[key] !== typeof defaults[key]) continue
      settings[key] = data[key]
    }
    barHeight = Math.max(minBar, Math.min(maxBar, Math.round(barHeight)))
    if (barPosition !== "top" && barPosition !== "bottom") barPosition = "top"
    if (ccSide !== "right" && ccSide !== "left") ccSide = "right"
    if (tempUnit !== "C" && tempUnit !== "F") tempUnit = "C"
    if (["rare", "sometimes", "often"].indexOf(callFrequency) < 0) callFrequency = "rare"
    panelOpacity = Math.max(0.4, Math.min(1, panelOpacity))
    dim = Math.max(0, Math.min(0.7, dim))
    motion = Math.max(0, Math.min(2, motion))
    notifTimeout = Math.max(3, Math.min(20, Math.round(notifTimeout)))
    screensaverDelay = Math.max(1, Math.min(4, Math.round(screensaverDelay)))
  }

  FileView {
    id: store
    path: settings.path
    blockLoading: true
    watchChanges: true
    onFileChanged: reload()
    onLoaded: settings.load(text())
  }
}
