# Terminal setup — Omarchy-style look (Fish)

The same **Alacritty + Tokyo Night + Fish** stack works on **Kubuntu + KDE Plasma** today and on **Hyprland** when you switch sessions. Colours and shell live in [alacritty/alacritty-base.toml](alacritty/alacritty-base.toml); window decorations are chosen by a small wrapper (**KDE:** title bar for dragging — [alacritty/alacritty-kde.toml](alacritty/alacritty-kde.toml); **Hyprland:** no title bar — [alacritty/alacritty.toml](alacritty/alacritty.toml)).

## Quick navigation

| Situation | Section |
|-----------|---------|
| **KDE Plasma only** (not on Hyprland yet) | [Kubuntu on KDE Plasma before Hyprland](#kubuntu-on-kde-plasma-before-hyprland) |
| **Hyprland** (or wiring the terminal there) | [Hyprland terminal integration](#hyprland-terminal-integration) |
| **Neovim / LazyVim** (transparent UI) | [Neovim (LazyVim) transparency](#neovim-lazyvim-transparency-over-alacritty) |
| **Fish + btop** (Tokyo Night) | [Fish and btop](#fish-and-btop-tokyo-night) |
| **Other emulators** (Ghostty, Kitty, …) | [Option B](#option-b--ghostty-closer-to-latest-omarchy-default-on-arch) / [Option C](#option-c--kitty-foot-wezterm) |

**Full Hyprland desktop install** (second session, Waybar, portals, …): [SETUP.md](SETUP.md) · **Source builds**: [SOURCES.md](SOURCES.md) · **Repo overview**: [README.md](README.md)

---

## What Omarchy uses

Omarchy is an Arch-based Hyprland desktop. From the [Omarchy manual — Terminal](https://learn.omacom.io/2/the-omarchy-manual/106/terminal):

- **Historically:** **Alacritty** (minimal, fast, no built-in tabs or inline images).
- **Recent releases (around 3.2+):** many installs default to **Ghostty**; Omarchy still offers **Kitty**, **Foot**, **WezTerm**, etc.

You do **not** need a specific emulator for LazyVim or Fish. The “Omarchy look” is mostly:

1. **Compositor / WM** — On Hyprland: rounding, gaps, blur (see [hypr/hyprland.conf](hypr/hyprland.conf)). On KDE: optional **KWin** blur / translucency so a slightly transparent terminal looks soft over the wallpaper.
2. **Terminal theme** — Background `#1a1b26`, Tokyo Night palette, **JetBrains Mono Nerd Font**, modest transparency (`window.opacity` in Alacritty).
3. **Shell** — Fish inside the terminal (often without changing login shell); configured in `alacritty-base.toml` for both desktops. Omarchy’s interactive defaults use **`eza`** for `ls` (icons, git column in `lt`, colours) when the package is present — see [fish/README.md](fish/README.md).

This repo standardizes on **Alacritty** from Ubuntu/Kubuntu apt; [SETUP.md](SETUP.md) Step 7 deploys the Hyprland pair (`alacritty-base.toml` + `alacritty.toml`).

---

## Shared — Alacritty, Tokyo Night, Nerd Font, Fish

Use these on **both** KDE and Hyprland.

### 1. Install and version

```bash
sudo apt install alacritty
alacritty --version   # need >= 0.12 for TOML
```

### 2. Nerd Font (icons in prompt, lazygit, etc.)

Follow [SETUP.md](SETUP.md) Step **0c** or **Nerd Fonts — JetBrains Mono** in [SOURCES.md](SOURCES.md).

```bash
fc-list | grep -i "JetBrainsMono Nerd"
```

### 3. Deploy config

Shared theme: [alacritty/alacritty-base.toml](alacritty/alacritty-base.toml) (Tokyo Night Night, 12pt, **96% opacity**, block blinking cursor, **Fish** via `[shell]`). Wrappers only set **window decorations**:

| Desktop | Copy into `~/.config/alacritty/` |
|---------|----------------------------------|
| **Hyprland** | `alacritty-base.toml` + `alacritty.toml` (no title bar; compositor moves tiled windows) |
| **KDE Plasma** | `alacritty-base.toml` + **`alacritty-kde.toml` → rename to `alacritty.toml`** (native **title bar** so you can drag the window) |

Example if the repo is at `~/Development/Ricing`:

**Hyprland**

```bash
mkdir -p ~/.config/alacritty
cp ~/Development/Ricing/alacritty/alacritty-base.toml ~/.config/alacritty/
cp ~/Development/Ricing/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
```

**KDE Plasma**

```bash
mkdir -p ~/.config/alacritty
cp ~/Development/Ricing/alacritty/alacritty-base.toml ~/.config/alacritty/
cp ~/Development/Ricing/alacritty/alacritty-kde.toml ~/.config/alacritty/alacritty.toml
```

The main config file must always be named `alacritty.toml`; only the **second** line differs (which wrapper you copy in as `alacritty.toml`). Alacritty hot-reloads on save.

### 4. Fish path

The base config uses `/usr/bin/fish`. If `command -v fish` shows `/bin/fish`, edit `[shell] program` in `alacritty-base.toml` to match.

---

## Fish and btop (Tokyo Night)

Match Alacritty’s palette in the **shell** (syntax highlighting) and **btop**
(system monitor). Files live in this repo: [`fish/tokyo-night-colors.fish`](fish/tokyo-night-colors.fish), [`btop/tokyo-night.theme`](btop/tokyo-night.theme). Full step-by-step (backup, revert, Starship): [SETUP.md](SETUP.md) Steps **19–21**.

Replace `~/Development/Ricing` with your checkout path if different.

### Fish — syntax highlighting

The script sets **universal** `fish_color_*` variables (no `config.fish` edit).

**Backup** (optional but recommended):

```bash
cp ~/.local/share/fish/fish_variables ~/.local/share/fish/fish_variables.bak
```

**Apply** (run **once** from Fish):

```fish
fish ~/Development/Ricing/fish/tokyo-night-colors.fish
```

You should see `Tokyo Night fish colours applied.` Type a command: commands blue
(`#7aa2f7`), strings green, comments grey.

**Revert:** `cp ~/.local/share/fish/fish_variables.bak ~/.local/share/fish/fish_variables` then `exec fish`

### Fish — Omarchy-style `ls` (eza) and Ctrl+C on an empty line

Omarchy does **not** use plain `ls -la`; it uses **[eza](https://github.com/eza-community/eza)** when installed — see [Omarchy `default/bash/aliases`](https://github.com/basecamp/omarchy/blob/dev/default/bash/aliases) and [omarchy-fish `functions/ls.fish`](https://github.com/omacom-io/omarchy-fish/blob/master/functions/ls.fish). This repo ships the same idea under [`fish/functions/`](fish/functions/) plus [`fish/conf.d/99-omarchy-parity.fish`](fish/conf.d/99-omarchy-parity.fish) so **Ctrl+C on an empty prompt** matches **Bash**: Fish’s reader does not emit `^C` when the buffer is empty, so the snippet adds a **zero-width space** and runs the built-in **`cancel-commandline`** (Fish’s normal `^C` path — no custom repaint that clears scrollback).

Install and deploy: **[`fish/README.md`](fish/README.md)** (and [SETUP.md](SETUP.md) Step 20, subsection *Omarchy-style listings*). **Alacritty:** [`alacritty-base.toml`](alacritty/alacritty-base.toml) sets `TERM = "xterm-256color"` like [Omarchy’s Alacritty snippet](https://github.com/basecamp/omarchy/blob/dev/config/alacritty/alacritty.toml) for predictable 256-colour programs.

### btop — colour theme

**Install** btop if needed: `sudo apt install btop`

**Deploy** the theme file:

```bash
mkdir -p ~/.config/btop/themes
cp ~/Development/Ricing/btop/tokyo-night.theme ~/.config/btop/themes/tokyo-night.theme
```

**Select the theme**

- **In the UI:** start `btop` → **Esc** → **Options** → **Color theme** → **tokyo-night** → apply / save.
- **Or edit config:** run `btop` once and quit so it creates `~/.config/btop/btop.conf`, then:

```bash
sed -i 's/^color_theme =.*/color_theme = "tokyo-night"/' ~/.config/btop/btop.conf
```

Restart `btop` to pick up changes.

**Revert:** set `color_theme` back in btop options, or remove `~/.config/btop/themes/tokyo-night.theme`.

### Prompt (optional)

For a Tokyo Night **Starship** prompt, see [SETUP.md](SETUP.md) Step **19**.

---

## Kubuntu on KDE Plasma before Hyprland

Hyprland-specific pieces (`$terminal`, `Super+Return` in Hyprland, `hyprctl`) do **not** apply here. Use the **KDE** deploy commands above so `decorations = "Full"` — you get a normal **title bar** to drag and resize under KWin. The Hyprland wrapper uses `decorations = "None"` and is awkward on floating Plasma windows.

### Default terminal in Plasma

1. Open **System Settings**.
2. Go to **Apps** → **Default Applications** (Plasma 6), or **Default Applications** / **Details** depending on your Plasma version.
3. Set **Terminal emulator** to **Alacritty** (or **Other…** and choose `/usr/bin/alacritty`).

If Alacritty does not appear in the list, confirm the package is installed and that `/usr/share/applications/Alacritty.desktop` exists; log out and back in if the menu cache is stale.

### Optional: keyboard shortcut

**System Settings** → **Keyboard** → **Shortcuts** → **Custom Shortcuts** (or **KWin** shortcuts, depending on version): add a command shortcut, command `alacritty`, trigger e.g. **Meta+Return**. Disable or reassign any conflicting **Konsole** shortcut first.

### Ctrl+Alt+T → Alacritty (replace Konsole)

On Kubuntu, **Ctrl+Alt+T** is often bound to **Konsole** by default.

1. **System Settings** → **Keyboard** → **Shortcuts**.
2. Search for **terminal** or **Konsole**, or open **Standard shortcuts** / **Shortcuts for Applications** (labels vary between Plasma 5 and 6).
3. Find the entry that uses **Ctrl+Alt+T** (commonly “Konsole” or “Open Terminal”).
4. Either **change** its action to `alacritty` (use the full path `/usr/bin/alacritty` if the picker asks for a command), or **disable** it and create a **Custom shortcut**:
   - **Trigger:** Ctrl+Alt+T  
   - **Action:** Command / URL → `alacritty`

If Plasma reports a conflict with a **global** shortcut, disable the old binding first, then assign Ctrl+Alt+T again.

### Transparency and blur on KDE

`alacritty-base.toml` sets `opacity = 0.96`, so you see wallpaper or windows behind the terminal. For a softer “glass” look similar to Hyprland blur:

- Open **System Settings** → **Workspace** (or **Appearance**) → **Desktop Effects** (wording varies by Plasma 5 vs 6).
- Enable effects such as **Blur** / **Background contrast** for translucent windows (exact names depend on your Plasma version).

If text becomes hard to read, raise `opacity` in `alacritty-base.toml` (e.g. `0.98`) or turn down blur.

### Konsole vs Alacritty

Plasma’s default **Konsole** is unchanged system-wide until you set **Default Applications** and shortcuts. You can keep Konsole for `kio`/`sudo` dialogs while using Alacritty daily.

---

## Neovim (LazyVim) transparency over Alacritty

The terminal can be semi-transparent while Neovim still looks **opaque** if the
colorscheme paints a solid **Normal** background.

1. Use a Tokyo Night config with **`transparent = true`** and transparent
   sidebars/floats. This repo ships **[`nvim/lua/plugins/theme.lua`](nvim/lua/plugins/theme.lua)** — copy it to `~/.config/nvim/lua/plugins/theme.lua` (see [SETUP.md](SETUP.md) Step **22h**).
2. Restart Neovim; run `:hi Normal` and confirm **`guibg=NONE`** (or empty).
3. If a one-off test works, run `:hi Normal guibg=NONE` — if the wallpaper shows
   through, another plugin is resetting highlights; check for extra theme files
   under `lua/plugins/`.

More detail and revert steps: [SETUP.md](SETUP.md) → Step **22h**.

### Enter / Tab / Backspace register twice (Neo-tree “opens then closes”)

Neovim **0.11+** enables finer terminal key reporting (Kitty keyboard protocol /
extended keys). Some **Alacritty** versions (commonly **0.13.x**) mishandle **“report
event types”** and effectively deliver **both** the new encoding and the legacy byte
for the same physical key, so Neovim runs the mapping **twice** — classic symptom:
**Return** in the file explorer expands a folder and immediately collapses it.

This is **independent of LazyVim** and unrelated to Fish’s Omarchy Ctrl+C snippet.

**Fix (best):** upgrade **Alacritty** to a current release (the upstream fix is tracked
around [alacritty#8385](https://github.com/alacritty/alacritty/issues/8385)).

**Fix (workaround):** add the `VimEnter` / `VimLeavePre` autocommands from this repo’s
[`nvim/lua/config/autocmds.lua`](nvim/lua/config/autocmds.lua) to
`~/.config/nvim/lua/config/autocmds.lua` (merge with any autocommands you already have).
They narrow the terminal keyboard mode after startup and restore it on exit.

**Sanity check:** run `nvim --version` and `alacritty --version`. If you see **Neovim
0.12.x** and **Alacritty 0.13.x**, you are in the high-risk combination.

---

## Hyprland terminal integration

Use this after you have a **Hyprland** session (see [SETUP.md](SETUP.md) — SDDM session, config under `~/.config/hypr/`, etc.).

### 5. Hyprland `$terminal` and Super+Return

In [hypr/hyprland.conf](hypr/hyprland.conf):

```text
$terminal = alacritty
bind = $mod, Return, exec, $terminal
```

Deploy Hyprland config per [SETUP.md](SETUP.md) (Step 3 onward). **Super+Return** in the Hyprland session should launch Alacritty.

### Optional — Ctrl+Alt+T (match KDE habit)

Add to `hyprland.conf` (same `bind =` style as the rest of the file):

```text
bind = CTRL ALT, T, exec, $terminal
```

Reload with `hyprctl reload` (or log out of Hyprland and back in).

### 6. Optional — per-window opacity (Hyprland only)

Find the window class (often `Alacritty`):

```bash
hyprctl clients | grep -A3 'class:'
```

Example (tune values; confirm syntax for your Hyprland version):

```text
windowrulev2 = opacity 0.92 0.88, class:^(Alacritty)$
```

Add under the `windowrulev2` section in `hyprland.conf`. Remove if you prefer only Alacritty’s own `window.opacity`.

---

## Option B — Ghostty (closer to latest Omarchy default on Arch)

Install from [Ghostty’s official install docs](https://ghostty.org/docs/install) if not in apt.

- **KDE:** set **Default Applications** → Terminal to Ghostty; configure Tokyo Night + Fish in Ghostty’s config format.
- **Hyprland:** set `$terminal` to the `ghostty` binary and theme Fish there.

---

## Option C — Kitty, Foot, WezTerm

Same idea on either desktop:

1. Install the emulator.
2. Tokyo Night colours + **JetBrainsMono Nerd Font** (~12pt).
3. Background opacity ~0.96 (Hyprland blur shows through; on KDE pair with KWin blur if you want).
4. Shell → Fish.
5. **Hyprland only:** set `$terminal` to that program.

**Kitty** — graphics protocol for some Neovim plugins. **Foot** — minimal Wayland terminal. **WezTerm** — very configurable.

---

## Verify checklist

### On KDE Plasma

- [ ] `alacritty` from the app menu or a shortcut opens with Tokyo Night colours.
- [ ] Optional: **Default Applications** opens Alacritty for “open in terminal” workflows that respect it.
- [ ] You deployed **`alacritty-kde.toml` as `~/.config/alacritty/alacritty.toml`** so the window has a **title bar** (easy to drag under KWin).
- [ ] Transparency looks acceptable; optional KWin blur enabled if you want it.
- [ ] Fish prompt and Nerd icons (no `□` boxes).

### On Hyprland

- [ ] **`alacritty-base.toml` and `alacritty.toml`** are both under `~/.config/alacritty/` (the main file imports the base by fixed path).
- [ ] **Super+Return** opens your chosen terminal.
- [ ] Transparency + Hyprland blur look good (optional `windowrulev2` opacity).
- [ ] `echo $SHELL` may still show bash if you did not `chsh`; Fish is fine if the prompt is Fish.
- [ ] Nerd icons in `lazygit` / Starship / etc.

---

## Related files in this repo

| Piece | Location |
|--------|----------|
| Hyprland terminal bind + `$terminal` | [hypr/hyprland.conf](hypr/hyprland.conf) |
| Alacritty Tokyo Night + Fish | [alacritty/alacritty-base.toml](alacritty/alacritty-base.toml), [alacritty/alacritty.toml](alacritty/alacritty.toml) (Hyprland), [alacritty/alacritty-kde.toml](alacritty/alacritty-kde.toml) (KDE → deploy as `alacritty.toml`) |
| LazyVim Tokyo Night (transparent) | [nvim/lua/plugins/theme.lua](nvim/lua/plugins/theme.lua) |
| Neovim — doubled Enter/Tab/BS workaround (optional) | [nvim/lua/config/autocmds.lua](nvim/lua/config/autocmds.lua) |
| Fish Tokyo Night syntax | [fish/tokyo-night-colors.fish](fish/tokyo-night-colors.fish) |
| Fish Omarchy-style `ls` (eza), Ctrl+C empty line | [fish/README.md](fish/README.md) |
| btop Tokyo Night theme | [btop/tokyo-night.theme](btop/tokyo-night.theme) |
| Full Hyprland / Waybar walkthrough | [SETUP.md](SETUP.md) |
| Source builds (Neovim, Hyprland chain, fonts) | [SOURCES.md](SOURCES.md) |
| Doc index (Plasma vs Hyprland) | [README.md](README.md) |

---

## Upstream references

- [Omarchy manual — Terminal](https://learn.omacom.io/2/the-omarchy-manual/106/terminal)
- [Omarchy `dev` config](https://github.com/basecamp/omarchy/tree/dev/config) (Alacritty, themes, …)
