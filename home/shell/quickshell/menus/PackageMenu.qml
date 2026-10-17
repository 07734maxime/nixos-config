import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.services
import qs.components

// PACKAGE BROKER: searches nixpkgs and adds programs to home/packages.json
// through cyberdeck-pkgs (see shell/tools.nix), which refuses any name nixpkgs does
// not know. ENGRAVE installs them. Opened from the bar, the MENU tab of the
// quickhack launcher or `quickshell -c cyberdeck ipc call packages open`.
Overlay {
  id: window

  screen: Hud.screenNamed(Hud.pkgOutput)
  open: Hud.pkgOpen
  WlrLayershell.namespace: "cyberdeck-packages"
  blurItem: panel
  blurPad: backdrop.pad
  onDismissed: Hud.pkgOpen = false

  property string query: ""
  property var results: []
  property int selected: 0
  property var status: ({ channel: "", count: 0, age: -1, managed: [], writable: true })
  property bool searching: false
  property string searchedFor: ""
  property string flash: ""
  property bool flashOk: true
  property string busyName: ""

  readonly property var current: results.length > 0 ? results[Math.min(selected, results.length - 1)] : null
  // the end of the selected name, drawn after what was typed; TAB takes it
  readonly property string ghost: current && query !== "" && current.name.toLowerCase().startsWith(query.toLowerCase()) ? current.name.slice(query.length) : ""

  function lastLine(text) {
    const lines = text.trim().split("\n").filter(l => l !== "")
    return lines.length > 0 ? lines[lines.length - 1].replace(/^cyberdeck-pkgs: /, "") : ""
  }

  function say(text, ok) {
    flash = text
    flashOk = ok
    flashTimer.restart()
    Sounds.play(ok ? "breach-success" : "breach-fail")
  }

  function search() {
    const q = query.trim()
    if (q === "") {
      results = []
      searchedFor = ""
      return
    }
    // a run is going: its end starts the next one with the latest text
    if (searcher.running) return
    searchedFor = q
    searching = true
    searcher.command = [Theme.bin("pkgs"), "search", q]
    searcher.running = true
  }

  function add(name) {
    if (installer.running || name === "") return
    busyName = name
    installer.command = [Theme.bin("pkgs"), "add", name]
    installer.running = true
  }

  function remove(name) {
    if (installer.running) return
    busyName = name
    installer.command = [Theme.bin("pkgs"), "remove", name]
    installer.running = true
  }

  // ENTER: the selected match, or exactly what was typed (refused if unknown)
  function submit() {
    const typed = query.trim()
    if (current && !current.installed) add(current.name)
    else if (current && current.installed) say("'" + current.name + "' IS ALREADY INSTALLED", false)
    else if (typed !== "") add(typed)
  }

  function move(delta) {
    if (results.length === 0) return
    selected = Math.max(0, Math.min(results.length - 1, selected + delta))
    list.positionViewAtIndex(selected, ListView.Contain)
    Sounds.play("hover")
  }

  function prefill(text) {
    input.text = text
    input.cursorPosition = text.length
  }

  function complete() {
    if (!current) return
    query = current.name
    input.text = current.name
    input.cursorPosition = input.text.length
  }

  onOpenChanged: {
    if (!open) return
    statusProc.running = true
    Qt.callLater(() => input.forceActiveFocus())
  }

  Timer {
    id: debounce
    interval: 160
    onTriggered: window.search()
  }

  Timer {
    id: flashTimer
    interval: 6000
    onTriggered: window.flash = ""
  }

  Process {
    id: searcher
    stdout: StdioCollector { id: searchOut }
    stderr: StdioCollector { id: searchErr }
    onExited: (code) => {
      window.searching = false
      if (code === 0) {
        try {
          window.results = JSON.parse(searchOut.text)
        } catch (error) {
          window.results = []
        }
        window.selected = 0
      } else {
        window.say(window.lastLine(searchErr.text) || "SEARCH FAILED", false)
      }
      // the first search downloads the index
      if (window.status.count === 0) statusProc.running = true
      if (window.query.trim() !== window.searchedFor) window.search()
    }
  }

  Process {
    id: installer
    stdout: StdioCollector { id: installOut }
    stderr: StdioCollector { id: installErr }
    onExited: (code) => {
      if (code === 0) window.say(window.lastLine(installOut.text) + "  //  ENGRAVE TO INSTALL IT", true)
      else window.say(window.lastLine(installErr.text) || "BROKER OFFLINE", false)
      window.busyName = ""
      statusProc.running = true
      window.searchedFor = ""
      window.search()
    }
  }

  Process {
    id: statusProc
    command: [Theme.bin("pkgs"), "status"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          window.status = JSON.parse(this.text)
        } catch (error) {
          console.warn("cyberdeck: unreadable package status: " + error)
        }
      }
    }
  }

  // ------------------------------------------------------------ pieces

  component Action: Item {
    id: action
    property string label: ""
    property color tone: Theme.primary
    signal triggered()

    width: actionText.implicitWidth + 28
    height: 28

    Plate {
      anchors.fill: parent
      cut: 8
      fill: actionArea.containsMouse ? action.tone : Theme.alpha(action.tone, 0.1)
      stroke: action.tone
    }

    Text {
      id: actionText
      anchors.centerIn: parent
      text: action.label
      color: actionArea.containsMouse ? Theme.bg : action.tone
      font.family: Theme.fontUi
      font.pixelSize: 12
      font.weight: Font.Bold
      font.letterSpacing: 1
    }

    Clickable {
      id: actionArea
      anchors.fill: parent
      onClicked: action.triggered()
    }
  }

  // ------------------------------------------------------------ panel

  Item {
    id: panel
    // a drawer down the whole left edge, sliding in from the side
    x: 12 - (1 - window.reveal) * (width + 24)
    y: 6
    width: Math.min(760, parent.width - 24)
    height: parent.height - 12
    opacity: Math.min(1, window.reveal * 2)

    Backdrop { id: backdrop }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.AllButtons
    }

    Column {
      id: top
      width: parent.width
      spacing: 8

      Header {
        width: parent.width
        height: 30
        label: "PACKAGE BROKER"
        index: "NIXPKGS // " + (window.status.channel || "...").toUpperCase()
        icon: "package"
      }

      // the search line
      Item {
        width: parent.width
        height: 56

        Plate {
          anchors.fill: parent
          cut: 14
          cutBL: 6
          fill: Theme.alpha(Theme.primary, input.activeFocus ? 0.1 : 0.05)
          stroke: Theme.primary
          strokeW: 1.5
        }

        Rectangle { x: 0; y: 12; width: 3; height: parent.height - 24; color: Theme.primary }

        Text {
          id: prompt
          x: 16
          anchors.verticalCenter: parent.verticalCenter
          text: ">"
          color: Theme.primary
          font.family: Theme.fontMono
          font.pixelSize: 20
          font.weight: Font.Bold
        }

        Item {
          id: field
          x: 42
          width: parent.width - 42 - statusChip.width - 28
          height: parent.height
          clip: true

          Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: input.text === ""
            text: "SCAN NIXPKGS FOR A PACKAGE..."
            color: Theme.muted
            font: input.font
          }

          TextInput {
            id: input
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            color: Theme.fg
            selectionColor: Theme.alpha(Theme.primary, 0.5)
            selectByMouse: true
            font.family: Theme.fontUi
            font.pixelSize: 24
            font.weight: Font.Bold
            font.letterSpacing: 1
            onTextChanged: {
              window.query = text
              debounce.restart()
            }
            Keys.onPressed: (event) => {
              if (event.key === Qt.Key_Down) window.move(1)
              else if (event.key === Qt.Key_Up) window.move(-1)
              else if (event.key === Qt.Key_Tab) window.complete()
              else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) window.submit()
              else if (event.key === Qt.Key_Escape) window.dismissed()
              else return
              event.accepted = true
            }
          }

          // autocompletion ghost, after the typed text
          Text {
            x: input.contentWidth
            anchors.verticalCenter: parent.verticalCenter
            visible: window.ghost !== "" && input.cursorPosition === input.text.length
            text: window.ghost
            color: Theme.alpha(Theme.primary, 0.4)
            font: input.font
          }
        }

        Chip {
          id: statusChip
          anchors.right: parent.right
          anchors.rightMargin: 18
          anchors.verticalCenter: parent.verticalCenter
          label: window.searching ? (window.status.count === 0 ? "DOWNLOADING INDEX" : "SCANNING")
               : window.query.trim() === "" ? "TAB // COMPLETE" : window.results.length + (window.results.length >= 40 ? "+" : "") + " MATCHES"
          tone: window.searching ? Theme.warn : Theme.primary
          flashing: window.searching
          size: 11
        }
      }

      // last answer of the broker, or the state of the index
      Text {
        x: 4
        width: parent.width - 8
        height: 18
        elide: Text.ElideRight
        text: window.flash !== "" ? window.flash
            : window.status.count > 0 ? "INDEX // " + Stats.format(window.status.count) + " PACKAGES OF " + window.status.channel.toUpperCase() + " // UPDATED " + Math.floor(window.status.age / 86400) + "D AGO // ONLY EXISTING PACKAGES ARE ACCEPTED"
            : "INDEX // DOWNLOADED FROM CHANNELS.NIXOS.ORG ON THE FIRST SEARCH (A FEW SECONDS)"
        color: window.flash !== "" ? (window.flashOk ? Theme.ok : Theme.danger) : Theme.subtle
        font.family: window.flash !== "" ? Theme.fontUi : Theme.fontMono
        font.pixelSize: window.flash !== "" ? 14 : 9
        font.weight: window.flash !== "" ? Font.Bold : Font.Normal
        font.letterSpacing: 0.5
      }
    }

    // ------------------------------------------------ matches

    Item {
      id: matches
      anchors.top: top.bottom
      anchors.topMargin: 8
      anchors.bottom: bottom.top
      anchors.bottomMargin: 8
      width: parent.width

      Plate {
        anchors.fill: parent
        cut: 0
        cutBR: 14
        fill: Settings.plate
        stroke: Theme.frameDim
      }

      Column {
        anchors.centerIn: parent
        visible: window.results.length === 0
        spacing: 6

        Icon {
          anchors.horizontalCenter: parent.horizontalCenter
          width: 42
          height: 42
          name: window.query.trim() === "" ? "package" : "close"
          color: window.query.trim() === "" ? Theme.frame : Theme.danger
          weight: 1.4
        }

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: window.query.trim() === "" ? "TYPE A NAME TO SCAN NIXPKGS"
              : window.searching ? "SCANNING..." : "NO MATCH IN NIXPKGS"
          color: window.query.trim() === "" || window.searching ? Theme.subtle : Theme.danger
          font.family: Theme.fontUi
          font.pixelSize: 18
          font.weight: Font.Bold
          font.letterSpacing: 2
        }

        MicroText {
          anchors.horizontalCenter: parent.horizontalCenter
          text: window.query.trim() === "" ? "NAMES, PACKAGE SETS (PYTHON3PACKAGES.REQUESTS) OR WORDS OF THE DESCRIPTION"
              : "'" + window.query.trim().toUpperCase() + "' WOULD BE REFUSED"
        }
      }

      ListView {
        id: list
        anchors.fill: parent
        anchors.margins: 6
        anchors.bottomMargin: 14
        clip: true
        spacing: 2
        model: window.results
        currentIndex: window.selected
        boundsBehavior: Flickable.StopAtBounds

        delegate: Item {
          id: row
          required property var modelData
          required property int index
          readonly property bool picked: index === window.selected
          readonly property bool busy: installer.running && window.busyName === modelData.name
          width: list.width
          height: 50

          Rectangle {
            anchors.fill: parent
            color: Theme.alpha(Theme.primary, row.picked ? 0.14 : (rowArea.containsMouse ? 0.07 : 0))
            border.color: Theme.alpha(Theme.primary, row.picked ? 0.5 : 0)
            border.width: 1
          }

          Rectangle {
            visible: row.picked
            width: 3
            height: parent.height
            color: Theme.primary
          }

          Row {
            x: 14
            y: 6
            spacing: 8

            Text {
              text: row.modelData.name
              color: row.picked ? Theme.primary : Theme.fg
              font.family: Theme.fontUi
              font.pixelSize: 17
              font.weight: Font.Bold
            }

            Text {
              anchors.baseline: parent.children[0].baseline
              text: row.modelData.version
              color: Theme.subtle
              font.family: Theme.fontMono
              font.pixelSize: 9
            }
          }

          Text {
            x: 14
            y: 28
            width: parent.width - 28 - side.width
            text: row.modelData.description || "NO DESCRIPTION"
            color: row.modelData.description ? Theme.subtle : Theme.muted
            elide: Text.ElideRight
            font.family: Theme.fontUi
            font.pixelSize: 13
            font.weight: Font.Medium
          }

          Item {
            id: side
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 110
            height: 28

            Chip {
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              visible: row.modelData.installed || row.busy
              label: row.busy ? "UPLOADING..." : "INSTALLED"
              tone: row.busy ? Theme.warn : Theme.ok
              solid: !row.busy
              flashing: row.busy
              size: 11
            }

            Action {
              anchors.right: parent.right
              visible: !row.modelData.installed && !row.busy && (row.picked || rowArea.containsMouse)
              label: "+ ADD"
              onTriggered: window.add(row.modelData.name)
            }
          }

          Clickable {
            id: rowArea
            anchors.fill: parent
            anchors.rightMargin: side.width + 12
            onEntered: window.selected = row.index
            onClicked: {
              window.selected = row.index
              window.complete()
            }
            onDoubleClicked: if (!row.modelData.installed) window.add(row.modelData.name)
          }
        }
      }
    }

    // ------------------------------------------------ the broker list and the keys

    Column {
      id: bottom
      anchors.bottom: parent.bottom
      width: parent.width
      spacing: 8

      Item {
        width: parent.width
        height: brokerBody.height + 46

        Plate {
          anchors.fill: parent
          cut: 12
          cutBL: 6
          fill: Settings.plate
          stroke: Theme.alpha(Theme.warn, 0.6)
        }

        Row {
          x: 14
          y: 10
          spacing: 8

          Icon { anchors.verticalCenter: parent.verticalCenter; width: 16; height: 16; name: "package"; color: Theme.warn }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "ADDED FROM THE BROKER // " + (window.status.managed || []).length
            color: Theme.warn
            font.family: Theme.fontUi
            font.pixelSize: 15
            font.weight: Font.Bold
            font.letterSpacing: 1.5
          }
        }

        Action {
          anchors.right: parent.right
          anchors.rightMargin: 14
          y: 8
          label: "ENGRAVE NOW"
          tone: Theme.warn
          onTriggered: {
            Hud.pkgOpen = false
            Quickshell.execDetached([Theme.bin("kitty"), "--class", "cyberdeck-float", "--title", "ENGRAVING FIRMWARE", "-e", Theme.bin("engrave")])
          }
        }

        Column {
          id: brokerBody
          x: 14
          y: 40
          width: parent.width - 28
          spacing: 6

          Flow {
            width: parent.width
            spacing: 6
            visible: (window.status.managed || []).length > 0

            Repeater {
              model: window.status.managed || []
              delegate: Item {
                id: pkg
                required property string modelData
                width: pkgRow.width + 16
                height: 22

                Plate {
                  anchors.fill: parent
                  cut: 6
                  fill: Theme.alpha(pkgArea.containsMouse ? Theme.danger : Theme.warn, 0.1)
                  stroke: pkgArea.containsMouse ? Theme.danger : Theme.alpha(Theme.warn, 0.6)
                }

                Row {
                  id: pkgRow
                  anchors.centerIn: parent
                  spacing: 6

                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: pkg.modelData
                    color: pkgArea.containsMouse ? Theme.danger : Theme.fg
                    font.family: Theme.fontUi
                    font.pixelSize: 13
                    font.weight: Font.Bold
                  }

                  Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 9
                    height: 9
                    name: "close"
                    color: pkgArea.containsMouse ? Theme.danger : Theme.subtle
                    weight: 2.4
                  }
                }

                Clickable {
                  id: pkgArea
                  anchors.fill: parent
                  onClicked: window.remove(pkg.modelData)
                }
              }
            }
          }

          MicroText {
            width: parent.width
            wrapMode: Text.WordWrap
            text: (window.status.managed || []).length === 0
                ? "NOTHING YET. WHAT YOU ADD LANDS IN " + (window.status.repo || "THE REPO") .toUpperCase() + "/HOME/PACKAGES.JSON"
                : "WRITTEN TO " + (window.status.repo || "THE REPO").toUpperCase() + "/HOME/PACKAGES.JSON // ENGRAVE (NIXOS-REBUILD) INSTALLS OR REMOVES THEM"
            color: Theme.subtle
          }
        }
      }

      Item {
        width: parent.width
        height: 28

        Row {
          anchors.verticalCenter: parent.verticalCenter
          x: 4
          spacing: 12

          Repeater {
            model: [
              { key: "↑↓", label: "SELECT" },
              { key: "TAB", label: "COMPLETE" },
              { key: "↵", label: "ADD" },
              { key: "ESC", label: "CLOSE" }
            ]
            delegate: Row {
              required property var modelData
              spacing: 5

              KeyCap {
                anchors.verticalCenter: parent.verticalCenter
                implicitHeight: 20
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
      }
    }
  }
}
