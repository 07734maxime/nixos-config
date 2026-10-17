import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.components

// The braindance screensaver: after a few idle minutes (SHELL SETTINGS) the
// wallpaper plays as a recorded braindance, slowly panned, with the editor's
// HUD, its layers, a clock and lines of Night City lore. Any input ends it.
// Idle inhibitors (a playing video) and ADRENALINE keep it away; the lock
// screen goes over it. `quickshell -c cyberdeck ipc call screensaver preview`.
Scope {
  id: saver

  // a preview started by hand, ended by the next pointer move
  property bool forced: false
  readonly property bool shown: (forced || idle.isIdle) && !Lock.locked && !Sandevistan.active
  property real startedAt: 0

  readonly property var lines: [
    "NIGHT CITY. FOUNDED 1994 BY RICHARD NIGHT. HE DID NOT LIVE TO SEE IT GROW.",
    "IN NIGHT CITY YOU CAN BE ANYONE. MOST END UP NO ONE.",
    "THE AFTERLIFE SERVES DRINKS NAMED AFTER DEAD LEGENDS.",
    "ARASAKA TOWER WAS REBUILT AFTER 2023. THE SCARS STAYED.",
    "BEYOND THE BLACKWALL, SOMETHING IS LISTENING.",
    "A BRAINDANCE RECORDS EVERYTHING. EVEN WHAT YOU WANTED TO FORGET.",
    "THE BADLANDS DO NOT CARE ABOUT YOUR CHROME.",
    "PACIFICA WAS SUPPOSED TO BE PARADISE. THE MONEY RAN OUT FIRST.",
    "NETWATCH CANNOT SEE EVERYTHING. IT JUST WANTS YOU TO THINK SO.",
    "EVERY MERC DREAMS OF A DRINK AT THE AFTERLIFE. FEW GET ONE.",
    "TRAUMA TEAM PLATINUM: SIX MINUTES, OR YOUR MONEY BACK.",
    "THE CITY NEVER SLEEPS. NEITHER DOES YOUR DECK.",
    "WAKE UP, SAMURAI. WE HAVE A CITY TO BURN."
  ]

  function preview() {
    forced = true
    startedAt = Date.now()
  }

  onShownChanged: if (shown) startedAt = Date.now()

  IdleMonitor {
    id: idle
    enabled: Settings.screensaver && !Hud.caffeine
    timeout: Settings.screensaverDelay * 60
    respectInhibitors: true
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: window

      required property var modelData
      property real level: saver.shown ? 1 : 0
      property int line: 0
      property int layer: 0
      property real elapsed: 0

      Behavior on level { NumberAnimation { duration: saver.shown ? 1600 : 250; easing.type: Easing.InOutCubic } }

      screen: modelData
      visible: level > 0
      color: "transparent"
      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "cyberdeck-screensaver"

      readonly property var layers: [
        { name: "VISUAL", tint: "transparent" },
        { name: "AUDIO", tint: Theme.alpha(Theme.tertiary, 0.18) },
        { name: "THERMAL", tint: Theme.alpha(Theme.alt, 0.28) }
      ]

      function timecode(ms) {
        const pad = v => String(v).padStart(2, "0")
        const s = Math.floor(ms / 1000)
        return pad(Math.floor(s / 3600)) + ":" + pad(Math.floor(s / 60) % 60) + ":" + pad(s % 60) + ":" + pad(Math.floor(ms / 40) % 25)
      }

      Timer {
        interval: 40
        repeat: true
        running: window.visible
        onTriggered: window.elapsed = Date.now() - saver.startedAt
      }

      Timer {
        interval: 9000
        repeat: true
        running: window.visible
        onTriggered: window.line = (window.line + 1) % saver.lines.length
      }

      Timer {
        interval: 14000
        repeat: true
        running: window.visible
        onTriggered: window.layer = (window.layer + 1) % window.layers.length
      }

      Rectangle {
        anchors.fill: parent
        color: Theme.bg
        opacity: window.level
      }

      // the recording: the wallpaper, slowly panned
      Item {
        anchors.fill: parent
        clip: true
        opacity: window.level

        Image {
          id: shot
          width: parent.width * 1.18
          height: parent.height * 1.18
          source: Theme.poster !== "" ? "file://" + Theme.poster : ""
          fillMode: Image.PreserveAspectCrop
          asynchronous: true
          sourceSize: Qt.size(2400, 1350)
          property real drift: 0
          x: -(width - parent.width) * drift
          y: -(height - parent.height) * (1 - drift) * 0.6

          SequentialAnimation on drift {
            running: window.visible
            loops: Animation.Infinite
            NumberAnimation { from: 0; to: 1; duration: 60000; easing.type: Easing.InOutSine }
            NumberAnimation { from: 1; to: 0; duration: 60000; easing.type: Easing.InOutSine }
          }
        }

        // the layer being edited
        Rectangle {
          anchors.fill: parent
          color: window.layers[window.layer].tint
          Behavior on color { ColorAnimation { duration: 1200 } }
        }

        Rectangle {
          anchors.fill: parent
          gradient: Gradient {
            GradientStop { position: 0; color: Theme.alpha(Theme.bg, 0.55) }
            GradientStop { position: 0.35; color: Theme.alpha(Theme.bg, 0.1) }
            GradientStop { position: 0.7; color: Theme.alpha(Theme.bg, 0.25) }
            GradientStop { position: 1; color: Theme.alpha(Theme.bg, 0.9) }
          }
        }

        Column {
          anchors.fill: parent
          spacing: 3
          Repeater {
            model: Math.max(0, Math.ceil(window.height / 4))
            delegate: Rectangle { width: window.width; height: 1; color: Qt.rgba(0, 0, 0, 0.22) }
          }
        }
      }

      // ------------------------------------------------ the editor's HUD

      Item {
        anchors.fill: parent
        anchors.margins: 40
        opacity: window.level

        Brackets {
          anchors.fill: parent
          len: 46
          thickness: 3
          tone: Theme.alpha(Theme.danger, 0.8)
        }

        Row {
          x: 24
          y: 20
          spacing: 12

          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 14
            height: 14
            radius: 7
            color: Theme.danger
            SequentialAnimation on opacity {
              running: window.visible
              loops: Animation.Infinite
              NumberAnimation { to: 0.15; duration: 600 }
              NumberAnimation { to: 1; duration: 600 }
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "BRAINDANCE // PLAYBACK"
            color: Theme.danger
            font.family: Theme.fontUi
            font.pixelSize: 24
            font.weight: Font.Bold
            font.letterSpacing: 4
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: window.timecode(window.elapsed)
            color: Theme.fg
            font.family: Theme.fontMono
            font.pixelSize: 16
            font.weight: Font.Bold
          }
        }

        Row {
          anchors.right: parent.right
          anchors.rightMargin: 24
          y: 22
          spacing: 6

          Repeater {
            model: window.layers
            delegate: Chip {
              required property var modelData
              required property int index
              label: modelData.name
              tone: index === 2 ? Theme.alt : (index === 1 ? Theme.tertiary : Theme.primary)
              solid: index === window.layer
              size: 12
            }
          }
        }

        MicroText {
          x: 24
          y: 56
          text: "SOURCE // " + Theme.wallpaper.split("/").pop().toUpperCase() + " // RECORDED BY " + (Quickshell.env("USER") || "V").toUpperCase() + " // " + (Theme.osInfo.name || "")
        }

        // the clock and the lore, bottom left like a BD caption
        Column {
          x: 24
          anchors.bottom: timeline.top
          anchors.bottomMargin: 30
          spacing: 6

          SystemClock {
            id: clock
            precision: SystemClock.Minutes
          }

          Text {
            text: Qt.formatDateTime(clock.date, Settings.clock24 ? "HH:mm" : "hh:mm")
            color: Theme.warn
            font.family: Theme.fontUi
            font.pixelSize: 150
            font.weight: Font.Bold
            style: Text.Outline
            styleColor: Theme.alpha(Theme.bg, 0.4)
          }

          Text {
            text: Qt.formatDateTime(clock.date, "dddd dd MMMM").toUpperCase() + "  //  NIGHT CITY"
            color: Theme.fg
            font.family: Theme.fontUi
            font.pixelSize: 26
            font.weight: Font.Bold
            font.letterSpacing: 3
          }

          Item { width: 1; height: 14 }

          DecodeText {
            width: window.width * 0.6
            source: saver.lines[window.line]
            color: Theme.primary
            wrapMode: Text.WordWrap
            duration: 900
            font.family: Theme.fontUi
            font.pixelSize: 22
            font.weight: Font.Bold
            font.letterSpacing: 2
          }
        }

        // the editing timeline, its playhead crawling
        Item {
          id: timeline
          x: 24
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 30
          width: parent.width - 48
          height: 34
          readonly property real head: (window.elapsed % 120000) / 120000

          Repeater {
            model: 61
            delegate: Rectangle {
              required property int index
              x: index * (timeline.width - 1) / 60
              y: index % 10 === 0 ? 0 : 8
              width: 1
              height: index % 10 === 0 ? 18 : 10
              color: Theme.alpha(Theme.fg, index / 60 <= timeline.head ? 0.7 : 0.25)
            }
          }

          Rectangle { y: 22; width: parent.width; height: 2; color: Theme.alpha(Theme.fg, 0.2) }
          Rectangle { y: 22; width: parent.width * timeline.head; height: 2; color: Theme.danger }

          Rectangle {
            x: parent.width * timeline.head - 1
            y: -6
            width: 2
            height: 34
            color: Theme.danger
          }

          MicroText {
            anchors.right: parent.right
            anchors.top: parent.bottom
            anchors.topMargin: 4
            text: "MOVE TO EXIT THE BRAINDANCE"
            color: Theme.alpha(Theme.fg, 0.6)
          }
        }
      }

      // any input wakes the deck; the click itself goes nowhere
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onPositionChanged: if (Date.now() - saver.startedAt > 1200) saver.forced = false
        onPressed: saver.forced = false
        onWheel: saver.forced = false
      }
    }
  }
}
