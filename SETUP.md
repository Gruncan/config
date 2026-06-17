# Desktop Rice Setup Guide
**Target:** Kubuntu 24.04 · KDE Plasma · Wayland  
**Style:** Omarchy-inspired · Tokyo Night Dark · Hyprland + Waybar

Work through each step in order. Every step backs up the existing file before
touching it, and every step has a one-line revert. Stop at any point — nothing
done so far will break anything that came before.

This file is the **Hyprland session** install path (second SDDM session). For
what to do **while you still use KDE Plasma only** (terminal, doc map), see
[README.md](README.md) and [TERMINAL_OMARCHY.md](TERMINAL_OMARCHY.md#kubuntu-on-kde-plasma-before-hyprland).
Step **0** below is a large `apt` set aimed at building/running Hyprland; you can
defer it until you are ready, or install a smaller set (e.g. `alacritty`,
`unzip`, `wget`) and add the rest later.

**KDE Plasma is never touched.** At any point you can log out and select
**Plasma** in the SDDM session menu to return to your original KDE desktop.

> The previous X11/i3 version of this tutorial is preserved in `ARCHIVE_X11/SETUP_X11.md`.

**Terminal (Omarchy-style, Fish, Alacritty vs Ghostty/Kitty):** see [TERMINAL_OMARCHY.md](TERMINAL_OMARCHY.md).

---

## Before you start

Clone or copy this repo to the Kubuntu machine:
```bash
git clone <your-repo-url> ~/Development/Ricing
# or just scp/copy the folder across
```

Confirm you are booted into Kubuntu with KDE Plasma working normally.
Hyprland will be added as a second session — KDE remains intact throughout.

---

## Step 0 — Packages

Install all Wayland-native tools and build dependencies in one command.
If a package is missing from your mirror, see `SOURCES.md`.

```bash
sudo apt install \
    meson ninja-build cmake pkg-config git \
    libwayland-dev wayland-protocols libxkbcommon-dev \
    libpixman-1-dev libcairo2-dev libpango1.0-dev \
    libdrm-dev libgbm-dev libgl-dev libegl-dev libegl1-mesa-dev \
    libinput-dev libudev-dev libgles2-mesa-dev \
    libvulkan-dev glslang-tools vulkan-validationlayers-dev \
    libseat-dev libdisplay-info-dev hwdata \
    libxcb-dri3-dev libxcb-composite0-dev libxcb-res0-dev \
    libxcb-icccm4-dev libxcb-ewmh-dev libx11-xcb-dev \
    libxcb-xinput-dev libxcb-xfixes0-dev libxcb-shm0-dev \
    libdecor-0-dev libtoml++3-dev libre2-dev \
    libwebp-dev libjpeg-dev libpng-dev \
    waybar wofi swaylock swaybg grim slurp wl-clipboard \
    brightnessctl dunst alacritty \
    pipewire wireplumber libpipewire-0.3-dev \
    xdg-desktop-portal xdg-desktop-portal-wlr \
    papirus-icon-theme fonts-jetbrains-mono libnotify-bin playerctl \
    qt5-style-kvantum qt5-style-kvantum-themes \
    capitaine-cursors \
    ripgrep fd-find fzf unzip eza \
    clang clangd bear \
    policykit-1-gnome network-manager-gnome pavucontrol \
    xwayland
```

Check what your mirror skipped:
```bash
for p in waybar wofi swaylock swaybg grim slurp wl-clipboard \
          brightnessctl dunst alacritty pipewire wireplumber \
          xdg-desktop-portal xdg-desktop-portal-wlr \
          papirus-icon-theme fonts-jetbrains-mono libnotify-bin playerctl \
          qt5-style-kvantum capitaine-cursors \
          ripgrep fd-find fzf eza clang clangd bear \
          policykit-1-gnome network-manager-gnome pavucontrol xwayland; do
    dpkg -s "$p" &>/dev/null && echo "OK      $p" || echo "MISSING $p"
done
```

For any `MISSING` entry, refer to `SOURCES.md`.

**Revert:** `sudo apt remove <package>` — no config files are touched by this step.

---

## Step 0b — Version checks

```bash
waybar  --version     # Any version is fine
dunst   --version     # Need >= 1.9 for Wayland layer support
alacritty --version   # Need >= 0.12 for TOML config
swaylock  --version   # Any version is fine
```

### If dunst < 1.9
Replace the `origin`/`offset` position block with the legacy format:
```
geometry = "360x5-20+45"
```
Remove the `origin`, `offset`, `width`, `height`, `gap_size` lines.

### If alacritty < 0.12
The `alacritty.toml` config will be ignored. YAML format is required instead.
Share the output of `alacritty --version` and I'll generate an
`alacritty.yml` equivalent.

---

## Step 0c — Nerd Font (do this if you see □ characters in the bar/prompt)

The apt package `fonts-jetbrains-mono` does **not** include the icon glyphs.
Install the Nerd Font variant manually:

```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip -d JetBrainsMono
rm JetBrainsMono.zip
fc-cache -fv
```

Verify:
```bash
fc-list | grep -i "JetBrainsMono Nerd"
```

**Revert:** `rm -rf ~/.local/share/fonts/JetBrainsMono && fc-cache -fv`

---

## Step 1 — Build Hyprland from Source

Hyprland is not packaged in Ubuntu's apt repositories. It must be built from
source. The process builds five small Hyprland-ecosystem libraries first, then
Hyprland itself. Allow ~20 minutes on first build; subsequent rebuilds are faster.

All libraries install to `/usr/local` and can be uninstalled cleanly. See
`SOURCES.md` for the full details on each library.

### 1a — Create a build workspace

```bash
mkdir -p ~/build/hypr
cd ~/build/hypr
```

### 1b — Build the dependency chain in order

Each library follows the same three-command pattern:
```bash
git clone <repo> && cd <name>
cmake -B build -DCMAKE_BUILD_TYPE=Release
sudo cmake --build build --target install
cd ..
```

Run through them in this order (copy-paste the block from `SOURCES.md Step 1`):

1. `hyprwayland-scanner` — Wayland protocol code generator
2. `hyprutils` — utility library
3. `hyprlang` — Hyprland config language parser
4. `hyprland-protocols` — Hyprland-specific Wayland protocols
5. `aquamarine` — DRM/KMS rendering backend

See `SOURCES.md → Step 1: Hyprland Build Chain` for the exact clone URLs and
build commands for each library.

### 1c — GCC version prerequisite

Ubuntu 24.04 ships GCC 13. Hyprland v42+ requires GCC 14. Install it and
set it as the default **before** building:

```bash
sudo apt install gcc-14 g++-14
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 14 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-14 \
    --slave /usr/bin/gcov gcov /usr/bin/gcov-14

# Verify:
gcc --version   # should show gcc-14 (Ubuntu …)
```

**Revert (restore GCC 13 as default):**
```bash
sudo update-alternatives --set gcc /usr/bin/gcc-13
```

---

### 1d — Build Hyprland itself

```bash
cd ~/build/hypr
git clone --recursive https://github.com/hyprwm/Hyprland.git
cd Hyprland

# List available tags and check out the one you want (v42 was tested with this tutorial):
git tag --sort=-v:refname | head -10
git checkout v42   # replace with your chosen tag

make all
sudo make install
```

This installs:
- `/usr/local/bin/Hyprland`
- `/usr/local/bin/hyprctl`
- `/usr/local/share/wayland-sessions/hyprland.desktop`

### Verify the build

```bash
Hyprland --version
hyprctl version   # will fail until Hyprland is running — that's expected
ls /usr/local/share/wayland-sessions/hyprland.desktop
```

### Revert (remove Hyprland)

```bash
# From the Hyprland source directory:
cd ~/build/hypr/Hyprland
sudo make uninstall
# Or manually:
sudo rm /usr/local/bin/Hyprland /usr/local/bin/hyprctl
sudo rm /usr/share/wayland-sessions/hyprland.desktop
```

---

## Step 2 — SDDM Session Entry

Source builds install the session file to `/usr/local/share/wayland-sessions/`.
SDDM on Ubuntu 24.04 only reads `/usr/share/wayland-sessions/`, so a symlink is
needed. The `Exec=` line must also use the full path because SDDM's PATH does
not include `/usr/local/bin`.

### Verify both sessions exist

```bash
# KDE Plasma (must exist)
ls /usr/share/xsessions/plasmax11.desktop \
   /usr/share/xsessions/plasma.desktop 2>/dev/null || echo "Check /usr/share/xsessions/"

# Hyprland — source build puts the file here:
ls /usr/local/share/wayland-sessions/hyprland.desktop
```

### Symlink to where SDDM can find it

```bash
sudo mkdir -p /usr/share/wayland-sessions
sudo ln -sf /usr/local/share/wayland-sessions/hyprland.desktop \
            /usr/share/wayland-sessions/hyprland.desktop
```

If the file is missing entirely (e.g. older build), create it directly:
```bash
sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null <<'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=/usr/local/bin/Hyprland
Type=Application
DesktopNames=Hyprland
EOF
```

### Test (without logging out)

```bash
# Preview that SDDM will show both sessions:
ls /usr/share/xsessions/ /usr/share/wayland-sessions/
# hyprland.desktop should appear in /usr/share/wayland-sessions/
```

Now log out: `Super+Shift+e` (from KDE) or use the KDE app menu → Leave.
At the SDDM login screen, click the session selector and confirm you see both
**Plasma** and **Hyprland**. Log back into **Plasma** for now — the next step
is the first Hyprland login.

**Revert:** Select **Plasma** in SDDM at any time. KDE is completely untouched.
To fully remove the Hyprland session entry: `sudo rm /usr/share/wayland-sessions/hyprland.desktop`

---

## Step 3 — Bare Hyprland Config (first boot)

Before deploying the full config, get a working bare session to confirm Hyprland
starts cleanly on your hardware.

### Deploy bare config

```bash
mkdir -p ~/.config/hypr
tee ~/.config/hypr/hyprland.conf > /dev/null <<'EOF'
monitor=,preferred,auto,1
$terminal = alacritty

bind = SUPER, Return, exec, $terminal
bind = SUPER SHIFT, E, exit

input {
    kb_layout = us
    touchpad { natural_scroll = true }
}

general {
    gaps_in = 6
    gaps_out = 12
    border_size = 2
    col.active_border   = rgba(7aa2f7ff)
    col.inactive_border = rgba(292e42ff)
}

decoration { rounding = 8 }
EOF
```

### Log into Hyprland

Log out of KDE. At SDDM, select **Hyprland** from the session menu. Log in.

You will see a plain black screen — that's correct at this stage.

### Confirm Wayland is active

Press `Super+Return` to open a terminal, then run:
```bash
echo "Session type: $XDG_SESSION_TYPE"
echo "Wayland display: $WAYLAND_DISPLAY"
# Expected: wayland and wayland-1 (or similar)
```

If the terminal doesn't open: Hyprland started but alacritty failed.
Switch to a TTY (`Ctrl+Alt+F2`), check `journalctl -e` for errors.

### Exit Hyprland

`Super+Shift+E` — returns cleanly to SDDM.

---

## Step 4 — Full Hyprland Config

**What this does:** Deploys the complete Hyprland config with Tokyo Night
colours, omarchy-style animations, keybindings, window rules, and autostart.

### Backup

```bash
cp ~/.config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf.bak 2>/dev/null || true
```

### Check your monitor setup first

Boot into Hyprland with the bare config (Step 3), open a terminal, and run:

```bash
hyprctl monitors
```

The default `monitor=,preferred,auto,1` in the full config handles single
and dual monitors automatically. For custom resolutions or specific ordering,
see Step 17 (Display / Monitor Config).

### Check for Nvidia GPU

```bash
lspci | grep -i nvidia
```

If you have an Nvidia card, **uncomment the Nvidia `env =` lines** in
`hypr/hyprland.conf` before deploying (they're clearly marked in the file).

### Deploy

```bash
mkdir -p ~/.config/hypr
cp ~/Development/Ricing/hypr/hyprland.conf ~/.config/hypr/hyprland.conf
```

### Apply (reload config without full logout)

```bash
# From inside Hyprland:
hyprctl reload
```

Or log out (`Super+Shift+E`) and back in.

### Keybindings at a glance

| Key | Action |
|-----|--------|
| `Super+Return` | Open terminal (alacritty) |
| `Super+Space` | Open launcher (wofi) |
| `Super+Shift+Q` | Close window |
| `Super+h/j/k/l` | Focus left/down/up/right |
| `Super+Shift+h/j/k/l` | Move window |
| `Super+1…9, 0` | Switch workspace |
| `Super+Shift+1…9, 0` | Move window to workspace |
| `Super+F` | Fullscreen |
| `Super+M` | Monocle (max without gaps) |
| `Super+R` | Resize mode (hjkl/arrows, Esc to exit) |
| `Super+Shift+Space` | Toggle floating |
| `Super+L` | Lock screen |
| `Super+Shift+S` | Screenshot selection → ~/Pictures |
| `Print` | Screenshot full screen → ~/Pictures |
| `Super+Shift+E` | Exit Hyprland |

### Revert

```bash
cp ~/.config/hypr/hyprland.conf.bak ~/.config/hypr/hyprland.conf
hyprctl reload
```

---

## Step 4b — Polkit Agent & Network Tray

**What this does:** Without a polkit agent, GUI apps that need elevated permissions
(connecting to VPN, unlocking keyrings, mounting drives) silently fail. `nm-applet`
adds a system tray icon so you can connect to WiFi without opening a terminal.
Both are wired into `hyprland.conf` already.

### Verify polkit agent starts

```bash
# From inside Hyprland, check it's running:
pgrep -a polkit-gnome
```

If `policykit-1-gnome` wasn't available from your mirror, check alternatives:
```bash
# lxpolkit is a lighter fallback (lxsession package):
which lxpolkit
# If found, edit hyprland.conf exec-once line to:
#   exec-once = lxpolkit
```

### Verify nm-applet appears in tray

Waybar's tray module (rightmost position) should show a network icon.
Click it to manage connections. Right-click the Waybar tray area if the icon
is hidden.

### Note on brightnessctl

Brightness keys require your user to be in the `video` group:
```bash
groups | grep video || sudo usermod -aG video $USER
# Log out and back in for group change to take effect
```

---

## Step 5 — Waybar (status bar)

**What this does:** Replaces the plain titlebar area with a floating Tokyo Night
bar showing workspaces, clock, CPU, memory, network, volume, and battery.
Started automatically by Hyprland (already in `exec-once` in hyprland.conf).

### Backup

```bash
cp -r ~/.config/waybar ~/.config/waybar.bak 2>/dev/null || true
```

### Deploy

```bash
mkdir -p ~/.config/waybar
cp ~/Development/Ricing/waybar/config.jsonc ~/.config/waybar/config.jsonc
cp ~/Development/Ricing/waybar/style.css    ~/.config/waybar/style.css
```

### Start / restart without logging out

```bash
killall waybar 2>/dev/null; waybar &
```

### Customise for your hardware

**No battery (desktop):** Remove `"battery"` from the `modules-right` array in
`~/.config/waybar/config.jsonc`.

**No wifi:** The network module auto-detects ethernet vs wifi. No changes needed
unless you want to pin it to a specific interface:
```jsonc
"network": { "interface": "eth0" }
```

**PipeWire audio:** The `pulseaudio` module works with both PipeWire and PulseAudio
because PipeWire ships a PulseAudio compatibility layer.

### Revert

```bash
killall waybar
cp -r ~/.config/waybar.bak ~/.config/waybar
waybar &
```

---

## Step 6 — Wofi (application launcher)

**What this does:** Styles the `Super+Space` launcher as a centred Tokyo Night
spotlight panel — 600px wide, 8 results, blue border on selection.
Replaces the X11-only rofi.

### Backup

```bash
cp -r ~/.config/wofi ~/.config/wofi.bak 2>/dev/null || true
```

### Deploy

```bash
mkdir -p ~/.config/wofi
cp ~/Development/Ricing/wofi/config    ~/.config/wofi/config
cp ~/Development/Ricing/wofi/style.css ~/.config/wofi/style.css
```

### Verify

```bash
wofi --show drun
```

The panel should appear centred, dark, with a blue focus border.
Press `Escape` to dismiss.

If wofi opens unstyled (grey/white): confirm `~/.config/wofi/style.css` exists.

### Revert

```bash
cp -r ~/.config/wofi.bak ~/.config/wofi
# or remove styling entirely:
rm ~/.config/wofi/style.css
```

---

## Step 7 — Alacritty (terminal)

**What this does:** Gives alacritty Tokyo Night Dark colours, JetBrains Mono at
12pt, subtle transparency (96%), block cursor with blink, and launches **Fish**
without requiring `chsh`. Alacritty detects Wayland automatically — no config
changes needed vs the X11 version. **KDE Plasma** users should deploy the
**KDE** wrapper so the window keeps a **title bar** for dragging; this step’s
commands target the **Hyprland** pair (borderless under the compositor).

Theme files in this repo:

- [`alacritty/alacritty-base.toml`](alacritty/alacritty-base.toml) — colours, font, Fish, opacity (shared).
- [`alacritty/alacritty.toml`](alacritty/alacritty.toml) — **Hyprland:** imports base, `decorations = "None"`.
- [`alacritty/alacritty-kde.toml`](alacritty/alacritty-kde.toml) — **KDE Plasma:** imports base, `decorations = "Full"` (title bar so you can drag the window).

On **KDE only**, deploy the KDE wrapper as your main config file name (see
[TERMINAL_OMARCHY.md](TERMINAL_OMARCHY.md#kubuntu-on-kde-plasma-before-hyprland)).

For upstream Omarchy’s current default terminal (often **Ghostty**), Kitty/Foot,
Hyprland-only opacity rules, and Fish path notes, read
[TERMINAL_OMARCHY.md](TERMINAL_OMARCHY.md).

### Backup

```bash
cp -r ~/.config/alacritty ~/.config/alacritty.bak 2>/dev/null || true
```

### Deploy (Hyprland session — default for this guide)

```bash
mkdir -p ~/.config/alacritty
# If you cloned this repo to ~/Development/Ricing (see "Before you start"):
cp ~/Development/Ricing/alacritty/alacritty-base.toml ~/.config/alacritty/
cp ~/Development/Ricing/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
```

If the repo lives elsewhere, copy both files from that checkout’s `alacritty/`
directory. **Both** are required: `alacritty.toml` imports `alacritty-base.toml`
by path under `~/.config/alacritty/`.

### Verify

Alacritty hot-reloads — open a terminal and the colours change immediately.

If the terminal looks wrong:
- Wrong colours → confirm `alacritty --version` is ≥ 0.12
- Box characters instead of icons → Nerd Font not installed (see Step 0c)
- Fish did not start → edit `[shell] program` in `alacritty-base.toml` to match
  `command -v fish` (often `/usr/bin/fish` or `/bin/fish`)
- Omarchy-style directory listings → install **`eza`** and deploy [fish/README.md](fish/README.md) (Step 20 in [SETUP.md](SETUP.md)); `[env] TERM` is set in the base config like [Omarchy’s Alacritty](https://github.com/basecamp/omarchy/blob/dev/config/alacritty/alacritty.toml)

### Revert

```bash
cp -r ~/.config/alacritty.bak ~/.config/alacritty
```

---

## Step 8 — Dunst (notifications on Wayland)

**What this does:** Dunst works on Wayland with one extra setting: `layer = overlay`.
Without it, notifications appear behind all windows. This step deploys the
updated config with that setting already included.

### Backup

```bash
cp -r ~/.config/dunst ~/.config/dunst.bak 2>/dev/null || true
```

### Deploy

```bash
mkdir -p ~/.config/dunst
cp ~/Development/Ricing/dunst/dunstrc ~/.config/dunst/dunstrc
```

### Start / restart dunst

```bash
pkill dunst 2>/dev/null || true
dunst &
```

### Test it

```bash
notify-send -u low    "Test" "Low urgency — grey border, 4s"
notify-send           "Test" "Normal — blue border, 6s"
notify-send -u critical "Test" "Critical — red border, stays until clicked"
```

Notifications should appear top-right, on top of all windows.

### Revert

```bash
pkill dunst
cp -r ~/.config/dunst.bak ~/.config/dunst
dunst &
```

---

## Step 9 — Wallpaper (swaybg)

**What this does:** `swaybg` sets the desktop wallpaper as a Wayland-native
background layer. It starts automatically with Hyprland. Until this step, it
runs with a solid Tokyo Night background (`#1a1b26`).

### Add your wallpaper

```bash
mkdir -p ~/Pictures
cp /path/to/your/image.jpg ~/Pictures/wallpaper.jpg
```

### Switch from solid colour to the image

```bash
pkill swaybg
swaybg -i ~/Pictures/wallpaper.jpg -m fill &
```

### Make it permanent (survive reboots)

Edit `~/.config/hypr/hyprland.conf` and replace the solid-colour swaybg line:
```
# Replace this:
exec-once = swaybg -c 1a1b26
# With this:
exec-once = swaybg -i ~/Pictures/wallpaper.jpg -m fill
```
Then `hyprctl reload`.

### Upgrade path: hyprpaper

For animated wallpapers or per-monitor wallpaper control, see
`SOURCES.md → hyprpaper`. It requires a source build but is a drop-in
replacement — just update the `exec-once` line.

### Recommended wallpapers for Tokyo Night

Dark, minimal, abstract — anything with deep blues and purples.
Search: `unsplash.com` → "dark abstract blue" or "cyberpunk cityscape"

---

## Step 9b — Idle Management (hypridle)

**What this does:** Automatically dims the display, locks the screen, and turns
off the monitor after inactivity — matching omarchy's behaviour. Without this,
the screen never locks automatically and the display never sleeps.

`hypridle` is a Hyprland-ecosystem tool not available in Ubuntu apt.
See `SOURCES.md → hypridle` for the source build (same cmake pattern as the
other hypr libraries, ~2 minutes).

### Config after building

Create `~/.config/hypr/hypridle.conf`:

```ini
general {
    lock_cmd = swaylock
    before_sleep_cmd = swaylock
    after_sleep_cmd = hyprctl dispatch dpms on
}

listener {
    timeout = 300          # 5 min: lock screen
    on-timeout = swaylock
    on-resume = notify-send "Welcome back"
}

listener {
    timeout = 360          # 6 min: turn off display
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}
```

### Add to hyprland.conf autostart

```bash
# Add this line to ~/.config/hypr/hyprland.conf exec-once section:
exec-once = hypridle
```

### Revert / skip

If you skip this step, the screen will never lock or sleep automatically.
That's fine for a desktop — only relevant for laptops or security requirements.

**Revert:** Remove `exec-once = hypridle` from `hyprland.conf`, then
`pkill hypridle`.

---

## Step 10 — Lock Screen (swaylock)

**What this does:** Locks the screen with a solid Tokyo Night background and a
ring indicator in Tokyo Night colours. `Super+L` triggers it (already wired
in `hyprland.conf`). Notifications are automatically paused while locked.

> **Note:** The standard apt `swaylock` shows a solid colour background, not a
> blurred screenshot. For blur + clock overlay, see `SOURCES.md → swaylock-effects`.

### Backup

```bash
cp -r ~/.config/swaylock ~/.config/swaylock.bak 2>/dev/null || true
```

### Deploy

```bash
mkdir -p ~/.config/swaylock
cp ~/Development/Ricing/swaylock/config ~/.config/swaylock/config
```

### Test without locking yourself out

Open a second TTY first (`Ctrl+Alt+F2`), then test from Hyprland:
```bash
swaylock
```

If the screen goes blank and then shows the lock UI, press `Ctrl+Alt+F2`
to switch to the TTY and run `pkill swaylock` if anything looks wrong.

### Pause notifications on lock

To pause dunst while locked and resume on unlock (matching the old i3lock
behaviour), create a wrapper script:

```bash
cat > ~/.local/bin/lock.sh << 'EOF'
#!/usr/bin/env bash
dunstctl set-paused true
swaylock
dunstctl set-paused false
EOF
chmod +x ~/.local/bin/lock.sh
```

Then update the lock keybind in `~/.config/hypr/hyprland.conf`:
```
bind = $mod, L, exec, ~/.local/bin/lock.sh
```

### Upgrade path: swaylock-effects (blur on lock)

For a blurred screenshot background (like the old i3lock-color), see
`SOURCES.md → swaylock-effects`. It requires a source build but uses the
same config file with two extra lines:
```
screenshots
effect-blur=7x5
```

### Revert

```bash
cp -r ~/.config/swaylock.bak ~/.config/swaylock
```

---

## Step 11 — Tokyo Night GTK Theme

**What this does:** Makes all GTK3/GTK4 apps use Tokyo Night Dark colours.
Same approach as before — extract and copy, no compilation.

### Install the theme

```bash
mkdir -p ~/.themes
wget https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme/archive/refs/heads/master.zip \
    -O /tmp/tokyonight-gtk.zip
unzip /tmp/tokyonight-gtk.zip -d /tmp/tokyonight-gtk
cp -r /tmp/tokyonight-gtk/Tokyo-Night-GTK-Theme-master/themes/* ~/.themes/
rm -rf /tmp/tokyonight-gtk /tmp/tokyonight-gtk.zip
```

Verify:
```bash
ls ~/.themes/ | grep Tokyonight
# Should show: Tokyonight-Dark-B, Tokyonight-Storm-B, etc.
```

We use `Tokyonight-Dark-B` — darkest variant, closest to the Hyprland palette.

**Revert:** `rm -rf ~/.themes/Tokyonight*`

---

## Step 12 — Icons and Cursor

**What this does:** Switches icons to Papirus-Dark and cursor to
capitaine-cursors. Both were already installed in Step 0.

### Verify they're installed

```bash
ls /usr/share/icons/ | grep -i "papirus\|capitaine"
```

If missing:
```bash
sudo apt install papirus-icon-theme capitaine-cursors
```

**Revert:** `sudo apt remove papirus-icon-theme capitaine-cursors`

---

## Step 13 — Apply GTK Settings

**What this does:** On Wayland, GTK settings are applied via `gsettings` rather
than `xsettingsd`. The `exec-once = gsettings set …` lines in `hyprland.conf`
(Step 4) handle this automatically on every login.

This step deploys the GTK config files for apps that read them directly.

### Backup existing GTK config

```bash
cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini.bak 2>/dev/null || true
cp ~/.config/gtk-4.0/settings.ini ~/.config/gtk-4.0/settings.ini.bak 2>/dev/null || true
cp ~/.gtkrc-2.0 ~/.gtkrc-2.0.bak 2>/dev/null || true
```

### Deploy

```bash
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0

cp ~/Development/Ricing/gtk/settings.ini      ~/.config/gtk-3.0/settings.ini
cp ~/Development/Ricing/gtk/gtk4-settings.ini ~/.config/gtk-4.0/settings.ini
cp ~/Development/Ricing/gtk/gtkrc-2.0         ~/.gtkrc-2.0
```

### Apply immediately (belt and braces)

```bash
gsettings set org.gnome.desktop.interface gtk-theme        'Tokyonight-Dark-B'
gsettings set org.gnome.desktop.interface icon-theme       'Papirus-Dark'
gsettings set org.gnome.desktop.interface cursor-theme     'capitaine-cursors'
gsettings set org.gnome.desktop.interface cursor-size      24
gsettings set org.gnome.desktop.interface font-name        'JetBrains Mono 10'
gsettings set org.gnome.desktop.interface color-scheme     'prefer-dark'
```

Open Dolphin or a GTK app — it should show the Tokyo Night theme immediately.

> **GTK4 / libadwaita caveat:** Apps built with libadwaita largely ignore the
> GTK4 settings file. The `color-scheme = prefer-dark` gsettings call above
> forces dark mode in those apps.

### Revert

```bash
cp ~/.config/gtk-3.0/settings.ini.bak ~/.config/gtk-3.0/settings.ini
cp ~/.config/gtk-4.0/settings.ini.bak ~/.config/gtk-4.0/settings.ini
cp ~/.gtkrc-2.0.bak ~/.gtkrc-2.0
```

---

## Step 14 — Qt / KDE Apps (Kvantum)

**What this does:** KDE apps like Dolphin use Qt. Kvantum applies a matching
Tokyo Night skin so they match the rest of the desktop. Works identically on
Wayland vs X11 — no changes from the original tutorial.

### Install the Tokyo Night Kvantum theme

```bash
mkdir -p ~/.config/Kvantum
wget https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme/archive/refs/heads/master.zip \
    -O /tmp/tokyonight-gtk.zip
unzip /tmp/tokyonight-gtk.zip -d /tmp/tokyonight-gtk
cp -r /tmp/tokyonight-gtk/Tokyo-Night-GTK-Theme-master/Kvantum/* ~/.config/Kvantum/
rm -rf /tmp/tokyonight-gtk /tmp/tokyonight-gtk.zip
```

### Apply via Kvantum Manager

```bash
kvantummanager
```

1. Select **TokyoNight** from the dropdown
2. Click **Use this theme**
3. Close

### Tell Qt to use Kvantum

Already set by `env = QT_STYLE_OVERRIDE,kvantum` in `hyprland.conf`.
If Qt apps still show Breeze, also add to `~/.profile`:
```bash
echo 'export QT_STYLE_OVERRIDE=kvantum' >> ~/.profile
```

### Revert

Open kvantummanager → switch back to Default.
Remove the `QT_STYLE_OVERRIDE` line from `~/.profile` if you added it.

---

## Step 15 — XDG Desktop Portal

**What this does:** The XDG portal handles screen sharing, file picker dialogs,
and drag-and-drop for apps running under Wayland. Required for browsers and
Electron apps to share screens correctly.

**Kubuntu complication:** KDE Plasma installs `xdg-desktop-portal-kde` as a
dependency. When Hyprland runs, both the kde and wlr backends are present —
without guidance the wrong one gets picked for screensharing. The fix is a
`portals.conf` file that tells the portal daemon to prefer the wlr (or hyprland)
backend when the desktop is Hyprland.

### Deploy the portals preference file

```bash
mkdir -p ~/.config/xdg-desktop-portal
cp ~/Development/Ricing/xdg-portal/hyprland-portals.conf \
   ~/.config/xdg-desktop-portal/hyprland-portals.conf
```

This file is read by `xdg-desktop-portal` when `XDG_CURRENT_DESKTOP=Hyprland`.
It tries the hyprland backend first (if built from source), falls back to wlr.
The kde backend is bypassed for screensharing.

### Verify the portal is running (from inside Hyprland)

```bash
systemctl --user status xdg-desktop-portal
# Should show active (running).

# Check which backend is active:
journalctl --user -u xdg-desktop-portal -e | grep -i "using portal"
```

If the portal shows `failed`, restart it:
```bash
systemctl --user restart xdg-desktop-portal
```

### Quick test (screen sharing works)

Open Zen/Firefox → a video call site → request screen share. You should see a
monitor picker rather than a "no screens found" error.

### Upgrade path: xdg-desktop-portal-hyprland

The Hyprland project ships its own portal (`xdg-desktop-portal-hyprland`)
with better integration for screencasting. See `SOURCES.md → xdg-desktop-portal-hyprland`.
After building it, the `portals.conf` above will automatically prefer it.

---

## Step 16 — Screenshots

**What this does:** `grim` captures Wayland screens. `slurp` provides the
interactive area selector. Keybindings are already set in `hyprland.conf`.

### Verify tools are installed

```bash
grim --version
slurp --version
```

### Test

```bash
mkdir -p ~/Pictures
# Full screenshot:
grim ~/Pictures/test-screenshot.png
# Area screenshot (drag to select):
grim -g "$(slurp)" ~/Pictures/test-area.png
```

### Keybinds (already wired in hyprland.conf)

| Key | Action |
|-----|--------|
| `Print` | Full screenshot → `~/Pictures/screenshot-TIMESTAMP.png` |
| `Super+Shift+S` | Area screenshot (click-drag to select) |

### Copy to clipboard instead of file

```bash
# Add these variants to ~/.config/hypr/hyprland.conf if needed:
bind = $mod ALT, Print, exec, grim - | wl-copy
bind = $mod ALT SHIFT, S, exec, grim -g "$(slurp)" - | wl-copy
```

---

## Step 17 — Display / Monitor Config

**What this does:** Hyprland's `monitor=` directive replaces autorandr/arandr.
Monitors are detected automatically by the default rule; this step documents
how to customise for your setup.

### Detect your monitors (from inside Hyprland)

```bash
hyprctl monitors
```

Sample output:
```
Monitor DP-1, 2560x1440@144.00Hz at 0x0, scale 1.0, transform 0
Monitor HDMI-A-1, 1920x1080@60.00Hz at 2560x0, scale 1.0, transform 0
```

### Add explicit monitor rules

Edit `~/.config/hypr/hyprland.conf`, replace the auto rule with explicit ones:
```
# monitor = name,        resolution@hz,  position,  scale
monitor   = DP-1,        2560x1440@144,  0x0,       1
monitor   = HDMI-A-1,    1920x1080@60,   2560x0,    1
# Keep the fallback for any monitor not listed above:
monitor   = ,preferred,auto,1
```

### Laptop lid / external-only

Add to `hyprland.conf`:
```
# Close lid → disable built-in display
bindl = , switch:on:Lid Switch,  exec, hyprctl keyword monitor "eDP-1, disable"
bindl = , switch:off:Lid Switch, exec, hyprctl keyword monitor "eDP-1, preferred, auto, 1"
```

### Reload

```bash
hyprctl reload
```

Monitor changes take effect immediately without logging out.

---

## Step 18 — SDDM Login Screen (Tokyo Night)

**What this does:** Applies a Tokyo Night–styled login screen. Identical to
the original tutorial — this step is unaffected by the Wayland/Hyprland migration.

### Check your SDDM version

```bash
sddm --version
```

The astronaut theme requires SDDM ≥ 0.19. Kubuntu 24.04 ships 0.21.

### Install Qt dependencies

```bash
sudo apt install \
    qml-module-qtquick-controls \
    qml-module-qtquick-controls2 \
    qml-module-qtgraphicaleffects \
    qml-module-qtquick-layouts
```

### Install the theme

```bash
git clone https://github.com/Keyitdev/sddm-astronaut-theme.git /tmp/sddm-astronaut-theme
sudo cp -r /tmp/sddm-astronaut-theme /usr/share/sddm/themes/sddm-astronaut-theme
rm -rf /tmp/sddm-astronaut-theme
```

### Activate the Tokyo Night variant

```bash
sudo cp /usr/share/sddm/themes/sddm-astronaut-theme/Themes/tokyo-night.conf \
        /usr/share/sddm/themes/sddm-astronaut-theme/theme.conf
```

### Tell SDDM to use the theme

```bash
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/theme.conf > /dev/null <<'EOF'
[Theme]
Current=sddm-astronaut-theme
EOF
```

### Preview without logging out

```bash
sddm-greeter --test-mode --theme /usr/share/sddm/themes/sddm-astronaut-theme
```

Press `Ctrl+C` to dismiss.

### Revert

```bash
sudo rm /etc/sddm.conf.d/theme.conf
# SDDM falls back to Breeze automatically
```

---

## Step 19 — Starship Prompt (Tokyo Night)

**What this does:** Applies a Tokyo Night–styled prompt to Starship. Unchanged
from the original tutorial — Starship works identically on Wayland.

### Backup

```bash
cp ~/.config/starship.toml ~/.config/starship.toml.bak 2>/dev/null || true
```

### Option A — Starship's built-in preset

```bash
starship preset tokyo-night -o /tmp/starship-preview.toml
cp /tmp/starship-preview.toml ~/.config/starship.toml
```

### Option B — Custom config from this repo (recommended)

```bash
cp ~/Development/Ricing/starship/starship.toml ~/.config/starship.toml
```

Apply immediately:
```fish
exec fish
```

### Revert

```bash
cp ~/.config/starship.toml.bak ~/.config/starship.toml
exec fish
```

---

## Step 20 — Fish Shell Colours (Tokyo Night)

**What this does:** Sets fish's syntax highlighting to Tokyo Night. Unchanged
from the original tutorial.

### Backup

```bash
cp ~/.local/share/fish/fish_variables ~/.local/share/fish/fish_variables.bak
```

### Apply

```fish
fish ~/Development/Ricing/fish/tokyo-night-colors.fish
```

### Verify

Type a command — commands should be blue (`#7aa2f7`), strings green (`#9ece6a`),
comments grey (`#565f89`), errors red (`#f7768e`).

### Revert

```bash
cp ~/.local/share/fish/fish_variables.bak ~/.local/share/fish/fish_variables
exec fish
```

### Omarchy-style listings (`eza`) and Ctrl+C on an empty line

**What this does:** Matches [Omarchy’s default `ls`](https://github.com/basecamp/omarchy/blob/dev/default/bash/aliases) and [omarchy-fish](https://github.com/omacom-io/omarchy-fish): `ls` uses **`eza -lh --group-directories-first --icons=auto`** (icons and colours need a [Nerd Font](TERMINAL_OMARCHY.md#3-nerd-font-icons-in-prompt-lazygit-etc); see Step 0c). Adds **`lsa`**, **`lt`**, **`lta`**. Also fixes the quirk where **Ctrl+C on an empty line** in Fish does nothing: Fish’s reader **returns early** on an empty buffer and never prints `^C`. This snippet inserts a **zero-width space** so **`cancel-commandline`** runs Fish’s normal non-empty path (same as Bash: `^C`, newline, line kept in scrollback, new prompt). No custom `printf`/`repaint` — those fight Fish’s screen redraw and could wipe the line.

**Install `eza`** (included in the Step 0 package list; otherwise):

```bash
sudo apt install eza
```

**Deploy** Fish functions + one conf.d snippet (see [fish/README.md](fish/README.md)):

```bash
REPO=~/Development/Ricing   # same path you used in "Before you start"
mkdir -p ~/.config/fish/functions ~/.config/fish/conf.d
cp -r "$REPO/fish/functions/." ~/.config/fish/functions/
cp "$REPO/fish/conf.d/99-omarchy-parity.fish" ~/.config/fish/conf.d/
exec fish
```

**Note:** If you already define **`fish_user_key_bindings`** in `~/.config/fish/config.fish`, that file loads after `conf.d` and replaces the function from `99-omarchy-parity.fish`. Merge the `bind` lines from that snippet into your own `fish_user_key_bindings`, or call `__fish_omarchy_ctrl_c` from it.

**Revert:** remove `~/.config/fish/conf.d/99-omarchy-parity.fish` and the four functions under `~/.config/fish/functions/` named `ls.fish`, `lsa.fish`, `lt.fish`, `lta.fish`, then `exec fish`.

**`^C` looks highlighted (reversed colours):** Fish’s default is `fish_color_cancel -r`. Re-run [`tokyo-night-colors.fish`](tokyo-night-colors.fish) (sets plain red `f7768e`), or `set -U fish_color_cancel f7768e`. The parity `conf.d` snippet also overrides a lone stock `-r` for the session.

---

## Step 21 — btop (Tokyo Night)

**What this does:** Adds a Tokyo Night theme file to btop. Unchanged.

### Deploy

```bash
mkdir -p ~/.config/btop/themes
cp ~/Development/Ricing/btop/tokyo-night.theme ~/.config/btop/themes/tokyo-night.theme
```

### Apply inside btop

```
ESC → Options → Color theme → tokyo-night → apply
```

Or set directly:
```bash
sed -i 's/^color_theme =.*/color_theme = "tokyo-night"/' ~/.config/btop/btop.conf
```

### Revert

```bash
cp ~/.config/btop/btop.conf.bak ~/.config/btop/btop.conf
```

---

## Step 22 — Neovim (LazyVim)

**What this does:** Builds Neovim 0.10+ from source, bootstraps LazyVim,
and sets up the Rust and C/C++ language servers, debugger, and Tokyo Night
theme — matching the NvimTutorial config at `~/Development/NvimTutorial`.

The apt `neovim` package is too old. All other runtime tools (`ripgrep`,
`fd-find`, `fzf`, `clang`, `clangd`, `bear`) were already installed in Step 0.
See `SOURCES.md → Neovim` for the full build reference.

### 22a — Build Neovim from source

`cmake` and `ninja-build` were already installed in Step 0. Only one extra dep needed:

```bash
sudo apt install gettext

mkdir -p ~/build
git clone https://github.com/neovim/neovim.git ~/build/neovim
cd ~/build/neovim
git checkout stable          # latest stable branch

make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install            # installs to /usr/local/bin/nvim

nvim --version   # confirm NVIM v0.10 or later
```

Build time: ~3–5 minutes.

**Revert:**
```bash
cd ~/build/neovim && sudo make uninstall
# or manually: sudo rm /usr/local/bin/nvim && sudo rm -rf /usr/local/share/nvim
```

### 22b — Fix fd-find path

Ubuntu installs `fd-find` as `fdfind`. LazyVim's Telescope expects `fd`:

```bash
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
# Make sure ~/.local/bin is on your PATH (fish/bash should pick this up)
echo $PATH | grep -o '\.local/bin' || echo 'Add ~/.local/bin to PATH'
```

### 22c — Install Node.js (for LSP servers)

Some Mason language servers require Node. Ubuntu 24.04 ships Node 20 in apt —
the simplest option, no version manager needed, and it works in fish shell:

```bash
sudo apt install nodejs npm
node --version   # confirm v20+
npm --version
```

**Revert:** `sudo apt remove nodejs npm`

> nvm is an alternative but requires extra setup to work in fish shell.
> The apt package is sufficient for all LSP servers in this tutorial.

### 22d — Install Rust toolchain

Required for `rust-analyzer` (Rust LSP) and the WebGL tutorial targets:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
rustup target add wasm32-unknown-unknown

rustc --version   # rustc 1.78.0 or later
cargo --version
```

**Revert:** `rustup self uninstall`

### 22e — Install lazygit

Not in apt — built from source using Go (a Go project, not C++).
Go 1.22 is available in Ubuntu 24.04 apt and is sufficient.
See `SOURCES.md → lazygit` for the full build reference.

```bash
sudo apt install golang-go   # Go 1.22 from Ubuntu 24.04

mkdir -p ~/build
git clone https://github.com/jesseduffield/lazygit.git ~/build/lazygit
cd ~/build/lazygit
git checkout $(git tag --sort=-v:refname | grep '^v' | head -1)   # latest tag

go build -ldflags="-s -w" -o lazygit .
sudo install -m 755 lazygit /usr/local/bin/
lazygit --version
```

Build time: ~1–2 minutes.

**Revert:** `sudo rm /usr/local/bin/lazygit`

### 22f — Bootstrap LazyVim

```bash
# Back up any existing Neovim config
mv ~/.config/nvim{,.bak} 2>/dev/null || true

# Clone the LazyVim starter
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# Launch Neovim — plugins install automatically
nvim
```

Wait for the plugin installation spinner in the status bar to finish. Quit
and reopen once done.

**Revert:** `rm -rf ~/.config/nvim && mv ~/.config/nvim.bak ~/.config/nvim 2>/dev/null || true`

### 22g — Enable language extras

Edit `~/.config/nvim/lazyvim.json`:

```json
{
  "extras": [
    "lazyvim.plugins.extras.editor.neo-tree",
    "lazyvim.plugins.extras.lang.rust",
    "lazyvim.plugins.extras.lang.clangd",
    "lazyvim.plugins.extras.dap.core"
  ],
  "install_version": 8,
  "version": 8
}
```

Then inside Neovim: `:Lazy sync` — installs rust-analyzer, clangd tooling,
codelldb debugger adapter, and Treesitter parsers.

### 22h — Apply Tokyo Night theme (transparent over Alacritty)

Neovim draws its own background unless the colorscheme sets **Normal** to
transparent. The vendored LazyVim plugin file in this repo enables Tokyo Night
**night** with `transparent = true` and forces `Normal` / floats to `NONE`.

**Deploy**

```bash
mkdir -p ~/.config/nvim/lua/plugins
cp ~/Development/Ricing/nvim/lua/plugins/theme.lua ~/.config/nvim/lua/plugins/theme.lua
```

If the repo path differs, copy from [`nvim/lua/plugins/theme.lua`](nvim/lua/plugins/theme.lua).

Then restart Neovim (or `:Lazy sync` then quit and reopen).

**If Enter, Tab, or Backspace act twice** (file tree toggles on one Enter, two
newlines per Return, etc.): this is **not** LazyVim — it is Neovim’s TUI extended-key
negotiation with the terminal (Kitty keyboard protocol). **Alacritty 0.13.x** with
**Neovim 0.11+** is a known bad pair; upgrade Alacritty when your distro allows, or
merge the autocommands from [`nvim/lua/config/autocmds.lua`](nvim/lua/config/autocmds.lua)
into `~/.config/nvim/lua/config/autocmds.lua` (create the file if you do not have one
yet; if LazyVim already created it, append the two `nvim_create_autocmd` blocks so you
do not remove your other autocommands). See [TERMINAL_OMARCHY.md](TERMINAL_OMARCHY.md#neovim-lazyvim-transparency-over-alacritty).

**If it is still opaque**

- Run `:hi Normal` — you want `guibg=NONE` (or cleared). If you see a hex colour,
  another plugin may be overriding after load; temporarily run `:hi Normal guibg=NONE`
  to confirm transparency works in that terminal.
- Ensure you are not using `TERM=xterm` without true colour; Alacritty should set
  `COLORTERM=truecolor` automatically.
- Remove or adjust any other `lua/plugins/*theme*` or colorscheme overrides that
  set a solid `Normal` background.

**Revert:** `rm ~/.config/nvim/lua/plugins/theme.lua` then `:Lazy sync`

### 22i — Disable arrow keys (optional — forces hjkl habit)

Create `~/.config/nvim/lua/config/keymaps.lua`:

```lua
for _, k in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
  vim.keymap.set({ "n", "i", "v" }, k, "<Nop>", { silent = true })
end
```

### Verify LSP is working

Open any `.rs` file. After ~5 seconds:
- `K` on a type → documentation popup
- `gd` on a function → jump to definition
- `:LspInfo` → shows `rust_analyzer` attached

Open a `.cpp` or `.c` file with `compile_commands.json` at the project root:
- `:LspInfo` → shows `clangd` attached

Run `:Mason` to confirm `rust-analyzer`, `clangd`, `taplo`, `codelldb` are installed.

### Generate compile_commands.json (C++ projects)

CMake projects:
```bash
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build .
ln -s build/compile_commands.json .
```

Non-CMake / Make projects:
```bash
bear -- make   # wraps your build and records compiler calls
```

### Full Neovim revert

```bash
rm -rf ~/.config/nvim
mv ~/.config/nvim.bak ~/.config/nvim 2>/dev/null || true
sudo rm /usr/local/bin/nvim
sudo rm /usr/local/bin/lazygit
rustup self uninstall          # if you installed Rust only for this
sudo apt remove nodejs npm    # if you installed Node only for this
rm -rf ~/.local/share/nvim     # Mason installs, plugin data
rm -rf ~/.local/state/nvim     # undo history, swap files
```

---

## Step 23 — Zen Browser (Tokyo Night)

Unchanged from original tutorial — see `ARCHIVE_X11/SETUP_X11.md Step 12`
for the full steps. Zen / Firefox run under XWayland automatically (no changes
needed). The `MOZ_ENABLE_WAYLAND=1` env set in `hyprland.conf` enables native
Wayland rendering if Zen supports it.

---

## Step 24 — CLion (Tokyo Night)

Unchanged from original tutorial — see `ARCHIVE_X11/SETUP_X11.md Step 19`.
CLion runs under XWayland automatically when launched from Hyprland.

---

## Full Revert — Back to KDE Plasma

```bash
# Restore all backed-up configs
cp -r ~/.config/hypr.bak         ~/.config/hypr         2>/dev/null || true
cp -r ~/.config/waybar.bak       ~/.config/waybar        2>/dev/null || true
cp -r ~/.config/wofi.bak         ~/.config/wofi          2>/dev/null || true
cp -r ~/.config/swaylock.bak     ~/.config/swaylock      2>/dev/null || true
cp -r ~/.config/dunst.bak        ~/.config/dunst         2>/dev/null || true
cp -r ~/.config/alacritty.bak    ~/.config/alacritty     2>/dev/null || true
cp    ~/.config/gtk-3.0/settings.ini.bak ~/.config/gtk-3.0/settings.ini 2>/dev/null || true
cp    ~/.config/gtk-4.0/settings.ini.bak ~/.config/gtk-4.0/settings.ini 2>/dev/null || true
cp    ~/.gtkrc-2.0.bak           ~/.gtkrc-2.0            2>/dev/null || true
cp    ~/.config/starship.toml.bak ~/.config/starship.toml 2>/dev/null || true
cp    ~/.config/btop/btop.conf.bak ~/.config/btop/btop.conf 2>/dev/null || true
cp    ~/.local/share/fish/fish_variables.bak \
      ~/.local/share/fish/fish_variables                  2>/dev/null || true

# Remove theme files (KDE uses its own theme store — not affected)
rm -rf ~/.themes/Tokyonight*
rm -rf ~/.config/Kvantum/TokyoNight*
rm -f  ~/.config/btop/themes/tokyo-night.theme

# Restore SDDM to Breeze (if Step 18 was done)
sudo tee /etc/sddm.conf.d/theme.conf > /dev/null <<'EOF'
[Theme]
Current=breeze
EOF
```

Log out and select **Plasma** from the SDDM session menu.
KDE Plasma is entirely separate — switching sessions leaves it exactly as you
left it.

---

## Quick Reference — Hyprland Keybindings

| Key | Action |
|-----|--------|
| `Super+Return` | Open terminal (alacritty) |
| `Super+Space` | Open launcher (wofi) |
| `Super+Shift+Q` | Close window |
| `Super+h/j/k/l` | Focus left/down/up/right |
| `Super+Shift+h/j/k/l` | Move window left/down/up/right |
| `Super+1…9, 0` | Switch workspace |
| `Super+Shift+1…9, 0` | Move window to workspace |
| `Super+F` | Fullscreen toggle |
| `Super+M` | Monocle (fullscreen without gaps) |
| `Super+R` | Resize mode (hjkl/arrows, Esc to exit) |
| `Super+Shift+Space` | Toggle floating |
| `Super+P` | Dwindle pseudotile |
| `Super+T` | Toggle dwindle split direction |
| `Super+L` | Lock screen (swaylock) |
| `Print` | Full screenshot → ~/Pictures |
| `Super+Shift+S` | Area screenshot → ~/Pictures |
| `Super+Shift+E` | Exit Hyprland |
| `Super+mouse drag` | Move window |
| `Super+right-click drag` | Resize window |
| `Super+scroll` | Switch workspace |
