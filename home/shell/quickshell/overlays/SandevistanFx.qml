import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.components

// What the Sandevistan does to the optics, on every output: a shockwave when
// it engages, the world tinted and split at the edges while time crawls, the
// charge draining at the top. Purely visual: clicks go through.
Scope {
  id: fx

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: window

      required property var modelData

      readonly property color tone: Theme.ok
      readonly property color split: Theme.secondary
      property real level: Sandevistan.active ? 1 : 0

      Behavior on level { NumberAnimation { duration: Sandevistan.active ? 220 : 900; easing.type: Easing.OutCubic } }

      screen: modelData
      visible: level > 0 && !Lock.locked
      color: "transparent"
      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }
      exclusionMode: ExclusionMode.Ignore
      mask: Region {}
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "cyberdeck-sandevistan"

      Connections {
        target: Sandevistan
        function onEngaged() {
          wave.restart()
        }
      }

      // the world, tinted
      Rectangle {
        anchors.fill: parent
        color: Theme.alpha(window.tone, 0.07 * window.level)
      }

      // chromatic split: the edges burn in two colours
      Rectangle {
        anchors.fill: parent
        opacity: window.level
        gradient: Gradient {
          orientation: Gradient.Horizontal
          GradientStop { position: 0; color: Theme.alpha(window.split, 0.28) }
          GradientStop { position: 0.16; color: "transparent" }
          GradientStop { position: 0.84; color: "transparent" }
          GradientStop { position: 1; color: Theme.alpha(window.tone, 0.28) }
        }
      }

      Rectangle {
        anchors.fill: parent
        opacity: window.level
        gradient: Gradient {
          GradientStop { position: 0; color: Theme.alpha(window.tone, 0.22) }
          GradientStop { position: 0.14; color: "transparent" }
          GradientStop { position: 0.86; color: "transparent" }
          GradientStop { position: 1; color: Theme.alpha(window.split, 0.22) }
        }
      }

      // speed lines streaking along the sides
      Repeater {
        model: 18
        delegate: Rectangle {
          id: streak
          required property int index
          readonly property bool fromLeft: index % 2 === 0
          readonly property real lane: (index * 0.137 + 0.05) % 1
          property real t: 0
          y: window.height * lane
          x: fromLeft ? -width + t * (window.width * 0.35) : window.width - t * (window.width * 0.35)
          width: 120 + (index % 5) * 60
          height: 1 + index % 2
          opacity: window.level * (1 - t) * 0.6
          gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: "transparent" }
            GradientStop { position: 0.5; color: streak.fromLeft ? window.split : window.tone }
            GradientStop { position: 1; color: "transparent" }
          }

          NumberAnimation on t {
            running: Sandevistan.active && window.visible
            loops: Animation.Infinite
            from: 0
            to: 1
            duration: 900 + (streak.index % 6) * 260
          }
        }
      }

      // scanlines of the slowed world
      Column {
        anchors.fill: parent
        opacity: 0.5 * window.level
        spacing: 3
        Repeater {
          model: Math.max(0, Math.ceil(window.height / 4))
          delegate: Rectangle { width: window.width; height: 1; color: Theme.alpha(window.tone, 0.06) }
        }
      }

      // the shockwave when it engages
      Item {
        id: shock
        anchors.centerIn: parent
        width: Math.hypot(window.width, window.height)
        height: width
        property real r: 0

        Rectangle {
          anchors.centerIn: parent
          width: shock.width * shock.r
          height: width
          radius: width / 2
          color: "transparent"
          border.color: window.tone
          border.width: 3 + 30 * (1 - shock.r)
          opacity: (1 - shock.r) * 0.8
        }

        Rectangle {
          anchors.centerIn: parent
          width: shock.width * Math.max(0, shock.r - 0.08)
          height: width
          radius: width / 2
          color: "transparent"
          border.color: window.split
          border.width: 2
          opacity: (1 - shock.r) * 0.6
        }

        NumberAnimation {
          id: wave
          target: shock
          property: "r"
          from: 0
          to: 1
          duration: 750
          easing.type: Easing.OutCubic
        }
      }

      // the HUD of the implant
      Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 70
        spacing: 6
        opacity: window.level

        Row {
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: 12

          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 10
            height: 10
            rotation: 45
            color: window.tone
          }

          GlitchText {
            anchors.verticalCenter: parent.verticalCenter
            text: "SANDEVISTAN"
            color: window.tone
            font.family: Theme.fontUi
            font.pixelSize: 34
            font.weight: Font.Bold
            font.letterSpacing: 6
            minGap: 400
            maxGap: 1200
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "x" + (1 / Sandevistan.dilation).toFixed(2)
            color: window.split
            font.family: Theme.fontMono
            font.pixelSize: 16
            font.weight: Font.Bold
          }
        }

        Slider {
          anchors.horizontalCenter: parent.horizontalCenter
          width: 360
          height: 6
          segments: 40
          value: Sandevistan.charge
          tone: window.tone
          enabled: false
        }

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: "MILITECH \"APOGEE\" // TIME DILATION ACTIVE // " + (Sandevistan.charge * Sandevistan.duration / 1000).toFixed(1) + "S"
          color: Theme.alpha(window.tone, 0.85)
          font.family: Theme.fontMono
          font.pixelSize: 10
          font.weight: Font.Bold
          font.letterSpacing: 2
        }
      }

      Brackets {
        anchors.fill: parent
        anchors.margins: 24
        len: 40
        thickness: 3
        tone: window.tone
        opacity: window.level * 0.8
      }
    }
  }
}
