# Source Repositories & Build Instructions

Each package listed in order of dependency. Build Step 1 first — each library
is required by the next. Everything else is optional (apt alternatives noted).

> The previous X11/i3 build instructions are in `ARCHIVE_X11/SOURCES_X11.md`.

---

## Prerequisites: GCC 14 (Ubuntu 24.04)

Ubuntu 24.04 ships GCC 13 by default. Hyprland v42 requires GCC 14. Install
and configure it before any of the source builds below:

```bash
sudo apt install gcc-14 g++-14
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 14 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-14 \
    --slave /usr/bin/gcov gcov /usr/bin/gcov-14

gcc --version   # confirm gcc-14 (Ubuntu …)
```

**Revert:** `sudo update-alternatives --set gcc /usr/bin/gcc-13`

---

## Step 1: Hyprland Build Chain

Build these in order. Each uses the same cmake pattern:

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
sudo cmake --build build --target install
```

All install to `/usr/local`. To uninstall any library:
```bash
sudo cmake --build build --target uninstall
# or manually: sudo rm $(cat build/install_manifest.txt)
```

---

### 1a — hyprwayland-scanner

Generates C++ Wayland protocol bindings. Needed before any other hypr library.

**Repo:** https://github.com/hyprwm/hyprwayland-scanner

```bash
cd ~/build/hypr
git clone https://github.com/hyprwm/hyprwayland-scanner.git
cd hyprwayland-scanner
git checkout $(git tag --sort=-v:refname | head -1)   # latest tag
cmake -B build -DCMAKE_BUILD_TYPE=Release
sudo cmake --build build --target install
cd ..
```

---

### 1b — hyprutils

Core utility library (smart pointers, signals, config helpers).

**Repo:** https://github.com/hyprwm/hyprutils

```bash
git clone https://github.com/hyprwm/hyprutils.git
cd hyprutils
git checkout $(git tag --sort=-v:refname | head -1)
cmake -B build -DCMAKE_BUILD_TYPE=Release
sudo cmake --build build --target install
cd ..
```

---

### 1c — hyprlang

The config language parser used by Hyprland config files.

**Repo:** https://github.com/hyprwm/hyprlang

```bash
git clone https://github.com/hyprwm/hyprlang.git
cd hyprlang
git checkout $(git tag --sort=-v:refname | head -1)
cmake -B build -DCMAKE_BUILD_TYPE=Release
sudo cmake --build build --target install
cd ..
```

---

### 1d — hyprland-protocols

Hyprland-specific Wayland protocol extensions.

**Repo:** https://github.com/hyprwm/hyprland-protocols

```bash
git clone https://github.com/hyprwm/hyprland-protocols.git
cd hyprland-protocols
git checkout $(git tag --sort=-v:refname | head -1)
meson setup build --prefix=/usr/local
ninja -C build
sudo ninja -C build install
cd ..
```

---

### 1e — aquamarine

The DRM/KMS/Vulkan rendering backend for Hyprland.

**Repo:** https://github.com/hyprwm/aquamarine

Additional deps (install first if not already present):
```bash
sudo apt install libseat-dev libdrm-dev libgbm-dev libinput-dev \
                 libdisplay-info-dev libvulkan-dev libudev-dev
```

```bash
git clone https://github.com/hyprwm/aquamarine.git
cd aquamarine
git checkout $(git tag --sort=-v:refname | head -1)
cmake -B build -DCMAKE_BUILD_TYPE=Release
sudo cmake --build build --target install
cd ..
```

---

### 1f — hyprgraphics

Image loading and rendering helpers (needed for Hyprland v0.45+).

**Repo:** https://github.com/hyprwm/hyprgraphics

```bash
sudo apt install libwebp-dev libjpeg-dev libpng-dev

git clone https://github.com/hyprwm/hyprgraphics.git
cd hyprgraphics
git checkout $(git tag --sort=-v:refname | head -1)
cmake -B build -DCMAKE_BUILD_TYPE=Release
sudo cmake --build build --target install
cd ..
```

---

### 1g — Hyprland (main)

After all dependencies above are installed:

**Repo:** https://github.com/hyprwm/Hyprland

```bash
git clone --recursive https://github.com/hyprwm/Hyprland.git
cd Hyprland

# List available tags and pick your target (v42 is the tested version for this tutorial):
git tag --sort=-v:refname | head -10
git checkout v42   # replace with your chosen tag

make all
sudo make install
```

If `make all` fails with a missing library error:
1. Note the library name in the error
2. Check if it has an apt package: `apt-cache search <libname>`
3. If not, it likely needs its own source build — check the Hyprland wiki
   at https://wiki.hyprland.org/Getting-Started/Installation/

**Verify:**
```bash
Hyprland --version
ls /usr/local/share/wayland-sessions/hyprland.desktop
# Then follow SETUP.md Step 2 to symlink this into /usr/share/wayland-sessions/
# so SDDM can find it.
```

**Uninstall:**
```bash
cd ~/build/hypr/Hyprland
sudo make uninstall
```

---

## Neovim (text editor)

The apt package is too old. Build from the `stable` branch for 0.10+.
`cmake`, `ninja-build`, and `git` are already installed from Step 0.

**Repo:** https://github.com/neovim/neovim

```bash
sudo apt install gettext   # only extra dep not already in Step 0

mkdir -p ~/build
git clone https://github.com/neovim/neovim.git ~/build/neovim
cd ~/build/neovim
git checkout stable

make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
# Installs: /usr/local/bin/nvim
#           /usr/local/share/nvim/
#           /usr/local/lib/nvim/
```

**Verify:** `nvim --version`  — should show NVIM v0.10 or later.

**Uninstall:**
```bash
cd ~/build/neovim && sudo make uninstall
```

---

## lazygit (terminal Git UI)

A Go project — build with Go 1.22 from Ubuntu 24.04 apt.

**Repo:** https://github.com/jesseduffield/lazygit

```bash
sudo apt install golang-go

mkdir -p ~/build
git clone https://github.com/jesseduffield/lazygit.git ~/build/lazygit
cd ~/build/lazygit
git checkout $(git tag --sort=-v:refname | grep '^v' | head -1)

go build -ldflags="-s -w" -o lazygit .
sudo install -m 755 lazygit /usr/local/bin/
```

**Verify:** `lazygit --version`

**Uninstall:** `sudo rm /usr/local/bin/lazygit`

---

## hypridle (idle / auto-lock daemon)

Omarchy-native idle manager: dims display, locks screen, powers off monitor.
Not in Ubuntu apt — same cmake build as the other hypr tools.

**Repo:** https://github.com/hyprwm/hypridle

```bash
# libsdbus-c++-dev may not be available on all company apt mirrors.
# If it's missing, libsystemd-dev is the Ubuntu 24.04 fallback:
sudo apt install libwayland-dev libxkbcommon-dev libsystemd-dev libsdbus-c++-dev 2>/dev/null || \
sudo apt install libwayland-dev libxkbcommon-dev libsystemd-dev

git clone https://github.com/hyprwm/hypridle.git
cd hypridle
git checkout $(git tag --sort=-v:refname | head -1)
cmake -B build -DCMAKE_BUILD_TYPE=Release
sudo cmake --build build --target install
```

After building, add `exec-once = hypridle` to `hyprland.conf` and create
`~/.config/hypr/hypridle.conf` (see SETUP.md Step 9b).

**Uninstall:** `sudo cmake --build build --target uninstall` from the source dir.

---

## swaylock-effects (blur on lock screen)

The apt `swaylock` package shows a solid colour. `swaylock-effects` is a fork
that adds `--screenshots` and `--effect-blur`. The existing `swaylock/config`
works with both — just add these two lines to enable blur:

```
screenshots
effect-blur=7x5
```

**Repo:** https://github.com/mortie/swaylock-effects

```bash
sudo apt install libwayland-dev wayland-protocols libxkbcommon-dev \
                 libcairo2-dev libgdk-pixbuf2.0-dev libpam0g-dev

git clone https://github.com/mortie/swaylock-effects.git
cd swaylock-effects
meson setup build
ninja -C build
sudo ninja -C build install
# Installs to /usr/local/bin/swaylock (shadows the apt package)
```

**Revert:** `sudo rm /usr/local/bin/swaylock` — the apt `swaylock` at
`/usr/bin/swaylock` takes over again.

---

## hyprpaper (animated / per-monitor wallpaper)

Drop-in replacement for `swaybg`. Supports animated wallpapers (`.gif`/`.mp4`)
and per-monitor wallpaper control.

**Repo:** https://github.com/hyprwm/hyprpaper

```bash
sudo apt install libcairo2-dev libwebp-dev libjpeg-dev libxkbcommon-dev

git clone https://github.com/hyprwm/hyprpaper.git
cd hyprpaper
cmake -B build -DCMAKE_BUILD_TYPE=Release
sudo cmake --build build --target install
```

To use: replace the `exec-once = swaybg …` line in `hyprland.conf` with:
```
exec-once = hyprpaper
```

And create `~/.config/hypr/hyprpaper.conf`:
```
preload = ~/Pictures/wallpaper.jpg
wallpaper = ,~/Pictures/wallpaper.jpg
```

---

## hyprlock (native Hyprland lock screen)

Hyprland's own lock screen — tighter integration than swaylock.

**Repo:** https://github.com/hyprwm/hyprlock

```bash
sudo apt install libwayland-dev libxkbcommon-dev libcairo2-dev \
                 libpango1.0-dev libgdk-pixbuf2.0-dev libpam0g-dev \
                 libgles2-mesa-dev

git clone https://github.com/hyprwm/hyprlock.git
cd hyprlock
cmake -B build -DCMAKE_BUILD_TYPE=Release
sudo cmake --build build --target install
```

Update the keybind in `hyprland.conf`:
```
bind = $mod, L, exec, hyprlock
```

---

## xdg-desktop-portal-hyprland

Better screensharing and file picker integration than the generic `-wlr` portal.

**Repo:** https://github.com/hyprwm/xdg-desktop-portal-hyprland

```bash
sudo apt install libwayland-dev libpipewire-0.3-dev \
                 qt6-wayland qt6-base-dev

git clone https://github.com/hyprwm/xdg-desktop-portal-hyprland.git
cd xdg-desktop-portal-hyprland
cmake -B build -DCMAKE_BUILD_TYPE=Release
sudo cmake --build build --target install
```

Update the `exec-once` lines in `hyprland.conf`:
```
exec-once = /usr/local/libexec/xdg-desktop-portal-hyprland
exec-once = /usr/libexec/xdg-desktop-portal --replace
```

---

## Nerd Fonts — JetBrains Mono

Not on apt. Install from the Nerd Fonts release archive (no compilation):

```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip -d JetBrainsMono
rm JetBrainsMono.zip
fc-cache -fv
```

---

## Tokyo Night GTK Theme

No compilation — extract from GitHub release:

```bash
mkdir -p ~/.themes
wget https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme/archive/refs/heads/master.zip \
    -O /tmp/tokyonight-gtk.zip
unzip /tmp/tokyonight-gtk.zip -d /tmp/tokyonight-gtk
cp -r /tmp/tokyonight-gtk/Tokyo-Night-GTK-Theme-master/themes/* ~/.themes/
rm -rf /tmp/tokyonight-gtk /tmp/tokyonight-gtk.zip
```

Variants (use `Tokyonight-Dark-B` — darkest):

- `Tokyonight-Dark-B` — pure dark, no light elements
- `Tokyonight-Storm-B` — slightly lighter blue tint

---

## Tokyo Night Kvantum Theme (Qt apps — Dolphin, etc.)

Same repo as the GTK theme. Kvantum packages are in its `Kvantum/` folder:

```bash
sudo apt install qt5-style-kvantum qt5-style-kvantum-themes

mkdir -p ~/.config/Kvantum
wget https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme/archive/refs/heads/master.zip \
    -O /tmp/tokyonight-gtk.zip
unzip /tmp/tokyonight-gtk.zip -d /tmp/tokyonight-gtk
cp -r /tmp/tokyonight-gtk/Tokyo-Night-GTK-Theme-master/Kvantum/* ~/.config/Kvantum/
rm -rf /tmp/tokyonight-gtk /tmp/tokyonight-gtk.zip
```

Then open `kvantummanager` → select `TokyoNight` → Use this theme.

---

## SDDM Astronaut Theme (Tokyo Night variant)

No compilation. Clone and copy:

```bash
sudo apt install qml-module-qtquick-controls qml-module-qtquick-controls2 \
    qml-module-qtgraphicaleffects qml-module-qtquick-layouts

git clone https://github.com/Keyitdev/sddm-astronaut-theme.git
sudo cp -r sddm-astronaut-theme /usr/share/sddm/themes/
rm -rf sddm-astronaut-theme

sudo cp /usr/share/sddm/themes/sddm-astronaut-theme/Themes/tokyo-night.conf \
        /usr/share/sddm/themes/sddm-astronaut-theme/theme.conf
```

Then set it active — see SETUP.md Step 18.
