import QtQuick
import qs.services

// Diagonal warning stripes, like the hazard strips framing the game menus.
Item {
  id: hatch

  property color tone: Theme.primary
  property real gap: 6
  property real thickness: 2

  clip: true

  Repeater {
    model: Math.max(0, Math.ceil((hatch.width + hatch.height) / hatch.gap) + 1)
    delegate: Rectangle {
      required property int index
      x: index * hatch.gap - hatch.height
      y: -hatch.thickness
      width: hatch.thickness
      height: (hatch.height + 2 * hatch.thickness) * Math.SQRT2
      color: hatch.tone
      transformOrigin: Item.TopLeft
      rotation: -45
    }
  }
}
