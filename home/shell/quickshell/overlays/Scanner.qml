import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.services
import qs.components

// The Kiroshi scanner (Mod+Tab): the optics dim, every window on screen gets
// its target frame, and the one under the cursor (or clicked) is read like an
// NPC of the game: process, load, memory, threat level, then the quickhacks
// that work on it. PING focuses it, SHORT CIRCUIT closes it, SYNAPSE BURNOUT
// kills its process (click twice).
Overlay {
  id: window

  screen: Hud.screenNamed(Hud.scanOutput)
  open: Hud.scanOpen
  dim: 0.35
  // window positions are in output coordinates: cover the bar too
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.namespace: "cyberdeck-scanner"
  onDismissed: Hud.scanOpen = false

  readonly property color tone: Theme.warn
  property var targets: []
  property var hovered: null
  property var locked: null
  readonly property var target: locked || hovered
  property var info: ({})
  property bool armed: false

  // the windows drawn on this output right now, in its coordinates
  function scan() {
    const output = window.screen ? window.screen.name : ""
    const ws = Niri.workspaces.find(w => w.output === output && w.is_active)
    if (!ws) {
      targets = []
      return
    }
    const list = []
    for (const id in Niri.windows) {
      const w = Niri.windows[id]
      if (w.workspace_id !== ws.id || !w.layout) continue
      const pos = w.layout.tile_pos_in_workspace_view
      const size = w.layout.tile_size
      // a fullscreen window has no tile position: it is the whole output
      if (pos) list.push({ w: w, x: pos[0], y: pos[1], width: size[0], height: size[1], full: false })
      else if (ws.active_window_id === w.id) list.push({ w: w, x: 0, y: 0, width: 0, height: 0, full: true })
    }
    const sw = window.screen ? window.screen.width : window.width
    const sh = window.screen ? window.screen.height : window.height
    targets = list.filter(t => t.full || (t.x + t.width > 0 && t.x < sw && t.y + t.height > 0 && t.y < sh))
  }

  function read(t) {
    info = {}
    armed = false
    if (!t || !t.w.pid) return
    probe.command = ["sh", "-c", "ps -o pid=,comm=,%cpu=,rss=,nlwp=,etimes=,user= -p \"$1\"; pgrep -c -P \"$1\" || true", "sh", String(t.w.pid)]
    probe.running = true
  }

  function threat(i) {
    const cpu = parseFloat(i.cpu || "0")
    const ram = parseInt(i.rss || "0") / 1024
    if (cpu > 60 || ram > 3000) return { label: "EXTREME", tone: Theme.danger, level: 4 }
    if (cpu > 25 || ram > 1500) return { label: "HIGH", tone: Theme.alt, level: 3 }
    if (cpu > 5 || ram > 500) return { label: "MODERATE", tone: Theme.warn, level: 2 }
    return { label: "LOW", tone: Theme.ok, level: 1 }
  }

  function age(seconds) {
    const s = parseInt(seconds || "0")
    const d = Math.floor(s / 86400), h = Math.floor(s % 86400 / 3600), m = Math.floor(s % 3600 / 60)
    return (d > 0 ? d + "D " : "") + String(h).padStart(2, "0") + "H " + String(m).padStart(2, "0") + "M"
  }

  function hack(kind) {
    const t = target
    if (!t) return
    if (kind === "ping") {
      Niri.action(["focus-window", "--id", String(t.w.id)])
      Sounds.play("click")
      Hud.scanOpen = false
    } else if (kind === "short") {
      Niri.action(["close-window", "--id", String(t.w.id)])
      Sounds.play("breach-success")
      locked = null
      rescan.restart()
    } else if (kind === "burnout") {
      if (!armed) {
        armed = true
        Sounds.play("lock-denied")
        return
      }
      Quickshell.execDetached(["kill", "-KILL", String(t.w.pid)])
      Sounds.play("breach-success")
      locked = null
      armed = false
      rescan.restart()
    }
  }

  onOpenChanged: {
    if (!open) return
    hovered = null
    locked = null
    info = {}
    scan()
    Sounds.play("breach-open")
  }

  onTargetChanged: read(target)

  Timer {
    id: rescan
    interval: 400
    onTriggered: window.scan()
  }

  Process {
    id: probe
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = this.text.trim().split("\n")
        const f = (lines[0] || "").trim().split(/\s+/)
        window.info = f.length >= 7 ? { pid: f[0], comm: f[1], cpu: f[2], rss: f[3], threads: f[4], etimes: f[5], user: f[6], children: lines[1] || "0" } : {}
      }
    }
  }

  // ------------------------------------------------ the optics

  // the scan grid over the whole output
  Item {
    anchors.fill: parent
    opacity: window.reveal

    Repeater {
      model: Math.max(0, Math.ceil(window.width / 64))
      delegate: Rectangle {
        required property int index
        x: index * 64
        width: 1
        height: window.height
        color: Theme.alpha(window.tone, 0.05)
      }
    }

    Repeater {
      model: Math.max(0, Math.ceil(window.height / 64))
      delegate: Rectangle {
        required property int index
        y: index * 64
        width: window.width
        height: 1
        color: Theme.alpha(window.tone, 0.05)
      }
    }

    // the sweep of the optics when they switch on
    Rectangle {
      width: parent.width
      height: 3
      y: parent.height * window.reveal
      color: window.tone
      opacity: window.reveal < 1 ? 0.9 : 0
    }

    Row {
      x: 28
      y: 22
      spacing: 12

      Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 10; height: 10; rotation: 45; color: window.tone }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "KIROSHI OPTICS // SCANNING"
        color: window.tone
        font.family: Theme.fontUi
        font.pixelSize: 22
        font.weight: Font.Bold
        font.letterSpacing: 3
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: window.targets.length + " TARGET" + (window.targets.length === 1 ? "" : "S") + " // " + (window.screen ? window.screen.name : "")
        color: Theme.alpha(window.tone, 0.75)
        font.family: Theme.fontMono
        font.pixelSize: 11
        font.weight: Font.Bold
        font.letterSpacing: 1
      }
    }
  }

  // a target frame per window
  Repeater {
    model: window.targets
    delegate: Item {
      id: frame
      required property var modelData
      required property int index
      readonly property bool hot: window.target !== null && window.target.w.id === modelData.w.id
      x: modelData.x + 6
      y: modelData.y + 6
      // a fullscreen window takes the whole output, whatever its size
      width: (modelData.full ? window.width : modelData.width) - 12
      height: (modelData.full ? window.height : modelData.height) - 12
      opacity: window.reveal

      Rectangle {
        anchors.fill: parent
        color: Theme.alpha(window.tone, frame.hot ? 0.1 : 0.02)
        border.color: Theme.alpha(window.tone, frame.hot ? 0.9 : 0.3)
        border.width: 1
      }

      Brackets {
        anchors.fill: parent
        len: frame.hot ? 34 : 22
        thickness: frame.hot ? 3 : 2
        tone: window.tone
        Behavior on len { NumberAnimation { duration: 120 } }
      }

      // the name tag, top left of the frame
      Rectangle {
        x: 0
        y: 0
        width: tag.implicitWidth + 20
        height: 24
        color: frame.hot ? window.tone : Theme.alpha(Theme.bg, 0.85)
        border.color: window.tone
        border.width: 1

        Text {
          id: tag
          anchors.centerIn: parent
          text: (frame.modelData.w.app_id || "UNKNOWN").toUpperCase() + "  //  PID " + (frame.modelData.w.pid || "?")
          color: frame.hot ? Theme.bg : window.tone
          font.family: Theme.fontUi
          font.pixelSize: 13
          font.weight: Font.Bold
          font.letterSpacing: 1
        }
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.CrossCursor
        onEntered: {
          window.hovered = frame.modelData
          Sounds.play("matrix-hover")
        }
        onExited: if (window.hovered && window.hovered.w.id === frame.modelData.w.id) window.hovered = null
        onClicked: {
          window.locked = window.locked && window.locked.w.id === frame.modelData.w.id ? null : frame.modelData
          Sounds.play("click")
        }
      }
    }
  }

  // ------------------------------------------------ the readout

  Item {
    id: card
    readonly property var th: window.threat(window.info)
    // on the side of the screen away from the target
    readonly property bool onLeft: window.target !== null && !window.target.full && window.target.x + window.target.width / 2 > window.width / 2
    visible: window.target !== null
    x: onLeft ? 40 : window.width - width - 40
    anchors.verticalCenter: parent.verticalCenter
    width: 420
    height: cardColumn.height + 40
    opacity: window.reveal

    Plate {
      anchors.fill: parent
      cut: 18
      cutBL: 8
      fill: Theme.alpha(Theme.bg, 0.94)
      stroke: window.tone
      strokeW: 1.5
    }

    Rectangle { x: 0; y: 18; width: 3; height: parent.height - 36; color: card.th.tone }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.AllButtons
    }

    Column {
      id: cardColumn
      x: 22
      y: 20
      width: parent.width - 44
      spacing: 8

      Text {
        text: window.locked ? "TARGET LOCKED" : "SCAN IN PROGRESS"
        color: Theme.alpha(window.tone, 0.8)
        font.family: Theme.fontMono
        font.pixelSize: 10
        font.weight: Font.Bold
        font.letterSpacing: 2
      }

      DecodeText {
        width: parent.width
        source: window.target ? (window.target.w.app_id || "UNKNOWN").toUpperCase() : ""
        color: Theme.fg
        elide: Text.ElideRight
        font.family: Theme.fontUi
        font.pixelSize: 32
        font.weight: Font.Bold
        font.letterSpacing: 2
      }

      Text {
        width: parent.width
        text: window.target ? (window.target.w.title || "") : ""
        color: Theme.subtle
        elide: Text.ElideRight
        font.family: Theme.fontUi
        font.pixelSize: 14
        font.weight: Font.Medium
      }

      Row {
        spacing: 8
        Chip { label: "THREAT: " + card.th.label; tone: card.th.tone; solid: card.th.level >= 3; size: 11 }
        Chip { label: window.target && window.target.w.is_floating ? "FLOATING" : "TILED"; tone: Theme.primary; size: 11 }
      }

      Rectangle { width: parent.width; height: 1; color: Theme.alpha(window.tone, 0.35) }

      Repeater {
        model: [
          { k: "PROCESS", v: window.info.comm ? window.info.comm.toUpperCase() + "  //  PID " + window.info.pid : "READING..." },
          { k: "SYNAPSE LOAD", v: window.info.cpu !== undefined ? window.info.cpu + "%" : "--" },
          { k: "MEMORY", v: window.info.rss ? (parseInt(window.info.rss) / 1024).toFixed(0) + " MB" : "--" },
          { k: "THREADS", v: window.info.threads ? window.info.threads + "  //  " + window.info.children + " CHILD PROCESS" + (window.info.children === "1" ? "" : "ES") : "--" },
          { k: "ONLINE SINCE", v: window.info.etimes ? window.age(window.info.etimes) : "--" },
          { k: "AFFILIATION", v: window.info.user ? window.info.user.toUpperCase() : "--" }
        ]
        delegate: Item {
          required property var modelData
          width: cardColumn.width
          height: 20

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: modelData.k
            color: Theme.subtle
            font.family: Theme.fontMono
            font.pixelSize: 10
            font.letterSpacing: 1
          }

          Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: modelData.v
            color: Theme.fg
            font.family: Theme.fontUi
            font.pixelSize: 15
            font.weight: Font.Bold
          }
        }
      }

      Rectangle { width: parent.width; height: 1; color: Theme.alpha(window.tone, 0.35) }

      Text {
        text: "QUICKHACKS"
        color: window.tone
        font.family: Theme.fontUi
        font.pixelSize: 14
        font.weight: Font.Bold
        font.letterSpacing: 2
      }

      Repeater {
        model: [
          { kind: "ping", name: "PING", cost: 1, desc: "focus the window", tone: Theme.primary },
          { kind: "short", name: "SHORT CIRCUIT", cost: 4, desc: "close it, the polite way", tone: Theme.warn },
          { kind: "burnout", name: window.armed ? "CONFIRM: SYNAPSE BURNOUT" : "SYNAPSE BURNOUT", cost: 8, desc: "kill its process (SIGKILL)", tone: Theme.danger }
        ]
        delegate: Item {
          id: hack
          required property var modelData
          width: cardColumn.width
          height: 40

          Plate {
            anchors.fill: parent
            cut: 9
            fill: Theme.alpha(hack.modelData.tone, hackArea.containsMouse ? 0.24 : 0.07)
            stroke: Theme.alpha(hack.modelData.tone, hackArea.containsMouse ? 1 : 0.45)
          }

          Column {
            x: 14
            anchors.verticalCenter: parent.verticalCenter

            Text {
              text: hack.modelData.name
              color: hack.modelData.tone
              font.family: Theme.fontUi
              font.pixelSize: 16
              font.weight: Font.Bold
              font.letterSpacing: 1
            }

            Text {
              text: hack.modelData.desc.toUpperCase()
              color: Theme.subtle
              font.family: Theme.fontMono
              font.pixelSize: 9
            }
          }

          Text {
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: hack.modelData.cost + " RAM"
            color: Theme.alpha(hack.modelData.tone, 0.8)
            font.family: Theme.fontMono
            font.pixelSize: 11
            font.weight: Font.Bold
          }

          Clickable {
            id: hackArea
            anchors.fill: parent
            clickSound: ""
            onClicked: window.hack(hack.modelData.kind)
          }
        }
      }
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 26
    opacity: window.reveal
    text: window.targets.length === 0 ? "NO TARGET IN SIGHT // ESC TO CLOSE" : "HOVER TO SCAN // CLICK TO LOCK // ESC OR CLICK OUTSIDE TO CLOSE"
    color: Theme.alpha(window.tone, 0.8)
    font.family: Theme.fontMono
    font.pixelSize: 11
    font.weight: Font.Bold
    font.letterSpacing: 2
  }
}
