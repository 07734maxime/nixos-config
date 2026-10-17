import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.bar
import qs.controlcenter
import qs.menus
import qs.overlays

// Cyberdeck: a Cyberpunk 2077 desktop shell for niri.
ShellRoot {
  id: shell

  Variants {
    model: Quickshell.screens
    Bar {}
  }

  Quickhack { id: quickhack }
  ControlCenter {}
  OsMenu {}
  WallMenu {}
  SettingsMenu {}
  PackageMenu { id: packages }
  PhoneMenu {}
  Scanner {}
  SandevistanFx {}
  Screensaver { id: screensaver }
  Breach {}
  NotificationPopups {}
  Holocall {}
  Osd {}
  Reboot {}
  Boot {}

  Connections {
    target: Hud
    function onQuickhackRequested() { quickhack.toggle() }
    function onCaffeineChanged() {
      // no idle daemon, no lock and no monitor sleep while the adrenaline runs
      Quickshell.execDetached(["systemctl", "--user", Hud.caffeine ? "stop" : "start", "cyberdeck-idle.service"])
    }
  }

  // singletons are lazy: touch the ones that must exist from the start
  Component.onCompleted: {
    Notifs.count
    Lock.locked
    Blackwall.integrity
    Sounds.loop
    Settings.barHeight
    // resets the slow motion a dead shell may have left in niri
    Sandevistan.active
  }

  IpcHandler {
    target: "quickhack"
    function toggle(): void { quickhack.toggle() }
    function open(): void { quickhack.show() }
    function close(): void { quickhack.close() }
  }

  IpcHandler {
    target: "cc"
    function toggle(): void { Hud.toggleCc("") }
    function close(): void { Hud.ccOpen = false }
  }

  IpcHandler {
    target: "os"
    function open(): void { Hud.toggleOs("") }
    function install(id: string): void { Theme.switchTo(id) }
    function current(): string { return Theme.os }
  }

  IpcHandler {
    target: "wallpaper"
    function open(): void { Hud.toggleWall("") }
    function set(path: string): void { Theme.setWallpaper(path) }
    function current(): string { return Theme.wallpaper }
  }

  IpcHandler {
    target: "settings"
    function toggle(): void { Hud.toggleSettings("") }
    function open(): void { if (!Hud.settingsOpen) Hud.toggleSettings("") }
    function close(): void { Hud.settingsOpen = false }
  }

  IpcHandler {
    target: "packages"
    function toggle(): void { Hud.togglePkg("") }
    function open(): void { if (!Hud.pkgOpen) Hud.togglePkg("") }
    function close(): void { Hud.pkgOpen = false }
    // quickshell -c cyberdeck ipc call packages search obsidian
    function search(query: string): void {
      if (!Hud.pkgOpen) Hud.togglePkg("")
      packages.prefill(query)
    }
  }

  IpcHandler {
    target: "sandevistan"
    function activate(): void { Sandevistan.activate() }
  }

  IpcHandler {
    target: "scanner"
    function toggle(): void { Hud.toggleScan("") }
  }

  IpcHandler {
    target: "screensaver"
    function preview(): void { screensaver.preview() }
  }

  IpcHandler {
    target: "breach"
    function open(): void { Hud.openBreach("") }
  }

  IpcHandler {
    target: "sounds"
    function rescan(): void { Sounds.rescan() }
  }

  IpcHandler {
    target: "call"
    // quickshell -c cyberdeck ipc call call test "Jackie Welles"
    function test(name: string): void { Calls.test(name) }
    function stop(): void { Calls.stop() }
    // the holocall simulator: a contact id (jackie, judy, panam, rogue, regina,
    // wakako, viktor, delamain, misty, johnny) calls in, or gets called
    function incoming(id: string): void { Calls.incoming(id) }
    function dial(id: string): void { Calls.dial(id) }
    function random(): void { Calls.incoming(Calls.randomContact().id) }
    function answer(): void { Calls.connect() }
    function choose(index: int): void { Calls.choose(index - 1) }
    function contacts(): void { Hud.togglePhone("") }
  }

  IpcHandler {
    target: "lock"
    function lock(): void { Lock.lock() }
    function isLocked(): bool { return Lock.locked }
  }

  IpcHandler {
    target: "blackwall"
    function whisper(): void { Blackwall.speak("") }
  }

  IpcHandler {
    target: "theme"
    function reload(): void { Theme.reload() }
  }

  IpcHandler {
    target: "dnd"
    function toggle(): void { Hud.dnd = !Hud.dnd }
  }
}
