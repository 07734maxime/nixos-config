import QtQuick
import Quickshell
import Quickshell.Wayland
import "../services/Contacts.js" as Contacts
import qs.services
import qs.components

// V's phone, top left like the game: the contacts of the holocall simulator.
// Pick one to call them. Opened from the quickhack MENU tab or
// `quickshell -c cyberdeck ipc call call contacts`.
Overlay {
  id: window

  screen: Hud.screenNamed(Hud.phoneOutput)
  open: Hud.phoneOpen
  dim: Settings.dim * 0.5
  WlrLayershell.namespace: "cyberdeck-phone"
  blurItem: panel
  blurPad: backdrop.pad
  onDismissed: Hud.phoneOpen = false

  property int selected: 0

  function call(index) {
    Hud.phoneOpen = false
    Calls.dial(Contacts.contacts[index].id)
  }

  Item {
    id: panel
    x: 16 - (1 - window.reveal) * 40
    y: 6
    width: 380
    height: column.height
    opacity: Math.min(1, window.reveal * 2)

    Backdrop { id: backdrop }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.AllButtons
    }

    Item {
      anchors.fill: parent
      focus: true
      Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Down) window.selected = Math.min(Contacts.contacts.length - 1, window.selected + 1)
        else if (event.key === Qt.Key_Up) window.selected = Math.max(0, window.selected - 1)
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) window.call(window.selected)
        else if (event.key === Qt.Key_Escape) window.dismissed()
        else return
        Sounds.play("hover")
        event.accepted = true
      }
    }

    Column {
      id: column
      width: parent.width
      spacing: 6

      Header {
        width: parent.width
        height: 30
        label: "PHONE // CONTACTS"
        index: Contacts.contacts.length + " ENTRIES"
        icon: "phone"
      }

      Repeater {
        model: Contacts.contacts.length
        delegate: Item {
          id: row
          required property int index
          readonly property var contact: Contacts.contacts[index]
          readonly property color tone: Theme[contact.tone]
          readonly property bool picked: index === window.selected
          width: column.width
          height: 52

          Plate {
            anchors.fill: parent
            cut: 10
            cutBL: 4
            fill: Theme.alpha(row.tone, row.picked ? 0.16 : 0.04)
            stroke: row.picked ? row.tone : Theme.alpha(row.tone, 0.25)
          }

          // the contact's badge: monogram in a chamfered square
          Item {
            x: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 38
            height: 38

            Plate {
              anchors.fill: parent
              cut: 9
              fill: row.picked ? row.tone : Theme.alpha(row.tone, 0.14)
              stroke: row.tone
            }

            Text {
              anchors.centerIn: parent
              text: row.contact.monogram
              color: row.picked ? Theme.bg : row.tone
              font.family: Theme.fontUi
              font.pixelSize: 16
              font.weight: Font.Bold
            }
          }

          Column {
            x: 58
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 58 - 50

            Text {
              text: row.contact.glitch ? "UNKNOWN // " + row.contact.name : row.contact.name
              color: row.picked ? Theme.fg : Theme.subtle
              elide: Text.ElideRight
              width: parent.width
              font.family: Theme.fontUi
              font.pixelSize: 16
              font.weight: Font.Bold
              font.letterSpacing: 1
            }

            Text {
              text: row.contact.role
              color: Theme.alpha(row.tone, 0.8)
              font.family: Theme.fontMono
              font.pixelSize: 9
            }
          }

          Icon {
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            width: 18
            height: 18
            name: "phone"
            color: row.picked ? row.tone : Theme.alpha(row.tone, 0.4)
          }

          Clickable {
            anchors.fill: parent
            onEntered: window.selected = row.index
            onClicked: window.call(row.index)
          }
        }
      }

      Row {
        x: 4
        height: 28
        spacing: 10

        Repeater {
          model: [{ key: "↑↓", label: "SELECT" }, { key: "↵", label: "CALL" }, { key: "ESC", label: "CLOSE" }]
          delegate: Row {
            required property var modelData
            anchors.verticalCenter: parent.verticalCenter
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
