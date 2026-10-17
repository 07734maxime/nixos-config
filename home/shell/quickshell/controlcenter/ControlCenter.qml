import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.components

Overlay {
  id: window

  screen: Hud.screenNamed(Hud.ccOutput)
  open: Hud.ccOpen
  WlrLayershell.namespace: "cyberdeck-cc"
  blurItem: panel
  blurPad: backdrop.pad
  onDismissed: Hud.ccOpen = false

  Item {
    id: panel
    // a drawer down the whole edge, sliding in from its side
    readonly property real slide: (1 - window.reveal) * (width + 24)
    x: Settings.ccLeft ? 12 - slide : parent.width - width - 12 + slide
    y: 6
    width: Math.min(680, parent.width - 24)
    height: parent.height - 12
    opacity: Math.min(1, window.reveal * 2)

    // swallow clicks so the background does not close the panel
    Backdrop { id: backdrop }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.AllButtons
    }

    Flickable {
      anchors.fill: parent
      contentHeight: content.implicitHeight
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      interactive: contentHeight > height

      CcContent {
        id: content
        width: panel.width
        reveal: window.reveal
        available: panel.height
      }
    }

    // scan line sweeping down while the panel opens
    Rectangle {
      width: parent.width
      height: 2
      y: parent.height * window.reveal
      color: Theme.primary
      opacity: window.reveal < 1 && Settings.hudDecor ? 0.8 : 0
    }
  }
}
