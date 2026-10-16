import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
  id: root

  property int selectedTab: 0
  property int selectedHack: 0
  property string openedOnOutput: ""
  property var activeScreen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
  property var tabs: [
    { label: "APP", hacks: [
        { name: "VISUAL STUDIO CODE", detail: "CODE EDITOR", command: ["code"], cost: "10", icon: "◆" },
        { name: "FIREFOX", detail: "WEB BROWSER", command: ["firefox"], cost: "4", icon: "◈" },
        { name: "KITTY", detail: "TERMINAL", command: ["kitty"], cost: "5", icon: "⌁" },
        { name: "DISCORD", detail: "COMMS", command: ["discord"], cost: "3", icon: "✦" },
        { name: "YAZI", detail: "FILE MANAGER", command: ["kitty", "-e", "yazi"], cost: "4", icon: "◎" },
        { name: "PAVUCONTROL", detail: "AUDIO MIXER", command: ["pavucontrol"], cost: "3", icon: "≋" },
        { name: "NEOVIM", detail: "EDITOR", command: ["kitty", "-e", "nvim"], cost: "5", icon: "✧" },
        { name: "SHELL", detail: "COMMAND LINE", command: ["kitty", "-e", "bash"], cost: "6", icon: "▣" }
      ] },
    { label: "SYSTEM", hacks: [
        { name: "AUDIO MIXER", detail: "PAVUCONTROL", command: ["pavucontrol"], cost: "4", icon: "≋" },
        { name: "FILE MANAGER", detail: "YAZI", command: ["kitty", "-e", "yazi"], cost: "4", icon: "◎" },
        { name: "LOCK SCREEN", detail: "SWAYLOCK", command: ["swaylock"], cost: "8", icon: "◉" }
      ] },
    { label: "POWER", hacks: [
        { name: "LOCK SCREEN", detail: "SWAYLOCK", command: ["swaylock"], cost: "8", icon: "◉" },
        { name: "POWER OFF", detail: "SYSTEM", command: ["systemctl", "poweroff"], cost: "12", locked: true, icon: "×" }
      ] }
  ]

  function closeMenu() {
    panel.visible = false
    Qt.quit()
  }

  function launch() {
    const hack = tabs[selectedTab].hacks[selectedHack]
    if (!hack.locked) {
      Quickshell.execDetached(hack.command)
      closeMenu()
    }
  }

  function moveSelection(delta) {
    selectedHack = Math.max(0, Math.min(tabs[selectedTab].hacks.length - 1, selectedHack + delta))
    const targetY = selectedHack * 86
    hackList.contentY = Math.max(0, Math.min(hackList.contentHeight - hackList.height, targetY - 260))
  }

  function setOutputFromJson(text) {
    try {
      const outputName = JSON.parse(text).name
      if (openedOnOutput === "") {
        openedOnOutput = outputName
        for (const screen of Quickshell.screens) {
          if (screen.name === outputName) {
            activeScreen = screen
            break
          }
        }
      } else if (outputName !== openedOnOutput) {
        closeMenu()
      }
    } catch (error) {
      console.log("Unable to read focused output: " + error)
    }
  }

  Process {
    id: focusedOutput
    command: ["niri", "msg", "-j", "focused-output"]
    stdout: StdioCollector {
      onStreamFinished: root.setOutputFromJson(this.text)
    }
  }

  Timer {
    interval: 250
    running: panel.visible
    repeat: true
    onTriggered: focusedOutput.exec(focusedOutput.command)
  }

  PanelWindow {
    id: panel
    visible: true
    screen: root.activeScreen
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    Item {
      id: stage
      width: 680
      height: 860
      anchors.left: parent.left
      anchors.leftMargin: 42
      anchors.verticalCenter: parent.verticalCenter
      focus: true

      Column {
        id: header
        width: 600
        spacing: 12

        Row {
          width: parent.width
          height: 42
          spacing: 6

          Repeater {
            model: tabs
            delegate: Rectangle {
              required property var modelData
              required property int index
              width: (parent.width - 12) / tabs.length
              height: 42
              color: index === selectedTab ? "#16aaa8" : "#092a31cc"
              border.color: index === selectedTab ? "#a0ffff" : "#16848a"
              border.width: index === selectedTab ? 2 : 1

              Text {
                anchors.centerIn: parent
                text: modelData.label
                color: index === selectedTab ? "#061016" : "#79e8e7"
                font.family: "JetBrains Mono"
                font.pixelSize: 11
                font.bold: true
              }

              MouseArea {
                anchors.fill: parent
                onClicked: {
                  selectedTab = index
                  selectedHack = 0
                  hackList.contentY = 0
                }
              }
            }
          }
        }

        Rectangle { width: 600; height: 4; color: "#ff3f3f" }

        Text {
          text: tabs[selectedTab].label + "  /  READY"
          color: "#ff6b63"
          font.family: "JetBrains Mono"
          font.pixelSize: 12
          font.bold: true
        }
      }

      Flickable {
        id: hackList
        width: 650
        height: 700
        anchors.top: header.bottom
        anchors.topMargin: 18
        contentWidth: width
        contentHeight: hackColumn.height
        boundsBehavior: Flickable.StopAtBounds
        interactive: true
        clip: false

        Column {
          id: hackColumn
          width: hackList.width
          spacing: 10

          Repeater {
            model: tabs[selectedTab].hacks
            delegate: Rectangle {
              required property var modelData
              required property int index
              property bool hovered: false
              property bool keyboardSelected: index === selectedHack
              property int cascadeX: Math.max(0, 18 - index * 14)
              property bool raised: hovered || keyboardSelected
              x: cascadeX + (raised ? 20 : 0)
              width: 610
              height: 76
              color: "transparent"

              Behavior on x {
                NumberAnimation {
                  duration: 180
                  easing.type: Easing.OutCubic
                }
              }

              Rectangle { x: 1; y: 1; width: parent.width - 2; height: parent.height - 2; color: modelData.locked ? "#260f14e8" : (raised ? "#102c35ee" : "#07131bea") }
              Rectangle { x: 0; y: 0; width: 22; height: 9; color: "#061016" }
              Rectangle { x: 0; y: height - 9; width: 22; height: 9; color: "#061016" }
              Rectangle { anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom; width: 4; color: modelData.locked ? "#e34250" : "#24dce4" }

              Row {
                anchors.fill: parent
                anchors.leftMargin: 28
                anchors.rightMargin: 12
                spacing: 10

                Column {
                  width: parent.width - 185
                  anchors.verticalCenter: parent.verticalCenter
                  Text {
                    text: modelData.name
                    color: modelData.locked ? "#ff6c78" : "#5ceef4"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 20
                    font.bold: true
                    elide: Text.ElideRight
                  }

                  Rectangle {
                    width: 72
                    height: 25
                    color: "#082229"
                    border.color: modelData.locked ? "#a73543" : "#19a9b5"
                    border.width: 1

                    Text {
                      anchors.centerIn: parent
                      text: modelData.locked ? "LOCKED" : "READY"
                      color: modelData.locked ? "#ff6875" : "#36e8ed"
                      font.family: "JetBrains Mono"
                      font.pixelSize: 11
                      font.bold: true
                    }
                  }
                }

                Text {
                  text: "↓" + modelData.cost + "  ▐"
                  color: modelData.locked ? "#ff6875" : "#57f7fa"
                  font.family: "JetBrains Mono"
                  font.pixelSize: 24
                  font.bold: true
                  anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                  width: 58
                  height: 58
                  color: "#071a20"
                  border.color: modelData.locked ? "#a73543" : "#1aa5b1"
                  border.width: 1
                  anchors.verticalCenter: parent.verticalCenter

                  Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    color: modelData.locked ? "#ff6875" : "#63f7f5"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 28
                    font.bold: true
                  }
                }
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.hovered = true
                onExited: parent.hovered = false
                onClicked: {
                  selectedHack = index
                  if (!modelData.locked) launch()
                }
              }
            }
          }
        }

        WheelHandler {
          property: "contentY"
          onWheel: (event) => {
            hackList.contentY = Math.max(0, Math.min(hackList.contentHeight - hackList.height, hackList.contentY - event.angleDelta.y / 2))
            event.accepted = true
          }
        }

        ScrollBar.vertical: ScrollBar {
          policy: hackList.contentHeight > hackList.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        }
      }

      Text {
        anchors.top: hackList.bottom
        anchors.topMargin: 10
        text: "MOUSE WHEEL  SCROLL     TAB  SWITCH     ENTER  EXECUTE     ESC  EXIT"
        color: "#4f9ca1"
        font.family: "JetBrains Mono"
        font.pixelSize: 9
      }

      Keys.onEscapePressed: root.closeMenu()
      Keys.onReturnPressed: root.launch()
      Keys.onUpPressed: root.moveSelection(-1)
      Keys.onDownPressed: root.moveSelection(1)
      Keys.onTabPressed: { selectedTab = (selectedTab + 1) % tabs.length; selectedHack = 0; hackList.contentY = 0 }
      Keys.onLeftPressed: { selectedTab = Math.max(0, selectedTab - 1); selectedHack = 0; hackList.contentY = 0 }
      Keys.onRightPressed: { selectedTab = Math.min(tabs.length - 1, selectedTab + 1); selectedHack = 0; hackList.contentY = 0 }
      Component.onCompleted: {
        forceActiveFocus()
        focusedOutput.exec(focusedOutput.command)
      }
    }
  }
}
