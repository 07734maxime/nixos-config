import QtQuick
import QtQuick.Effects
import Quickshell
import qs.services
import qs.components

// The control center panel, built from the in-game menus: the character
// sheet on top, cyberware slots for the quick toggles, numbered folder tabs
// for the sections, attribute boxes for the deck status and the phone's
// message list. Sections can be hidden from SHELL SETTINGS.
Item {
  id: cc

  property real reveal: 1

  implicitWidth: 680
  implicitHeight: column.height

  // the deck levels up with the breaches won and the eddies stacked
  readonly property int level: Math.min(50, 1 + Math.floor(Stats.breaches / 3))
  readonly property real levelProgress: level >= 50 ? 1 : (Stats.breaches % 3) / 3
  readonly property real credRaw: Math.sqrt(Stats.eddies / 250)
  readonly property int cred: Math.min(50, 1 + Math.floor(credRaw))
  readonly property real credProgress: cred >= 50 ? 1 : credRaw - Math.floor(credRaw)

  // height of the drawer: the message list stretches down to its bottom
  property real available: 0

  // numbered in the order they are shown, like the tabs of the game menus
  readonly property var shown: [Settings.ccMedia, Settings.ccWeather, Settings.ccAudio, Settings.ccDeck, Settings.ccWeather, Settings.ccMessages]

  function codeAt(slot) {
    let n = 0
    for (let i = 0; i <= slot; i++) if (shown[i]) n++
    return String(n).padStart(2, "0")
  }

  // ------------------------------------------------------------ pieces

  // a folder tab with its number, the title next to it and the body plate
  // hanging under it, chamfered at the bottom right
  component Section: Item {
    id: section
    property string title: ""
    property string icon: ""
    property string index: ""
    property string code: ""
    property color tone: Theme.primary
    default property alias content: body.data
    property real order: 0
    // the section next to it in its row: both take the taller height
    property real pairHeight: 0
    readonly property real contentHeight: body.childrenRect.height + 52
    readonly property real local: Math.max(0, Math.min(1, cc.reveal * 1.6 - order * 0.12))
    width: cc.width
    height: Math.max(contentHeight, pairHeight)
    opacity: local
    transform: Translate { x: (1 - section.local) * (Settings.ccLeft ? -24 : 24) }

    Plate {
      y: 23
      width: parent.width
      height: parent.height - 23
      cut: 0
      cutBR: 14
      fill: Settings.plate
      stroke: Theme.frameDim
    }

    // the accent under the tab and its title
    Rectangle {
      y: 22
      width: tab.width + titleRow.width + 18
      height: 2
      color: section.tone
    }

    Plate {
      id: tab
      width: Math.max(30, codeText.implicitWidth + 16)
      height: 23
      cut: 7
      fill: section.tone
      strokeW: 0

      Text {
        id: codeText
        anchors.centerIn: parent
        text: section.code
        color: Theme.bg
        font.family: Theme.fontUi
        font.pixelSize: 15
        font.weight: Font.Bold
      }
    }

    Row {
      id: titleRow
      x: tab.width + 8
      height: 22
      spacing: 6

      Icon {
        anchors.verticalCenter: parent.verticalCenter
        visible: section.icon !== ""
        width: 14
        height: 14
        name: section.icon
        color: section.tone
        weight: 1.8
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: section.title
        color: section.tone
        font.family: Theme.fontUi
        font.pixelSize: 15
        font.weight: Font.Bold
        font.letterSpacing: 1.5
      }
    }

    Row {
      anchors.right: parent.right
      anchors.rightMargin: 2
      height: 22
      spacing: 8

      Hatch {
        anchors.verticalCenter: parent.verticalCenter
        visible: Settings.hudDecor
        width: 28
        height: 8
        tone: Theme.alpha(section.tone, 0.45)
        gap: 4
        thickness: 1.5
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: section.index
        color: Theme.alpha(section.tone, 0.75)
        font.family: Theme.fontMono
        font.pixelSize: 9
        font.weight: Font.Bold
      }
    }

    // reticle tick at the open corner
    Item {
      visible: Settings.hudDecor
      x: 3
      y: parent.height - 9
      width: 6
      height: 6
      Rectangle { width: 6; height: 1; y: 5; color: section.tone }
      Rectangle { width: 1; height: 6; color: section.tone }
    }

    Item {
      id: body
      x: 14
      y: 36
      width: parent.width - 28
    }
  }

  component Value: Text {
    color: Theme.fg
    font.family: Theme.fontUi
    font.pixelSize: 14
    font.weight: Font.Bold
  }

  component Caption: Text {
    color: Theme.subtle
    font.family: Theme.fontMono
    font.pixelSize: 9
    font.letterSpacing: 0.5
  }

  // LEVEL / STREET CRED row of the character sheet
  component Rank: Item {
    id: rank
    property string label: ""
    property int value: 0
    property real progress: 0
    property color tone: Theme.primary
    width: parent ? parent.width : 0
    height: 18

    Text {
      id: rankValue
      width: 26
      anchors.verticalCenter: parent.verticalCenter
      text: rank.value
      color: rank.tone
      font.family: Theme.fontUi
      font.pixelSize: 18
      font.weight: Font.Bold
    }

    Caption {
      x: 30
      width: 80
      anchors.verticalCenter: parent.verticalCenter
      text: rank.label
      color: Theme.fg
    }

    Slider {
      x: 112
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width - 112
      height: 5
      segments: 20
      value: rank.progress
      tone: rank.tone
      enabled: false
    }
  }

  // attribute box: a big number, its name and a thin gauge
  component Attribute: Item {
    id: attr
    property string label: ""
    property string value: ""
    property string unit: ""
    property real fill: 0
    property color tone: Theme.primary
    height: 66

    Plate {
      anchors.fill: parent
      cut: 0
      cutTL: 9
      fill: Theme.alpha(attr.tone, 0.06)
      stroke: Theme.alpha(attr.tone, 0.4)
    }

    Row {
      x: 10
      y: 6
      spacing: 2

      Text {
        id: attrValue
        text: attr.value
        color: attr.tone
        font.family: Theme.fontUi
        font.pixelSize: 26
        font.weight: Font.Bold
      }

      Text {
        anchors.baseline: attrValue.baseline
        text: attr.unit
        color: Theme.alpha(attr.tone, 0.7)
        font.family: Theme.fontUi
        font.pixelSize: 12
        font.weight: Font.Bold
      }
    }

    Caption {
      x: 10
      y: 40
      width: parent.width - 20
      elide: Text.ElideRight
      text: attr.label
      color: Theme.fg
    }

    Rectangle {
      x: 10
      y: parent.height - 9
      width: parent.width - 20
      height: 3
      color: Theme.alpha(attr.tone, 0.15)

      Rectangle {
        width: parent.width * Math.max(0, Math.min(1, attr.fill))
        height: parent.height
        color: attr.tone
        Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
      }
    }
  }

  Column {
    id: column
    width: cc.width
    spacing: 10

    // ---------------------------------------------- character sheet

    Item {
      width: cc.width
      height: 122
      opacity: Math.min(1, cc.reveal * 1.6)

      Plate {
        anchors.fill: parent
        cut: 18
        cutBL: 8
        fill: Settings.plate
        stroke: Theme.primary
        strokeW: 1.5
      }

      Rectangle { x: 0; y: 16; width: 3; height: parent.height - 32; color: Theme.primary }

      // portrait socket with the manufacturer of the running OS
      Item {
        id: portrait
        x: 16
        y: 16
        width: 84
        height: 84

        Rectangle {
          anchors.fill: parent
          color: Theme.primaryDeep
          border.color: Theme.frame
          border.width: 1
        }

        Hatch {
          anchors.fill: parent
          anchors.margins: 1
          visible: Settings.hudDecor
          tone: Theme.alpha(Theme.primary, 0.07)
          gap: 6
          thickness: 1
        }

        OsBadge {
          anchors.centerIn: parent
          width: Theme.osInfo.logo === "zetatech" ? 70 : 54
          height: 44
          color: Theme.primary
        }

        Brackets { anchors.fill: parent; anchors.margins: -4; len: 10; tone: Theme.primary }

        Rectangle {
          anchors.bottom: parent.bottom
          width: parent.width
          height: 14
          color: Theme.primary

          Text {
            anchors.centerIn: parent
            text: Theme.osInfo["class"] || "CYBERDECK"
            color: Theme.bg
            font.family: Theme.fontUi
            font.pixelSize: 10
            font.weight: Font.Bold
            font.letterSpacing: 1
          }
        }
      }

      Column {
        x: 116
        y: 12
        width: parent.width - 116 - 16
        spacing: 1

        MicroText {
          visible: Settings.hudDecor
          width: parent.width
          elide: Text.ElideRight
          text: "NC-DB // NETRUNNER PROFILE // KERNEL " + Sys.kernel
        }

        DecodeText {
          width: parent.width - 96
          source: (Quickshell.env("USER") || "V").toUpperCase()
          color: Theme.fg
          elide: Text.ElideRight
          font.family: Theme.fontUi
          font.pixelSize: 24
          font.weight: Font.Bold
          font.letterSpacing: 2
        }

        Text {
          width: parent.width - 96
          text: (Theme.osInfo.name || "") + "  //  UP " + Sys.uptime
          color: Theme.secondary
          elide: Text.ElideRight
          font.family: Theme.fontUi
          font.pixelSize: 12
          font.weight: Font.DemiBold
          font.letterSpacing: 0.5
        }

        Item { width: 1; height: 5 }

        Rank {
          label: "LEVEL"
          value: cc.level
          progress: cc.levelProgress
          tone: Theme.primary
        }

        Rank {
          label: "STREET CRED"
          value: cc.cred
          progress: cc.credProgress
          tone: Theme.warn
        }
      }

      Column {
        anchors.right: parent.right
        anchors.rightMargin: 22
        y: 14
        spacing: 6

        Chip {
          anchors.right: parent.right
          label: Theme.osInfo.tier || ""
          visible: label !== ""
          tone: Theme.osInfo.tier === "LEGENDARY" ? Theme.warn : Theme.tertiary
          size: 10
        }

        // opens SHELL SETTINGS
        Item {
          anchors.right: parent.right
          width: cfgRow.width + 14
          height: 20

          Plate {
            anchors.fill: parent
            cut: 6
            fill: cfgArea.containsMouse ? Theme.primary : Theme.alpha(Theme.primary, 0.08)
            stroke: Theme.primary
          }

          Row {
            id: cfgRow
            anchors.centerIn: parent
            spacing: 4

            Icon {
              anchors.verticalCenter: parent.verticalCenter
              width: 11
              height: 11
              name: "chip"
              color: cfgArea.containsMouse ? Theme.bg : Theme.primary
              weight: 2
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "SYS.CFG"
              color: cfgArea.containsMouse ? Theme.bg : Theme.primary
              font.family: Theme.fontUi
              font.pixelSize: 11
              font.weight: Font.Bold
              font.letterSpacing: 1
            }
          }

          Clickable {
            id: cfgArea
            anchors.fill: parent
            onClicked: Hud.toggleSettings(Hud.ccOutput)
          }
        }

        Caption {
          anchors.right: parent.right
          text: "BLACKWALL " + Blackwall.integrity.toFixed(2) + "%"
          color: Blackwall.integrity < 99 ? Theme.danger : Theme.alpha(Theme.subtle, 0.7)
          font.pixelSize: 8
        }
      }
    }

    // ---------------------------------------------- cyberware slots

    Item {
      width: cc.width
      height: slots.height + 18
      opacity: Math.min(1, cc.reveal * 1.6)

      Row {
        width: parent.width
        height: 12
        spacing: 6

        Text {
          id: slotsTitle
          anchors.verticalCenter: parent.verticalCenter
          text: "CYBERWARE // QUICK SLOTS"
          color: Theme.subtle
          font.family: Theme.fontUi
          font.pixelSize: 11
          font.weight: Font.Bold
          font.letterSpacing: 1.5
        }

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - slotsTitle.width - 6
          height: 1
          color: Theme.frameDim
        }
      }

      Row {
        id: slots
        y: 18
        width: cc.width
        spacing: 6

        readonly property real slotW: (cc.width - 36) / 7

        Tile {
          width: slots.slotW
          icon: Hud.dnd ? "bell-off" : "bell"
          label: "CAMO"
          hint: Hud.dnd ? "SILENT" : "VISIBLE"
          active: Hud.dnd
          tone: Theme.tertiary
          onClicked: Hud.dnd = !Hud.dnd
        }

        Tile {
          width: slots.slotW
          icon: Hud.caffeine ? "eye" : "eye-off"
          label: "ADRENALINE"
          hint: Hud.caffeine ? "NO SLEEP" : "IDLE OK"
          active: Hud.caffeine
          tone: Theme.warn
          onClicked: Hud.caffeine = !Hud.caffeine
        }

        Tile {
          width: slots.slotW
          icon: "matrix"
          label: "BREACH"
          hint: Stats.breaches + " RUNS"
          onClicked: Hud.openBreach(Hud.ccOutput)
        }

        Tile {
          width: slots.slotW
          icon: "hack"
          label: "QUICKHACK"
          hint: "SUPER+D"
          onClicked: {
            Hud.closeAll()
            Hud.quickhackRequested()
          }
        }

        Tile {
          width: slots.slotW
          icon: Sounds.fx ? (Sounds.ambience ? "volume" : "volume-low") : "volume-mute"
          label: "SOUND"
          hint: Sounds.fx ? (Sounds.ambience ? "ALL" : "FX ONLY") : "MUTED"
          active: Sounds.fx
          tone: Theme.secondary
          onClicked: Sounds.cycle()
        }

        Tile {
          width: slots.slotW
          icon: "bolt"
          label: "SANDEVISTAN"
          hint: Sandevistan.active ? "ENGAGED" : (Sandevistan.cooling ? "COOLDOWN " + Math.round(Sandevistan.heat * 100) + "%" : "SUPER+S")
          active: Sandevistan.active
          tone: Theme.ok
          onClicked: {
            Hud.closeAll()
            Sandevistan.activate()
          }
        }

        Tile {
          width: slots.slotW
          icon: "lock"
          label: "LOCK"
          hint: "SUPER+ALT+L"
          tone: Theme.danger
          onClicked: {
            Hud.closeAll()
            Lock.lock()
          }
        }
      }
    }

    // ---------------------------------------------- media + weather

    Row {
      visible: Settings.ccMedia || Settings.ccWeather
      width: cc.width
      spacing: 8

      Section {
        id: mediaSection
        width: Settings.ccWeather ? (cc.width - 8) * 0.6 : cc.width
        pairHeight: Settings.ccWeather ? weatherSection.contentHeight : 0
        visible: Settings.ccMedia
        title: "BRAINDANCE"
        code: cc.codeAt(0)
        icon: "music"
        index: Media.active ? (Media.player.identity || "MPRIS").toUpperCase() : "NO PLAYER"
        order: 1

        Item {
          width: parent.width
          height: 108

          Item {
            id: art
            width: 104
            height: 104
            y: 2

            Rectangle {
              anchors.fill: parent
              color: Theme.primaryDeep
              border.color: Theme.frame
              border.width: 1
            }

            Image {
              id: cover
              anchors.fill: parent
              anchors.margins: 1
              source: Media.art
              sourceSize: Qt.size(208, 208)
              fillMode: Image.PreserveAspectCrop
              asynchronous: true
              visible: false
            }

            MultiEffect {
              anchors.fill: cover
              source: cover
              visible: cover.status === Image.Ready
              colorization: 0.55
              colorizationColor: Theme.primary
              contrast: 0.15
            }

            Icon {
              anchors.centerIn: parent
              visible: cover.status !== Image.Ready
              width: 40
              height: 40
              name: "music"
              color: Theme.frame
            }

            Column {
              anchors.fill: parent
              anchors.margins: 1
              spacing: 2
              visible: cover.status === Image.Ready
              Repeater {
                model: 34
                delegate: Rectangle { width: art.width - 2; height: 1; color: "#000000"; opacity: 0.22 }
              }
            }

            Brackets { anchors.fill: parent; anchors.margins: -4; len: 10; tone: Theme.primary }
          }

          Column {
            x: 120
            width: parent.width - 120
            spacing: 2

            Row {
              spacing: 6

              Chip {
                label: Media.playing ? "LIVE FEED" : (Media.active ? "PAUSED" : "NO SIGNAL")
                tone: Media.playing ? Theme.danger : Theme.subtle
                solid: Media.playing
                size: 9
              }

              Chip {
                visible: Settings.hudDecor
                label: "LAYER: AUDIO"
                tone: Theme.secondary
                size: 9
              }
            }

            DecodeText {
              width: parent.width
              source: Media.title.toUpperCase()
              color: Theme.fg
              elide: Text.ElideRight
              font.family: Theme.fontUi
              font.pixelSize: 19
              font.weight: Font.Bold
            }

            Text {
              width: parent.width
              text: Media.artist.toUpperCase()
              color: Theme.secondary
              elide: Text.ElideRight
              font.family: Theme.fontUi
              font.pixelSize: 13
              font.weight: Font.DemiBold
              font.letterSpacing: 1
            }

            Item { width: 1; height: 4 }

            // braindance timeline: ticks, the elapsed part and the playhead
            Item {
              id: timeline
              width: parent.width
              height: 12
              readonly property real frac: Media.length > 0 ? Math.min(1, Media.position / Media.length) : 0

              Repeater {
                model: 21
                delegate: Rectangle {
                  required property int index
                  x: Math.round(index * (timeline.width - 1) / 20)
                  y: index % 5 === 0 ? 0 : 3
                  width: 1
                  height: index % 5 === 0 ? 12 : 6
                  color: Theme.alpha(Theme.primary, index / 20 <= timeline.frac ? 0.7 : 0.25)
                }
              }

              Rectangle {
                y: 5
                width: parent.width
                height: 2
                color: Theme.primaryDeep
              }

              Rectangle {
                y: 5
                width: parent.width * timeline.frac
                height: 2
                color: Theme.primary
                Behavior on width { NumberAnimation { duration: 900 } }
              }

              Rectangle {
                x: parent.width * timeline.frac - width / 2
                y: 2
                width: 8
                height: 8
                rotation: 45
                color: Theme.warn
                visible: Media.active
                Behavior on x { NumberAnimation { duration: 900 } }
              }
            }

            Item {
              width: parent.width
              height: 14

              Caption { text: Media.format(Media.position) }
              Caption { anchors.right: parent.right; text: Media.length > 0 ? Media.format(Media.length) : "--:--" }
            }

            Row {
              spacing: 8

              Repeater {
                model: [
                  { icon: "prev", act: "previous", big: false },
                  { icon: Media.playing ? "pause" : "play", act: "toggle", big: true },
                  { icon: "next", act: "next", big: false },
                  { icon: "refresh", act: "cycle", big: false }
                ]
                delegate: Item {
                  id: control
                  required property var modelData
                  width: modelData.big ? 44 : 30
                  height: 26

                  Plate {
                    anchors.fill: parent
                    cut: 6
                    fill: control.modelData.big ? Theme.primary : Theme.alpha(Theme.primary, controlArea.containsMouse ? 0.18 : 0.06)
                    stroke: Theme.alpha(Theme.primary, 0.6)
                  }

                  Icon {
                    anchors.centerIn: parent
                    width: control.modelData.big ? 16 : 13
                    height: width
                    name: control.modelData.icon
                    color: control.modelData.big ? Theme.bg : Theme.primary
                  }

                  Clickable {
                    id: controlArea
                    anchors.fill: parent
                    enabled: Media.active
                    onClicked: {
                      const p = Media.player
                      if (control.modelData.act === "toggle") p.togglePlaying()
                      else if (control.modelData.act === "next") p.next()
                      else if (control.modelData.act === "previous") p.previous()
                      else Media.cycle()
                    }
                  }
                }
              }
            }
          }
        }
      }

      Section {
        id: weatherSection
        visible: Settings.ccWeather
        pairHeight: Settings.ccMedia ? mediaSection.contentHeight : 0
        width: Settings.ccMedia ? (cc.width - 8) * 0.4 : cc.width
        title: "ATMOS"
        code: cc.codeAt(1)
        icon: Weather.icon
        index: Weather.place
        tone: Theme.secondary
        order: 1.5

        Column {
          width: parent.width
          spacing: 6

          Row {
            spacing: 10

            Icon {
              width: 44
              height: 44
              name: Weather.icon
              color: Theme.secondary
              weight: 1.4
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: Weather.ready ? Weather.temp + "°" + Settings.tempUnit : "--"
              color: Theme.fg
              font.family: Theme.fontUi
              font.pixelSize: 32
              font.weight: Font.Bold
            }
          }

          Text {
            width: parent.width
            text: Weather.ready ? Weather.condition : (Weather.failed ? "UPLINK LOST" : "SCANNING...")
            color: Weather.failed ? Theme.danger : Theme.secondary
            elide: Text.ElideRight
            font.family: Theme.fontUi
            font.pixelSize: 14
            font.weight: Font.Bold
            font.letterSpacing: 1
          }

          Caption {
            text: "FEELS " + Weather.feels + "°  //  HUM " + Weather.humidity + "%\nWIND " + Weather.wind + " " + Weather.windUnit
            lineHeight: 1.2
          }

          Row {
            spacing: 4
            Repeater {
              model: Weather.days
              delegate: Column {
                required property var modelData
                width: 40
                spacing: 1

                Caption {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: Qt.formatDate(new Date(modelData.date + "T12:00:00"), "ddd").toUpperCase()
                }

                Icon {
                  anchors.horizontalCenter: parent.horizontalCenter
                  width: 16
                  height: 16
                  name: modelData.icon
                  color: Theme.subtle
                  weight: 1.5
                }

                Caption {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: modelData.max + "/" + modelData.min
                  color: Theme.fg
                }
              }
            }
          }
        }
      }
    }

    // ---------------------------------------------- audio + deck status

    Row {
      visible: Settings.ccAudio || Settings.ccDeck
      width: cc.width
      spacing: 8

      Section {
        id: audioSection
        width: Settings.ccDeck ? (cc.width - 8) * 0.55 : cc.width
        pairHeight: Settings.ccDeck ? deckSection.contentHeight : 0
        visible: Settings.ccAudio
        title: "SONIC MATRIX"
        code: cc.codeAt(2)
        icon: Audio.icon
        index: "OUT " + Math.round(Audio.volume * 100) + "%"
        tone: Theme.secondary
        order: 2

        Column {
          width: parent.width
          spacing: 9

          Repeater {
            model: [
              { kind: "out", name: Audio.nameOf(Audio.sink), icon: Audio.icon, value: Audio.volume, muted: Audio.muted },
              { kind: "in", name: Audio.nameOf(Audio.source), icon: Audio.micMuted ? "mic-off" : "mic", value: Audio.micVolume, muted: Audio.micMuted }
            ]
            delegate: Item {
              id: channel
              required property var modelData
              readonly property color tone: modelData.kind === "out" ? Theme.primary : Theme.secondary
              width: parent.width
              height: 34

              Item {
                width: 26
                height: 26
                y: 4

                Plate {
                  anchors.fill: parent
                  cut: 6
                  fill: Theme.alpha(channel.modelData.muted ? Theme.danger : channel.tone, muteArea.containsMouse ? 0.2 : 0.06)
                  stroke: Theme.alpha(channel.modelData.muted ? Theme.danger : channel.tone, 0.6)
                }

                Icon {
                  anchors.centerIn: parent
                  width: 15
                  height: 15
                  name: channel.modelData.icon
                  color: channel.modelData.muted ? Theme.danger : channel.tone
                }

                Clickable {
                  id: muteArea
                  anchors.fill: parent
                  onClicked: channel.modelData.kind === "out" ? Audio.toggleMute() : Audio.toggleMic()
                }
              }

              Caption {
                x: 36
                text: (channel.modelData.kind === "out" ? "OUTPUT // " : "INPUT // ") + channel.modelData.name
                width: parent.width - 36 - 40
                elide: Text.ElideRight
              }

              Value {
                anchors.right: parent.right
                text: channel.modelData.muted ? "MUTE" : Math.round(channel.modelData.value * 100)
                color: channel.modelData.muted ? Theme.danger : Theme.fg
              }

              Slider {
                x: 36
                y: 18
                width: parent.width - 36
                height: 12
                value: channel.modelData.value
                muted: channel.modelData.muted
                tone: channel.tone
                onMoved: (v) => channel.modelData.kind === "out" ? Audio.setVolume(v) : Audio.setMic(v)
              }
            }
          }

          Repeater {
            model: Audio.streams.slice(0, 4)
            delegate: Item {
              id: stream
              required property var modelData
              width: parent.width
              height: 20

              Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 5
                height: 5
                rotation: 45
                color: Theme.tertiary
              }

              Caption {
                x: 12
                width: 116
                anchors.verticalCenter: parent.verticalCenter
                text: Audio.nameOf(stream.modelData).toUpperCase()
                elide: Text.ElideRight
                color: Theme.fg
              }

              Slider {
                x: 132
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 132 - 36
                height: 8
                segments: 32
                value: stream.modelData.audio ? stream.modelData.audio.volume : 0
                tone: Theme.tertiary
                onMoved: (v) => { if (stream.modelData.audio) stream.modelData.audio.volume = v }
              }

              Caption {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: stream.modelData.audio ? Math.round(stream.modelData.audio.volume * 100) : "--"
              }
            }
          }
        }
      }

      Section {
        id: deckSection
        width: Settings.ccAudio ? (cc.width - 8) * 0.45 : cc.width
        pairHeight: Settings.ccAudio ? audioSection.contentHeight : 0
        visible: Settings.ccDeck
        title: "CYBERDECK STATUS"
        code: cc.codeAt(3)
        icon: "chip"
        index: "€$ " + Stats.format(Stats.eddies)
        tone: Theme.warn
        order: 2.5

        Column {
          width: parent.width
          spacing: 10

          Grid {
            id: attrs
            width: parent.width
            columns: 2
            spacing: 6
            readonly property real boxW: (width - 6) / 2

            Attribute {
              width: attrs.boxW
              label: "SYNAPSE"
              value: Math.round(Sys.cpu * 100)
              unit: "%"
              fill: Sys.cpu
              tone: Sys.cpu > 0.85 ? Theme.danger : Theme.primary
            }

            Attribute {
              width: attrs.boxW
              label: "RAM " + Sys.memTotal.toFixed(0) + "G"
              value: Sys.memUsed.toFixed(1)
              unit: "G"
              fill: Sys.mem
              tone: Sys.mem > 0.85 ? Theme.danger : Theme.secondary
            }

            Attribute {
              width: attrs.boxW
              label: "SHARD " + Sys.diskTotal.toFixed(0) + "G"
              value: Math.round(Sys.disk * 100)
              unit: "%"
              fill: Sys.disk
              tone: Sys.disk > 0.9 ? Theme.danger : Theme.tertiary
            }

            Attribute {
              width: attrs.boxW
              label: Network.kind === "offline" ? "NO UPLINK" : (Network.name || "UPLINK").toUpperCase()
              value: Network.kind === "wifi" ? Network.strength : (Network.kind === "ethernet" ? "LAN" : "--")
              unit: Network.kind === "wifi" ? "%" : ""
              fill: Network.kind === "wifi" ? Network.strength / 100 : (Network.kind === "ethernet" ? 1 : 0)
              tone: Network.kind === "offline" ? Theme.danger : Theme.ok
            }
          }

          // synapse trace, the last minutes of CPU load
          Item {
            width: parent.width
            height: 52

            Caption { text: "SYNAPSE TRACE // " + (Sys.history.length * 2) + "S" }
            Caption { anchors.right: parent.right; text: "UPTIME " + Sys.uptime; color: Theme.fg }

            Item {
              id: trace
              y: 16
              width: parent.width
              height: 34

              Rectangle { anchors.fill: parent; color: Theme.alpha(Theme.primary, 0.04); border.color: Theme.alpha(Theme.primary, 0.2); border.width: 1 }

              Repeater {
                model: 3
                delegate: Rectangle {
                  required property int index
                  y: (index + 1) * trace.height / 4
                  width: trace.width
                  height: 1
                  color: Theme.alpha(Theme.primary, 0.08)
                }
              }

              Row {
                anchors.right: parent.right
                anchors.rightMargin: 2
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 1
                spacing: 1

                Repeater {
                  model: Sys.history
                  delegate: Rectangle {
                    required property var modelData
                    anchors.bottom: parent.bottom
                    width: (trace.width - 4) / 48 - 1
                    height: Math.max(1, (trace.height - 3) * modelData)
                    color: modelData > 0.85 ? Theme.danger : Theme.alpha(Theme.primary, 0.4 + modelData * 0.6)
                  }
                }
              }
            }
          }
        }
      }
    }

    // ---------------------------------------------- calendar + messages, down to the footer

    Row {
      id: lastRow
      visible: Settings.ccWeather || Settings.ccMessages
      width: cc.width
      spacing: 8

      Section {
        id: calendarSection
        visible: Settings.ccWeather
        width: Settings.ccMessages ? (cc.width - 8) * 0.45 : cc.width
        title: "CALENDAR"
        code: cc.codeAt(4)
        icon: "calendar"
        index: Qt.formatDate(new Date(), "dd.MM")
        tone: Theme.primary
        order: 3

        Calendar {
          width: parent.width
        }
      }

      Section {
        id: messagesSection
        width: Settings.ccWeather ? (cc.width - 8) * 0.55 : cc.width
        // stretches over what is left of the drawer
        pairHeight: cc.available - lastRow.y - footer.height - column.spacing
        visible: Settings.ccMessages
        title: "MESSAGES"
        code: cc.codeAt(5)
        icon: Hud.dnd ? "bell-off" : "bell"
        index: Notifs.count + " UNREAD"
        tone: Theme.tertiary
        order: 3.5

        Item {
          width: parent.width
          height: Math.max(Math.min(Math.max(30, log.contentHeight), 240) + 26, messagesSection.pairHeight - 52)

          ListView {
            id: log
            width: parent.width
            height: parent.height - 26
            clip: true
            spacing: 6
            model: Notifs.list.slice().reverse()
            boundsBehavior: Flickable.StopAtBounds

            // a thread of the phone: contact avatar, name, last message
            delegate: Item {
              id: entry
              required property var modelData
              required property int index
              width: log.width
              height: Math.max(46, msg.implicitHeight + 26)
              readonly property bool critical: Notifs.isCritical(modelData)
              readonly property color tone: critical ? Theme.danger : Theme.tertiary
              readonly property string sender: (modelData.appName || "UNKNOWN").toUpperCase()

              Plate {
                anchors.fill: parent
                cut: 0
                cutBR: 8
                fill: Theme.alpha(entry.tone, entryArea.containsMouse ? 0.14 : 0.05)
                stroke: Theme.alpha(entry.tone, entryArea.containsMouse ? 0.6 : 0.25)
              }

              Item {
                x: 8
                y: 8
                width: 30
                height: 30

                Plate {
                  anchors.fill: parent
                  cut: 7
                  fill: Theme.alpha(entry.tone, 0.18)
                  stroke: entry.tone
                }

                Text {
                  anchors.centerIn: parent
                  text: entry.sender.slice(0, 1)
                  color: entry.tone
                  font.family: Theme.fontUi
                  font.pixelSize: 17
                  font.weight: Font.Bold
                }
              }

              Caption {
                x: 46
                y: 6
                text: entry.sender
                color: entry.tone
                font.weight: Font.Bold
              }

              Chip {
                anchors.right: parent.right
                anchors.rightMargin: 10
                y: 5
                visible: entry.index === 0 || entry.critical
                label: entry.critical ? "PRIORITY" : "NEW"
                tone: entry.tone
                solid: true
                size: 8
              }

              Text {
                id: msg
                x: 46
                y: 19
                width: parent.width - 46 - 28
                text: "<b>" + entry.modelData.summary + "</b>" + (entry.modelData.body ? "  " + entry.modelData.body : "")
                textFormat: Text.StyledText
                color: Theme.fg
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                font.family: Theme.fontUi
                font.pixelSize: 13
                font.weight: Font.Medium
              }

              Clickable {
                id: entryArea
                anchors.fill: parent
                onClicked: Notifs.dismiss(entry.modelData)
              }

              Icon {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                width: 12
                height: 12
                name: "close"
                color: Theme.subtle
                visible: entryArea.containsMouse
              }
            }
          }

          Text {
            visible: Notifs.count === 0
            y: 4
            text: "NO INCOMING TRANSMISSIONS"
            color: Theme.muted
            font.family: Theme.fontUi
            font.pixelSize: 14
            font.weight: Font.Bold
            font.letterSpacing: 1.5
          }

          Row {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 6
            visible: Notifs.count > 0

            Icon { anchors.verticalCenter: parent.verticalCenter; width: 12; height: 12; name: "trash"; color: Theme.subtle }

            Text {
              text: "PURGE ALL"
              color: clearArea.containsMouse ? Theme.danger : Theme.subtle
              font.family: Theme.fontUi
              font.pixelSize: 12
              font.weight: Font.Bold
              font.letterSpacing: 1

              Clickable {
                id: clearArea
                anchors.fill: parent
                anchors.margins: -4
                onClicked: Notifs.clear()
              }
            }
          }
        }
      }
    }

    // ---------------------------------------------- key hints footer

    Item {
      id: footer
      width: cc.width
      height: 30
      opacity: Math.min(1, cc.reveal * 1.2)

      Rectangle { width: parent.width; height: 1; color: Theme.frameDim }

      Row {
        y: 6
        spacing: 12

        Repeater {
          model: [
            { key: "ESC", label: "CLOSE" },
            { key: "SUPER+A", label: "TOGGLE" },
            { key: "SUPER+D", label: "QUICKHACK" }
          ]
          delegate: Row {
            required property var modelData
            spacing: 5

            KeyCap {
              anchors.verticalCenter: parent.verticalCenter
              implicitHeight: 18
              label: modelData.key
              tone: Theme.subtle
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: modelData.label
              color: Theme.subtle
              font.family: Theme.fontUi
              font.pixelSize: 12
              font.weight: Font.Bold
              font.letterSpacing: 1
            }
          }
        }
      }

      MicroText {
        visible: Settings.hudDecor
        anchors.right: parent.right
        y: 11
        text: "BUILD " + Theme.os.toUpperCase() + " // " + Qt.formatDate(new Date(), "yyyy.MM.dd")
      }
    }
  }
}
