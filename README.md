# NixOS Configuration

My personal NixOS configuration, managed with flakes and
Home Manager. This is built around the Niri compositor and is
configured for NVIDIA graphics, and two 1920x1080
180 Hz DisplayPort monitors.

The whole desktop is a Cyberpunk 2077 "cyberdeck": a Quickshell shell, a
wallpaper driven colour scheme applied by Stylix and recoloured live, a
matching cursor, terminal, browser, lockscreen and login screen.

## What I've added for now

- NixOS unstable with flakes enabled
- Niri compositor
- Home Manager integrated into the system configuration
- NVIDIA drivers
- PipeWire audio
- Yazi as the XDG portal file chooser
- Unfree packages enabled
- **Cyberdeck shell** (Quickshell, replaces Waybar and Mako)
  - top bar per monitor: quickhack button, niri workspaces, focused window,
    clock and weather, eddies, breach protocol, OS selector, wallpaper bank,
    package broker, tray with themed menus, volume, network, notifications,
    control center
  - control center: a full-height drawer built from the game menus. The
    character sheet (level from the breaches won, street cred from the
    eddies), cyberware slots for the quick toggles, braindance media
    (MPRIS), sonic matrix (output / input / app volumes), weather, calendar,
    deck status (CPU / RAM / disk / network and a CPU trace) and the message
    log. Every module can be hidden, the drawer can sit on either side
  - quickhack launcher (`Mod+D`): applications, and a MENU tab with every
    system action of the deck. RAM is rolled between max - 10 and max on
    every opening; hacks that cost more turn red and **OVERCLOCK**
  - breach protocol mini game (the code matrix from the game) with
    eurodollar rewards
  - OS selector (`Mod+O`) and wallpaper bank (`Mod+W`): picking one
    recolours the whole deck live
  - **Shell Settings** (MENU tab, or the SYS.CFG button of the control
    center): a drawer on the left with the rebuild folder, bar (height,
    position, 24h / 12h clock, seconds, eddies and breach buttons), panels
    (frosted glass, shadows, opacity, dim, animation speed, HUD decor),
    control center (side, modules), system (notification timeout, Blackwall
    whispers, boot sequence, random holocalls, braindance screensaver),
    weather location, °C / °F and sounds. Saved live in
    `~/.local/state/cyberdeck/settings.json`
  - **Package broker** (the box of the bar, or the MENU tab): searches
    nixpkgs with autocompletion, from the package index nixos.org publishes
    for the channel, and adds programs to `home/packages.json`. Names
    nixpkgs does not know are refused. ENGRAVE installs them
  - **Holocall simulator**: Jackie, Judy, Panam, Rogue, Regina, Wakako,
    Viktor, Delamain, Misty and Johnny (through Blackwall interference) call
    in now and then, or get called from the PHONE. Answer, follow the
    subtitles, pick your lines; they talk about the time, the weather, your
    eddies, your CPU load or your uptime. A missed call leaves a text. Real
    calls of Discord and the other messengers ring the same holocall
  - **Sandevistan** (`Mod+S`, a slot of the control center): eight seconds
    of slow motion. niri animates four times slower (a live KDL include),
    the optics tint and split at the edges, then the implant cools down
  - **Kiroshi scanner** (`Mod+Tab`): every window on screen gets a target
    frame; hover one to read it like an NPC (process, load, memory, threads,
    threat level) and run quickhacks on it: PING (focus), SHORT CIRCUIT
    (close), SYNAPSE BURNOUT (kill, click twice)
  - **Braindance screensaver**: after a few idle minutes the wallpaper plays
    as a recorded braindance (slow pan, REC timecode, VISUAL / AUDIO /
    THERMAL layers, clock, lines of Night City lore). Never over a playing
    video or ADRENALINE; any input ends it
  - frosted panels: niri blurs the wallpaper behind the control center and
    the menus (ext-background-effect), with a drop shadow and a translucent
    backing that turns near opaque when frosted glass is off
  - a switch restarts the shell when its config changed (Quickshell does not
    see the new store files on its own)
  - notifications, volume OSD, lockscreen with PAM
  - a CRT style power-on sequence on the login screen and on the first
    login of a boot
  - sounds: the UI sounds of the game, city ambience, the Breach Protocol
    drone, V's ringtone (see [Sounds](#sounds))
  - hints of the **Blackwall** everywhere: whispers in the bar, the
    lockscreen, the launcher, the terminal, and a hidden daemon in the
    code matrix that unlocks a seventh OS
- **Colour engine** (`theme/cyberdeck_theme.py`): every "OS" is a colour
  picking algorithm run on the wallpaper. Stylix uses it at build time,
  the bar uses it live, and it writes the live themes of kitty, niri, GTK,
  cava and Firefox
- **Animated wallpapers**: WebM / MP4 videos play through mpvpaper (GPU
  decoded, paused while hidden); their colours come from a still
- **Cyberdeck cursor theme**, generated from SVG (the slim arrowhead of the
  game menus) and tinted with the palette; `cyberdeck-cursor PACK.zip`
  bakes a real Windows cursor pack over it instead
- **Firefox cyberdeck** (`home/apps/firefox`): chamfered dark chrome,
  numbered uppercase tabs, a neon address bar, HUD menus, the new tab and
  about: pages to match, and a netrunner home page (clock, weather, search,
  shortcuts). Colours follow the live OS when Firefox starts
- **Neovim cyberdeck** as the default editor (`home/apps/nvim`): live OS
  palette, netrunner statusline, a quickhack start screen (`Space s`),
  mini.nvim pickers (`Space f`, `Space /`), tree-sitter and nixd / lua_ls /
  qmlls; `Space` shows every key
- Visual Studio Code with Nix IDE and Material Icon Theme
- **Greeter**: Quickshell login screen on greetd (tuigreet fallback)
- Terminal goodies: **zsh** (ghost suggestions, neon syntax highlighting,
  shared history, HUD completion menu, `rebuild` from the Shell Settings
  folder), fzf, zoxide (`z`), eza with icons, bat; kitty on frosted glass
  with a neon cursor trail, slanted numbered tabs and a red glitch bell,
  `qh` quickhacks, Night City fastfetch, a two-line netrunner starship HUD,
  btop, and `chrono` (clock), `braindance` (cava) and `coderain` in the
  colours of the live OS

## Repository Layout

```text
.
├── flake.nix                         # Flake inputs and the hello host
├── theme/
│   ├── os                            # OS (colour algorithm) baked into Stylix
│   ├── wallpaper                     # wallpaper baked into Stylix and the greeter
│   ├── cyberdeck_theme.py            # colour engine (build time + runtime)
│   ├── default.nix                   # palettes, fonts, cursor package
│   └── cursors/                      # Cyberdeck xcursor theme (SVG sources,
│                                     #   official/ for an imported pack)
├── config/
│   ├── configuration.nix             # System-wide NixOS settings
│   ├── stylix.nix                    # Stylix fed with the computed palette
│   ├── greeter.nix                   # greetd + Quickshell greeter on niri
│   ├── greeter/                      # greeter QML
│   └── hardware-configuration.nix    # Machine-generated hardware settings
└── home/
    ├── home.nix                      # Home Manager entry point
    ├── theme.nix                     # Stylix targets, kitty, GTK styling
    ├── terminal.nix                  # zsh, starship, qh, fastfetch, chrono...
    ├── packages.nix                  # user programs
    ├── packages.json                 #   + the ones added by the package broker
    ├── assets/wallpapers/            # the wallpaper bank (images and videos)
    ├── niri/                         # Niri settings, layout, keybindings
    ├── apps/                         # Firefox (+ firefox/ CSS and home page),
    │                                 #   Neovim (+ nvim/ Lua), VS Code, Yazi
    └── shell/                        # the Cyberdeck shell
        ├── default.nix               #   deployment, niri bindings, idle
        ├── tools.nix                 #   cyberdeck-* commands
        ├── tools/                    #   their scripts: engrave, package broker,
        │                             #   sound and cursor importers
        └── quickshell/               #   the QML
            ├── shell.qml             #     root: every window and the IPC
            ├── services/             #     state: theme, settings, audio, calls...
            ├── components/           #     building blocks: plates, chips, icons...
            ├── bar/                  #     the top bar and its tray menu
            ├── controlcenter/        #     the control center
            ├── menus/                #     quickhack, OS, wallpapers, settings,
            │                         #     package broker, phone
            ├── overlays/             #     breach, holocall, notifications, OSD,
            │                         #     lock view, boot, reboot
            └── assets/               #     logos and sounds
```

## Operating systems (colour algorithms)

| OS | Algorithm |
| --- | --- |
| NetWatch Netdriver Mk.5 | faithful scan: the strongest neon signatures of the wallpaper |
| Militech Canto Mk.6 | target lock: analogous palette around the dominant neon |
| Arasaka Mk.4 | corporate: brushed steel and a single blood-red accent |
| Militech "Apogee" Sandevistan | chromatic dilation: neon triad |
| Zetatech Berserk Mk.5 | overheat: everything pushed into the red |
| Tetratronic Rippler Mk.4 | phase inversion: complementary hues |
| ████████ | win a breach through the wall |

Switching OS from the bar (or `Mod+O`, or `qh os <id>`) is live: the shell
morphs, kitty, cava and the niri focus ring are recoloured instantly, GTK
apps and Firefox pick it up on their next launch. Switching wallpaper
(`Mod+W`) works the same way, the palettes of every wallpaper of the flake
being computed at build time. **Engrave into system firmware** (in the OS
menu, or `cyberdeck-engrave`) rebuilds the system so Stylix themes every
other app (VS Code, btop, the TTY...) with the same OS and wallpaper.

Engraving rebuilds **the clone at `dotfiles` in `flake.nix`**
(`/home/hello/.dotfiles` by default) and writes `theme/os` and
`theme/wallpaper` back into it. If the repo lives somewhere else, pick it in
SHELL SETTINGS, change `dotfiles` there (or export `CYBERDECK_REPO`),
otherwise engraving rebuilds an old copy of the config. The engraving
terminal prints the path and the commit it builds from.

## Wallpapers

Drop images (`.jpg`, `.png`, `.webp`) or videos (`.webm`, `.mp4`, `.mkv`,
`.mov`, `.gif`) into `home/assets/wallpapers`. They show up in the wallpaper
bank right away (marked NEW, palette computed on the fly); after `git add`
and a rebuild they are part of the flake with precomputed palettes.
Engraving adds them to git for you.

Videos play through mpvpaper, muted and looped. WebM (AV1 / VP9) or MP4
(H.264) are decoded by the GPU and stay light, a GIF costs far more. Keep
them short, they live in git:

```bash
ffmpeg -i in.mp4 -an -c:v libsvtav1 -crf 35 home/assets/wallpapers/out.webm
```

The corporation logos are the official ones from the game (CD Projekt RED
trademarks), used for this personal rice only.

## First build

New files have to be tracked by git before a flake can see them, and the
`stylix` input gets added to `flake.lock` on the first build:

```bash
git add -A && sudo nixos-rebuild switch --flake ~/.dotfiles#hello
```

The palettes are computed from the wallpaper during evaluation (import from
derivation), so the very first evaluation builds the colour engine.

If the graphical greeter fails to start, a tuigreet in the same colours takes
over automatically; `style = "tuigreet"` in `config/greeter.nix` makes it the
default. Other TTYs (`Ctrl+Alt+F2`) keep a plain login as a last resort.

## Niri Keybindings

| Binding | Action |
| --- | --- |
| `Mod+T` | Open Kitty |
| `Mod+D` | Open the Quickhack launcher |
| `Mod+A` | Toggle the control center |
| `Mod+B` | Breach protocol |
| `Mod+O` | OS selector |
| `Mod+W` | Wallpaper bank |
| `Mod+N` | Toggle do not disturb |
| `Mod+S` | Sandevistan |
| `Mod+Tab` | Kiroshi scanner |
| `Mod+Alt+L` | Lock the session |
| `Mod+Shift+R` | Restart the shell |
| `Mod+Q` | Close the focused window |
| `Mod+H/J/K/L` | Focus left/down/up/right |
| `Mod+Shift+H/J/K/L` | Focus the monitor left/down/up/right |
| `Mod+1` ... `Mod+9` | Focus workspace 1 through 9 |
| `Mod+Ctrl+1` ... `Mod+Ctrl+9` | Move the column to a workspace |
| `Mod+F` | Maximize the column |
| `Mod+Shift+F` | Toggle fullscreen |
| `Mod+C` | Center the column |
| `Mod+R` | Switch column width preset |
| `Mod+Shift+E` | Quit Niri |
| `Mod+Shift+S` | Screenshot |
| `Ctrl+Print` | Screenshot the screen |
| `Alt+Print` | Screenshot the focused window |

In the bar: scroll on the bar to change workspace, scroll on the volume to
change it, right click on the bell for do not disturb, middle click on a
tray icon for its secondary action.

The Cyberdeck bindings (`Mod+D`, `Mod+A`, `Mod+B`, `Mod+O`, `Mod+W`, `Mod+N`,
`Mod+S`, `Mod+Tab`, `Mod+Alt+L`, `Mod+Shift+R`) are declared in `home/shell/default.nix`, next
to the commands they call; the others are in `home/niri/shortcuts.nix`.

Everything else of the shell answers to IPC too, e.g.
`quickshell -c cyberdeck ipc call settings open`, `... packages search obsidian`,
`... call contacts`, `... call incoming johnny`, `... screensaver preview`.

## Commands

| Command | What it does |
| --- | --- |
| `cyberdeck-engrave` | bake the live OS and wallpaper into the system (rebuild) |
| `cyberdeck-pkgs search\|add\|remove NAME` | the package broker, from a terminal |
| `cyberdeck-sounds PACK.zip [--call F] [--breach F] [--message F]` | turn the game's sounds into the deck's events |
| `cyberdeck-cursor PACK.zip` / `--reset` | bake a real cursor pack over the drawn cursors |
| `cyberdeck-theme apply OS` / `wallpaper set W` | the colour engine |
| `qh` | the terminal quickhacks |
| `chrono`, `braindance`, `coderain` | clock, audio visualizer, code rain |

## Sounds

Every sound is a file of `home/shell/quickshell/assets/sounds`, played with
`pw-play`; a file of the same name in `~/.local/share/cyberdeck/sounds`
wins without a rebuild. They come from the game: `cyberdeck-sounds` turns
the "UI Sound Effects" pack (plus V's ringtone, the Breach Protocol
ambience and the text message ping) into the events below. The SOUND tile
of the control center cycles between everything, effects only and muted.

| File | Played when |
| --- | --- |
| `hover.mp3` | the pointer lands on something clickable, or the quickhack selection moves |
| `click.mp3` | something is clicked, a quickhack is uploaded, a matrix cell is picked |
| `tab.mp3`, `value-up.mp3`, `value-down.mp3` | a tab switches, a gauge moves, a contact is dialed |
| `menu-open.mp3`, `menu-close.mp3` | a menu opens or closes, a holocall connects or ends |
| `radial-open.mp3`, `radial-close.mp3` | the quickhack launcher opens or closes |
| `ambient.mp3` | always, in a loop (general ambience) |
| `breach.mp3` | in a loop while the breach protocol is open (replaces the ambience) |
| `breach-open.mp3` | the breach protocol opens |
| `matrix-hover.mp3` | a cell of the code matrix gets hovered |
| `breach-success.mp3` | a breach ends with at least one daemon installed, a package is added |
| `breach-fail.mp3` | a breach ends with nothing installed, a package is refused |
| `notification.mp3` | a notification arrives (not in do not disturb) |
| `call.mp3` | a holocall rings |
| `deck-switch.mp3` | the OS (netdriver, canto...) is switched |
| `lock-granted.mp3`, `lock-denied.mp3` | the lockscreen accepts or refuses a password |
| `boot.mp3` | the power-on sequence of the first login |
