import QtQuick
import qs.services

// Quick toggle of the control center, drawn like a cyberware slot of the
// ripperdoc screen: the implant icon in its socket, its name under it and a
// charge strip that lights up while it runs.
Item {
  id: tile

  property string icon: "dot"
  property string label: ""
  property string hint: ""
  property bool active: false
  property color tone: Theme.primary

  signal clicked()

  readonly property bool hot: area.containsMouse
  readonly property color ink: active ? tone : (hot ? Theme.mix(tone, Theme.white, 0.2) : Theme.alpha(tone, 0.8))

  implicitWidth: 100
  implicitHeight: 78

  // the socket
  Item {
    id: socket
    width: parent.width
    height: 44

    Plate {
      anchors.fill: parent
      cut: 9
      fill: Theme.alpha(tile.tone, tile.active ? 0.2 : (tile.hot ? 0.12 : 0.04))
      stroke: tile.active || tile.hot ? tile.tone : Theme.alpha(tile.tone, 0.35)
      Behavior on fill { ColorAnimation { duration: 140 } }
    }

    Hatch {
      anchors.fill: parent
      anchors.margins: 3
      anchors.rightMargin: 12
      visible: tile.active && Settings.hudDecor
      tone: Theme.alpha(tile.tone, 0.16)
      gap: 5
      thickness: 1
    }

    // filled notch, the "equipped" marker
    Rectangle {
      x: 3
      y: 3
      width: 5
      height: 5
      color: tile.active ? tile.tone : Theme.alpha(tile.tone, 0.3)
    }

    Icon {
      anchors.centerIn: parent
      width: 20
      height: 20
      name: tile.icon
      color: tile.ink
      weight: 1.8
    }

    // charge strip
    Row {
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 3
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 2
      Repeater {
        model: 4
        delegate: Rectangle {
          width: (socket.width - 14) / 4 - 2
          height: 2
          color: tile.active ? tile.tone : Theme.alpha(tile.tone, 0.18)
        }
      }
    }
  }

  Column {
    anchors.top: socket.bottom
    anchors.topMargin: 4
    width: parent.width
    spacing: -2

    Text {
      width: parent.width
      text: tile.label
      color: tile.active ? tile.tone : Theme.fg
      horizontalAlignment: Text.AlignHCenter
      fontSizeMode: Text.HorizontalFit
      minimumPixelSize: 9
      font.family: Theme.fontUi
      font.pixelSize: 13
      font.weight: Font.Bold
      font.letterSpacing: 0.5
    }

    Text {
      width: parent.width
      text: tile.hint
      color: Theme.subtle
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      font.family: Theme.fontMono
      font.pixelSize: 8
    }
  }

  Clickable {
    id: area
    anchors.fill: parent
    onClicked: tile.clicked()
  }
}
