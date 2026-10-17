import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.components

// The holocall, top left like in the game: the brick phone sending its waves,
// who is calling, and their portrait behind the red frame. Sounds rings it.
// Real calls (Calls.ring) offer the app's own actions; the contacts of the
// simulator get ANSWER / DECLINE, then talk in subtitles with dialogue choices.
PanelWindow {
  id: window

  readonly property color frameTone: Theme.danger
  readonly property color nameTone: Theme.primary
  readonly property bool sim: Calls.simulated && Calls.contact !== null
  readonly property color contactTone: sim ? Theme[Calls.contact.tone] : nameTone
  readonly property bool glitchy: sim && Calls.contact.glitch === true
  readonly property string phase: Calls.phase
  property real enter: Calls.active ? 1 : 0
  property int elapsed: 0

  Behavior on enter { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

  screen: Hud.screenNamed(Hud.here())
  visible: enter > 0 && !Lock.locked
  color: "transparent"
  anchors {
    top: true
    left: true
  }
  margins {
    top: 10
    left: 16
  }
  exclusionMode: ExclusionMode.Normal
  implicitWidth: 440
  implicitHeight: Math.max(1, content.height)
  WlrLayershell.namespace: "cyberdeck-holocall"
  WlrLayershell.layer: WlrLayer.Overlay

  function clock(seconds) {
    const pad = v => (v < 10 ? "0" : "") + v
    return pad(Math.floor(seconds / 60)) + ":" + pad(seconds % 60)
  }

  // the "default" action only brings the app forward (Discord's single "View"):
  // that is where the call gets picked up
  function actionLabel(action) {
    if (action.identifier === "default") return "OPEN " + (Calls.app || "APP").toUpperCase()
    return (action.text || "OK").toUpperCase()
  }

  function actionTone(label) {
    if (/^open |accept|answer|join|r[ée]pondre|d[ée]crocher|rejoindre/i.test(label)) return Theme.ok
    if (/decline|reject|ignore|refuser|raccrocher/i.test(label)) return Theme.danger
    return window.nameTone
  }

  readonly property string status: phase === "dialing" ? "CALLING..."
      : phase === "connected" ? "HOLOCALL // CONNECTED"
      : phase === "ended" ? "CALL ENDED"
      : "INCOMING CALL" + (Calls.app !== "" ? " // " + Calls.app.toUpperCase() : "")

  readonly property string footer: phase === "dialing" ? "DIALING // ESTABLISHING LINK"
      : phase === "connected" ? "CONNECTED // " + clock(elapsed)
      : phase === "ended" ? "SIGNAL LOST"
      : "RINGING // " + clock(elapsed)

  // a new caller, even over a ringing call, tears in again
  Connections {
    target: Calls
    function onSinceChanged() {
      window.elapsed = 0
      title.burst()
      flicker.restart()
    }
    function onPhaseChanged() {
      if (Calls.phase === "ended") flicker.restart()
    }
  }

  Timer {
    interval: 1000
    repeat: true
    running: Calls.active
    onTriggered: window.elapsed = Math.floor((Date.now() - Calls.since) / 1000)
  }

  // the small square buttons of the holocall
  component Action: Item {
    id: button
    property string label: ""
    property color tone: Theme.primary
    signal triggered()
    width: buttonText.implicitWidth + 18
    height: 24

    Plate {
      anchors.fill: parent
      cut: 6
      fill: Theme.alpha(Theme.mix(Theme.bg, button.tone, buttonArea.containsMouse ? 0.35 : 0.14), 0.94)
      stroke: button.tone
    }

    Text {
      id: buttonText
      anchors.centerIn: parent
      text: button.label
      color: button.tone
      font.family: Theme.fontUi
      font.pixelSize: 13
      font.weight: Font.Bold
    }

    Clickable {
      id: buttonArea
      anchors.fill: parent
      onClicked: button.triggered()
    }
  }

  Item {
    id: content
    width: parent.width
    height: buttons.y + (buttons.visible ? buttons.height : 0)
    opacity: window.enter
    transform: Translate { x: (1 - window.enter) * -40 }

    // keeps the caller readable over any window
    Plate {
      x: -8
      y: -4
      width: Math.min(content.width + 8, Math.max(phone.width, heading.x + headingWidth.width) + 24)
      height: heading.y + heading.height + 10
      cut: 10
      cutBL: 4
      fill: Theme.alpha(Theme.bg, 0.82)
      strokeW: 0
    }

    TextMetrics {
      id: headingWidth
      font.family: Theme.fontUi
      font.pixelSize: 30
      font.weight: Font.Bold
      text: Calls.caller.toUpperCase()
    }

    Icon {
      id: phone
      x: 0
      y: 8
      width: 36
      height: 36
      name: "phone"
      color: window.contactTone
      weight: 1.6
    }

    // in step with V's ringtone: one wave burst per ring, steady once connected
    Icon {
      anchors.fill: phone
      name: "waves"
      color: window.contactTone
      weight: 1.6
      opacity: window.phase === "connected" ? 0.9 : 0.15

      SequentialAnimation on opacity {
        loops: Animation.Infinite
        running: Calls.active && (window.phase === "ringing" || window.phase === "dialing")
        NumberAnimation { to: 1; duration: 120 }
        PauseAnimation { duration: 700 }
        NumberAnimation { to: 0.15; duration: 300 }
        PauseAnimation { duration: 726 }
      }
    }

    Column {
      id: heading
      x: 48
      width: parent.width - x
      spacing: 0

      Text {
        text: window.status
        color: Theme.alpha(window.phase === "connected" ? Theme.ok : window.frameTone, 0.85)
        font.family: Theme.fontMono
        font.pixelSize: 10
        font.weight: Font.Bold
        font.letterSpacing: 2
      }

      GlitchText {
        id: title
        width: parent.width
        text: Calls.caller.toUpperCase()
        color: window.contactTone
        elide: Text.ElideRight
        font.family: Theme.fontUi
        font.pixelSize: 30
        font.weight: Font.Bold
        font.letterSpacing: 1
        minGap: window.glitchy ? 300 : 1800
        maxGap: window.glitchy ? 900 : 4000
      }

      Text {
        visible: window.sim
        text: window.sim ? Calls.contact.role : ""
        color: Theme.subtle
        font.family: Theme.fontMono
        font.pixelSize: 9
        font.letterSpacing: 1
      }
    }

    Item {
      id: frame
      x: heading.x
      y: heading.y + heading.height + 10
      width: 230
      height: 230

      SequentialAnimation on opacity {
        id: flicker
        running: false
        NumberAnimation { to: 0.2; duration: 40 }
        NumberAnimation { to: 1; duration: 50 }
        PauseAnimation { duration: 90 }
        NumberAnimation { to: 0.4; duration: 30 }
        NumberAnimation { to: 1; duration: 60 }
      }

      Plate {
        anchors.fill: parent
        cut: 14
        cutBL: 14
        fill: Theme.alpha(window.frameTone, 0.12)
        stroke: window.phase === "connected" ? window.contactTone : window.frameTone
        strokeW: 2
      }

      Item {
        id: portrait
        anchors.fill: parent
        anchors.margins: 7
        clip: true
        transform: Translate { id: jitter }

        Image {
          id: photo
          anchors.fill: parent
          source: Calls.image
          sourceSize: Qt.size(256, 256)
          fillMode: Image.PreserveAspectCrop
          asynchronous: true
          smooth: true
          visible: status === Image.Ready
        }

        // no picture: the contact's monogram, the app's icon, else a silhouette,
        // as a hologram on the red screen
        Rectangle {
          anchors.fill: parent
          visible: !photo.visible
          color: Theme.alpha(Theme.mix(Theme.bg, window.frameTone, 0.2), 0.92)

          Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            y: window.sim ? 18 : (parent.height - height) / 2
            width: window.sim ? 150 : 120
            height: width
            visible: Calls.appIcon === ""
            name: "user"
            color: window.sim ? Theme.alpha(window.contactTone, 0.35) : window.nameTone
            weight: 1.2
          }

          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 34
            visible: window.sim
            text: window.sim ? Calls.contact.monogram : ""
            color: window.contactTone
            style: Text.Outline
            styleColor: Theme.alpha(Theme.bg, 0.6)
            font.family: Theme.fontUi
            font.pixelSize: 64
            font.weight: Font.Bold
            font.letterSpacing: 4
          }

          HoloIcon {
            anchors.centerIn: parent
            width: 96
            height: 96
            visible: Calls.appIcon !== ""
            source: Calls.appIcon
            tone: window.nameTone
            glow: 0.6
          }
        }

        // the holocall's red cast and its scanlines
        Rectangle {
          anchors.fill: parent
          color: Theme.alpha(window.glitchy ? Theme.danger : window.frameTone, window.glitchy ? 0.26 : 0.16)
        }

        Column {
          anchors.fill: parent
          Repeater {
            model: Math.ceil(portrait.height / 3)
            delegate: Item {
              width: portrait.width
              height: 3
              Rectangle { width: parent.width; height: 1; color: Qt.rgba(0, 0, 0, 0.28) }
            }
          }
        }

        Rectangle {
          id: sweep
          width: parent.width
          height: 26
          gradient: Gradient {
            GradientStop { position: 0; color: "transparent" }
            GradientStop { position: 1; color: Theme.alpha(window.contactTone, 0.18) }
          }

          NumberAnimation on y {
            loops: Animation.Infinite
            running: Calls.active
            from: -sweep.height
            to: portrait.height
            duration: 1700
          }
        }

        // Johnny calls from where no call should come from
        Text {
          anchors.top: parent.top
          anchors.topMargin: 8
          anchors.horizontalCenter: parent.horizontalCenter
          visible: window.glitchy
          text: "BLACKWALL INTERFERENCE"
          color: Theme.danger
          font.family: Theme.fontMono
          font.pixelSize: 9
          font.weight: Font.Bold
          font.letterSpacing: 2
          opacity: jitterTimer.flip ? 1 : 0.3
        }

        Timer {
          id: jitterTimer
          property bool flip: false
          interval: 90
          repeat: true
          running: window.glitchy && Calls.active
          onTriggered: {
            flip = Math.random() > 0.5
            jitter.x = Math.random() < 0.18 ? (Math.random() - 0.5) * 14 : 0
          }
          onRunningChanged: if (!running) jitter.x = 0
        }
      }

      // the voice of whoever talks, bouncing while the subtitle types
      Row {
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.bottom: label.top
        anchors.bottomMargin: 6
        height: 26
        spacing: 2
        visible: window.phase === "connected"

        Repeater {
          model: 14
          delegate: Rectangle {
            required property int index
            readonly property bool talking: subtitle.typing
            anchors.bottom: parent.bottom
            width: 3
            height: talking ? 4 + Math.abs(Math.sin(voice.t * (3 + index % 5) + index)) * 22 : 3
            color: Calls.speaker === "V" ? Theme.warn : window.contactTone
            opacity: 0.9
          }
        }
      }

      Rectangle {
        id: label
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 12
        height: 22
        color: Theme.alpha(Theme.bg, 0.85)
        border.color: window.phase === "connected" ? window.contactTone : window.frameTone
        border.width: 1

        Text {
          anchors.verticalCenter: parent.verticalCenter
          x: 8
          text: window.footer
          color: window.phase === "ended" ? Theme.danger : window.nameTone
          font.family: Theme.fontMono
          font.pixelSize: 10
          font.weight: Font.Bold
          font.letterSpacing: 1
        }
      }
    }

    QtObject {
      id: voice
      property real t: 0
      property NumberAnimation run: NumberAnimation {
        target: voice
        property: "t"
        from: 0
        to: 1000
        duration: 1000000
        loops: Animation.Infinite
        running: subtitle.typing
      }
    }

    // ------------------------------------------------ subtitles, like the game's

    Item {
      id: subtitle
      x: 0
      y: frame.y + frame.height + 10
      width: parent.width
      height: Calls.line !== "" ? lineText.implicitHeight + 40 : 0
      visible: height > 0

      property int shown: 0
      readonly property bool typing: shown < Calls.line.length

      Connections {
        target: Calls
        function onLineChanged() {
          typer.stop()
          subtitle.shown = 0
          typer.to = Calls.line.length
          typer.duration = Calls.line.length * 22
          typer.start()
        }
      }

      NumberAnimation {
        id: typer
        target: subtitle
        property: "shown"
        from: 0
      }

      Plate {
        anchors.fill: parent
        cut: 10
        cutBL: 4
        fill: Theme.alpha(Theme.bg, 0.9)
        stroke: Theme.alpha(Calls.speaker === "V" ? Theme.warn : window.contactTone, 0.6)
      }

      Text {
        x: 14
        y: 8
        text: Calls.speaker
        color: Calls.speaker === "V" ? Theme.warn : window.contactTone
        font.family: Theme.fontUi
        font.pixelSize: 13
        font.weight: Font.Bold
        font.letterSpacing: 1.5
      }

      Text {
        id: lineText
        x: 14
        y: 26
        width: parent.width - 28
        text: Calls.line.slice(0, subtitle.shown)
        color: Theme.fg
        wrapMode: Text.WordWrap
        font.family: Theme.fontUi
        font.pixelSize: 16
        font.weight: Font.DemiBold
      }

      // click to skip the wait
      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          if (subtitle.typing) {
            typer.stop()
            subtitle.shown = Calls.line.length
          } else Calls.skip()
        }
      }
    }

    // the dialogue choices, numbered and yellow like the game's
    Column {
      id: choiceList
      x: 0
      y: subtitle.y + subtitle.height + (subtitle.visible ? 6 : 0)
      width: parent.width
      spacing: 4
      visible: Calls.choices.length > 0

      Repeater {
        model: Calls.choices
        delegate: Item {
          id: option
          required property var modelData
          required property int index
          width: choiceList.width
          height: optionText.implicitHeight + 14

          Rectangle {
            anchors.fill: parent
            color: Theme.alpha(Theme.mix(Theme.bg, Theme.warn, optionArea.containsMouse ? 0.24 : 0.08), 0.93)
            border.color: Theme.alpha(Theme.warn, optionArea.containsMouse ? 0.9 : 0.3)
            border.width: 1
          }

          Rectangle {
            visible: optionArea.containsMouse
            width: 3
            height: parent.height
            color: Theme.warn
          }

          Text {
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            text: "[" + (option.index + 1) + "]"
            color: Theme.warn
            font.family: Theme.fontMono
            font.pixelSize: 12
            font.weight: Font.Bold
          }

          Text {
            id: optionText
            x: 44
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 56
            text: option.modelData
            color: optionArea.containsMouse ? Theme.fg : Theme.warn
            wrapMode: Text.WordWrap
            font.family: Theme.fontUi
            font.pixelSize: 15
            font.weight: Font.Bold
          }

          Clickable {
            id: optionArea
            anchors.fill: parent
            onClicked: Calls.choose(option.index)
          }
        }
      }
    }

    Row {
      id: buttons
      x: window.sim ? 0 : frame.x
      y: (choiceList.visible ? choiceList.y + choiceList.height : (subtitle.visible ? subtitle.y + subtitle.height : frame.y + frame.height)) + 10
      spacing: 6
      visible: Calls.active && window.phase !== "ended"

      // a real call: the app's own actions
      Repeater {
        model: window.sim ? [] : Calls.actions
        delegate: Action {
          required property var modelData
          label: window.actionLabel(modelData)
          tone: window.actionTone(label)
          onTriggered: Calls.answer(modelData)
        }
      }

      Action {
        visible: window.sim && window.phase === "ringing"
        label: "ANSWER"
        tone: Theme.ok
        onTriggered: Calls.connect()
      }

      Action {
        visible: window.sim && window.phase === "ringing"
        label: "DECLINE"
        tone: Theme.danger
        onTriggered: Calls.decline()
      }

      Action {
        visible: window.sim && (window.phase === "connected" || window.phase === "dialing")
        label: window.phase === "dialing" ? "CANCEL" : "HANG UP"
        tone: Theme.danger
        onTriggered: window.phase === "dialing" ? Calls.stop() : Calls.hangUp()
      }

      // silences the deck; the app keeps ringing in its own window
      Action {
        visible: !window.sim
        label: "IGNORE"
        tone: Theme.subtle
        onTriggered: Calls.stop()
      }
    }
  }
}
