# Source Repositories & Build Instructions

Each package listed in order of priority. Try `apt install <pkg>` first;
fall back to building from source if it's missing from your mirror.

---

## i3lock-color
**Repo:** https://github.com/Raymo111/i3lock-color  
*(Not on apt — must compile from source)*

```bash
sudo apt install autoconf automake pkg-config libpam0g-dev libcairo2-dev \
    libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev \
    libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev \
    libxcb-image0-dev libxcb-util-dev libxcb-xrm-dev \
    libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev

git clone https://github.com/Raymo111/i3lock-color.git
cd i3lock-color
./build.sh
# Binary installs to /usr/local/bin/i3lock-color
# Verify: i3lock-color --version
```

---

## autorandr
**Package:** `autorandr`  
Available on apt:

```bash
sudo apt install autorandr arandr
```

If missing from mirror:  
**Repo:** https://github.com/phillipberndt/autorandr

```bash
git clone https://github.com/phillipberndt/autorandr.git
cd autorandr
sudo make install
```

---

## SDDM Astronaut Theme (Tokyo Night variant)
**Repo:** https://github.com/Keyitdev/sddm-astronaut-theme  
*(Not on apt — extract from release)*

```bash
sudo apt install qt5-declarative-dev qml-module-qtquick-controls \
    qml-module-qtquick-controls2 qml-module-qtgraphicaleffects \
    qml-module-qtquick-layouts

git clone https://github.com/Keyitdev/sddm-astronaut-theme.git
sudo cp -r sddm-astronaut-theme /usr/share/sddm/themes/
```

Then set the tokyo-night config variant — see SETUP.md Step 16.

---

## alacritty
**Repo:** https://github.com/alacritty/alacritty  
**Requires:** Rust toolchain (rustup)

```bash
# Install Rust if not present
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# Build deps
sudo apt install cmake pkg-config \
    libfreetype6-dev libfontconfig1-dev \
    libxcb-xfixes0-dev libxkbcommon-dev python3

# Clone and build
git clone https://github.com/alacritty/alacritty.git
cd alacritty
cargo build --release

# Install
sudo cp target/release/alacritty /usr/local/bin/
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database
```

---

## rofi
**Repo:** https://github.com/davatorium/rofi  
**Requires:** meson, ninja

```bash
sudo apt install meson ninja-build \
    libxcb-util-dev libxcb-ewmh-dev libxcb-icccm4-dev \
    libxcb-xinerama0-dev libxcb-randr0-dev libxcb-xkb-dev \
    libxkbcommon-x11-dev libglib2.0-dev libpango1.0-dev \
    libcairo2-dev libgdk-pixbuf2.0-dev librsvg2-dev check

git clone https://github.com/davatorium/rofi.git
cd rofi
git submodule update --init
meson setup build
ninja -C build
sudo ninja -C build install
```

---

## picom
**Repo:** https://github.com/yshui/picom  
**Requires:** meson, ninja

```bash
sudo apt install meson ninja-build \
    libx11-dev libxext-dev libxcomposite-dev libxdamage-dev \
    libxfixes-dev libxrandr-dev libxinerama-dev libpcre2-dev \
    libgl-dev libev-dev libconfig-dev libdbus-1-dev \
    libxdg-basedir-dev uthash-dev libpixman-1-dev libepoxy-dev

git clone https://github.com/yshui/picom.git
cd picom
git submodule update --init --recursive
meson setup --buildtype=release build
ninja -C build
sudo ninja -C build install
```

---

## dunst
**Repo:** https://github.com/dunst-project/dunst  
**Requires:** make, pkg-config

```bash
sudo apt install libdbus-1-dev libx11-dev libxinerama-dev \
    libxrandr-dev libxss-dev libglib2.0-dev libpango1.0-dev \
    libgtk-3-dev libnotify-dev libxdg-basedir-dev

git clone https://github.com/dunst-project/dunst.git
cd dunst
make
sudo make install
```

---

## feh
**Repo:** https://github.com/derf/feh  
**Requires:** make, imlib2

```bash
sudo apt install libcurl4-openssl-dev libexif-dev \
    libx11-dev libxt-dev libjpeg-dev libpng-dev \
    libxinerama-dev libimlib2-dev

git clone https://github.com/derf/feh.git
cd feh
make
sudo make install
```

---

## i3status
**Repo:** https://github.com/i3/i3status  
**Requires:** meson, ninja  
*(Usually ships with i3 on Ubuntu — only build if missing)*

```bash
sudo apt install meson ninja-build \
    libconfuse-dev libyajl-dev libasound2-dev \
    libpulse-dev libcap-dev libnl-genl-3-dev

git clone https://github.com/i3/i3status.git
cd i3status
meson setup build
ninja -C build
sudo ninja -C build install
```

---

## scrot
**Repo:** https://github.com/resurrecting-open-source-projects/scrot  
**Requires:** autoconf, automake

```bash
sudo apt install libimlib2-dev libxcomposite-dev \
    libxfixes-dev autoconf automake libtool

git clone https://github.com/resurrecting-open-source-projects/scrot.git
cd scrot
./autogen.sh
./configure
make
sudo make install
```

---

## JetBrains Mono Nerd Font
**Repo:** https://github.com/ryanoasis/nerd-fonts  
*(Not on apt — install manually from releases)*

```bash
# Download just the JetBrainsMono family (smaller than cloning the full repo)
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip -d JetBrainsMono
rm JetBrainsMono.zip
fc-cache -fv
```

---

## Tokyo Night GTK Theme
**Repo:** https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme  
*(Not on apt — extract from release, no compilation needed)*

```bash
mkdir -p ~/.themes
wget https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme/archive/refs/heads/master.zip \
    -O /tmp/tokyonight-gtk.zip
unzip /tmp/tokyonight-gtk.zip -d /tmp/tokyonight-gtk
cp -r /tmp/tokyonight-gtk/Tokyo-Night-GTK-Theme-master/themes/* ~/.themes/
rm -rf /tmp/tokyonight-gtk /tmp/tokyonight-gtk.zip
```

Variants installed (use `Tokyonight-Dark-B` — darkest):
- `Tokyonight-Dark-B` — pure dark, no light elements
- `Tokyonight-Storm-B` — slightly lighter blue tint
- `Tokyonight-Dark-B-LB` — dark with light bar (ignore this one)

---

## Tokyo Night Kvantum Theme (Qt apps — Dolphin, etc.)
**Repo:** https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme  
*(Same repo — Kvantum themes are in the `Kvantum/` folder)*

```bash
sudo apt install qt5-style-kvantum qt5-style-kvantum-themes

mkdir -p ~/.config/Kvantum
wget https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme/archive/refs/heads/master.zip \
    -O /tmp/tokyonight-gtk.zip
unzip /tmp/tokyonight-gtk.zip -d /tmp/tokyonight-gtk
cp -r /tmp/tokyonight-gtk/Tokyo-Night-GTK-Theme-master/Kvantum/* ~/.config/Kvantum/
rm -rf /tmp/tokyonight-gtk /tmp/tokyonight-gtk.zip
```

Then open `kvantummanager` and select `TokyoNight` from the theme list.

---

## capitaine-cursors
**Package:** `capitaine-cursors`  
Available on apt — no source build needed:

```bash
sudo apt install capitaine-cursors
```

If missing from mirror:  
**Repo:** https://github.com/keeferrourke/capitaine-cursors

```bash
sudo apt install inkscape python3 xorg-dev

git clone https://github.com/keeferrourke/capitaine-cursors.git
cd capitaine-cursors
./build.sh
mkdir -p ~/.local/share/icons
cp -r dist/dark ~/.local/share/icons/capitaine-cursors
```

---

## xsettingsd
**Package:** `xsettingsd`  
Available on apt:

```bash
sudo apt install xsettingsd
```

If missing from mirror:  
**Repo:** https://github.com/derat/xsettingsd

```bash
sudo apt install libglib2.0-dev

git clone https://github.com/derat/xsettingsd.git
cd xsettingsd
make
sudo cp xsettingsd /usr/local/bin/
```
