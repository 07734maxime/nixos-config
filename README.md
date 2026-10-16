# NixOS Configuration

My prsonal NixOS configuration, managed with flakes and
Home Manager. This is built around the Niri compositor and is
configured for NVIDIA graphics, and two 1920x1080
180 Hz DisplayPort monitors.

## What I've added for now

- NixOS unstable with flakes enabled
- Niri compositor
- Home Manager integrated into the system configuration
- NVIDIA drivers
- PipeWire audio
- Yazi as the XDG portal file chooser
- Waybar, Kitty, Fuzzel, Mako, Swaylock, and Swaybg (even though not all is configured for now)
- Neovim as the default editor
- Firefox with uBlock Origin and tracking protection enabled
- Visual Studio Code with Dracula Theme, Nix IDE, and Material Icon Theme
- Unfree packages enabled

## What I'll add soon

- Wallpaper daemon (probably using Waypaper as wrapper, or using a CLI)
- Theme based on wallpaper colors
- Anything related to Niri (including Fuzzel, Waybar...) 

## Repository Layout

```text
.
├── flake.nix                         # Flake inputs and the hello host
├── config/
│   ├── configuration.nix             # System-wide NixOS settings
│   └── hardware-configuration.nix    # Machine-generated hardware settings
└── home/
		├── home.nix                      # Home Manager packages and Niri setup
		└── apps/
				├── code.nix                  # Visual Studio Code configuration
				└── firefox.nix               # Firefox profile and extensions
```

## Niri Keybindings


| Binding | Action |
| --- | --- |
| `Mod+T` | Open Kitty |
| `Mod+D` | Open Fuzzel |
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
| `Print` | Screenshot |
| `Ctrl+Print` | Screenshot the screen |
| `Alt+Print` | Screenshot the focused window |
