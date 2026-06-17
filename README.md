# Kubuntu rice configs (KDE Plasma + optional Hyprland)

This repository holds **Omarchy-inspired · Tokyo Night** styling and install notes for **Kubuntu 24.04**. You can stay on **KDE Plasma** for as long as you like; Hyprland is an optional **second SDDM session** when you are ready.

## On KDE Plasma only (no Hyprland yet)

| Goal | Document |
|------|------------|
| **Terminal** — Alacritty, Tokyo Night, Fish, transparency | [TERMINAL_OMARCHY.md](TERMINAL_OMARCHY.md#kubuntu-on-kde-plasma-before-hyprland) (shared [alacritty-base.toml](alacritty/alacritty-base.toml); KDE uses [alacritty-kde.toml](alacritty/alacritty-kde.toml) as `~/.config/alacritty/alacritty.toml` for a **title bar**) |
| **Neovim / LazyVim** — transparent UI over the terminal | [nvim/lua/plugins/theme.lua](nvim/lua/plugins/theme.lua) · [SETUP.md](SETUP.md) Step **22h** · [TERMINAL_OMARCHY.md](TERMINAL_OMARCHY.md#neovim-lazyvim-transparency-over-alacritty) |
| **Fish + btop** — Tokyo Night, Omarchy-style `ls` (eza), Ctrl+C on empty line | [TERMINAL_OMARCHY.md](TERMINAL_OMARCHY.md#fish-and-btop-tokyo-night) · [fish/README.md](fish/README.md) · [fish/tokyo-night-colors.fish](fish/tokyo-night-colors.fish) · [btop/tokyo-night.theme](btop/tokyo-night.theme) |
| GTK / Qt / SDDM / Waybar / Dunst / etc. | Many steps in [SETUP.md](SETUP.md) copy configs into `~/.config` and work under Plasma too; start from steps you care about (fonts, themes, terminal). Full package blast is aimed at Hyprland — see README note in [SETUP.md](SETUP.md). |

Plasma itself is not removed by this rice: you can always log out and pick **Plasma (Wayland)** or **Plasma (X11)** in SDDM.

## Hyprland session (when you migrate)

| Goal | Document |
|------|------------|
| **Full install** — packages, Hyprland chain, Waybar, portals, SDDM | [SETUP.md](SETUP.md) |
| **Build from source** — Hyprland deps, Neovim, lazygit, etc. | [SOURCES.md](SOURCES.md) |
| **Terminal** — `$terminal`, Super+Return, optional window opacity | [TERMINAL_OMARCHY.md](TERMINAL_OMARCHY.md#hyprland-terminal-integration) |

## Legacy (X11 + i3)

See [ARCHIVE_X11/](ARCHIVE_X11/) (e.g. `SETUP_X11.md`, `SOURCES_X11.md`).
