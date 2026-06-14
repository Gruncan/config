# Desktop Rice Setup Guide
**Target:** Kubuntu 24.04 · KDE Plasma · X11  
**Style:** Omarchy-inspired · Tokyo Night Dark · i3 + i3bar

Work through each step in order. Every step backs up the existing file before
touching it, and every step has a one-line revert. Stop at any point — nothing
done so far will break anything that came before.

---

## Before you start

Clone or copy this repo to the Kubuntu machine:
```bash
git clone <your-repo-url> ~/Development/Ricing
# or just scp/copy the folder across
```

Confirm i3 is installed:
```bash
i3 --version
```
If not: `sudo apt install i3`

---

## Step 0 — Packages

Install everything in one go. If a package is missing from your mirror, see
`SOURCES.md` for the build-from-source instructions for that specific package.

```bash
sudo apt install \
    alacritty \
    rofi \
    picom \
    dunst \
    feh \
    scrot \
    i3status \
    i3lock \
    brightnessctl \
    papirus-icon-theme \
    fonts-jetbrains-mono \
    libnotify-bin \
    playerctl
```

Check which packages were skipped by your mirror:
```bash
for p in alacritty rofi picom dunst feh scrot i3status i3lock \
          brightnessctl papirus-icon-theme fonts-jetbrains-mono \
          libnotify-bin playerctl; do
    dpkg -s "$p" &>/dev/null && echo "OK  $p" || echo "MISSING  $p"
done
```

For any `MISSING` entry, refer to `SOURCES.md`.

**Revert:** `sudo apt remove <package>` — no config files are touched by this step.

---

## Step 0b — Version checks

Run these before deploying configs — some versions need small config adjustments.

```bash
alacritty --version   # Need >= 0.12 for TOML config
picom --version       # Need >= 8.0  for corner-radius
dunst --version       # Need >= 1.9  for origin/offset syntax
i3 --version          # Need >= 4.22 for built-in gaps
i3status --version    # Any version is fine
```

### If alacritty < 0.12
The `alacritty.toml` config will be ignored. You need YAML format instead.
Run this on the Kubuntu machine and share the output — I'll generate an
`alacritty.yml` equivalent.

### If picom < 8.0
Comment out the corner-radius block before deploying:
```bash
# In picom/picom.conf, comment out:
# corner-radius = 6;
# rounded-corners-exclude = { ... };
```

### If dunst < 1.9
Replace the position block in `dunst/dunstrc` with the legacy format:
```
geometry = "360x5-20+45"
```
and remove the `origin`, `offset`, `width`, `height`, `gap_size` lines.

### If i3 < 4.22
Comment out the gaps lines in `i3/config`:
```
# gaps inner 8
# gaps outer 4
```

---

## Step 1 — i3 config

**What this does:** Replaces your i3 window manager config. Sets Tokyo Night
colours, keybindings, gaps, and the i3bar. Only affects the i3 session —
your KDE Plasma session is completely untouched.

### Note on the KDE menu bar (File · Edit · View)
This is one of the things that goes away automatically. Alacritty has zero
window chrome — no menu bar, no toolbar, no tab strip, no title bar buttons.
It is a pure GPU-rendered canvas. Once you are in i3 using Alacritty, those
bars simply do not exist. If you ever open a KDE app (Dolphin, etc.) from
within i3 and want to hide its menu bar temporarily: `Ctrl+M` toggles it in
most KDE apps.

### Check polkit agent path first

The i3 config starts a polkit authentication agent (needed for sudo dialogs in GUI apps).
Kubuntu ships the KDE agent — verify the path exists before deploying:

```bash
ls /usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1
```

If that file is missing, check for the GNOME one instead:
```bash
ls /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1
# If found, edit i3/config and swap the commented lines in the polkit block
```

### Backup
```bash
cp -r ~/.config/i3 ~/.config/i3.bak
```

### Deploy
```bash
mkdir -p ~/.config/i3
cp ~/Development/Ricing/i3/config         ~/.config/i3/config
cp ~/Development/Ricing/i3/i3status.conf  ~/.config/i3/i3status.conf
```

### Verify (without logging out)
```bash
i3 -C ~/.config/i3/config
```
Exit code 0 = config is valid. Any errors will print to stdout.

### Apply
Log out of KDE Plasma. At the SDDM login screen, click the session selector
(bottom-left or top-right depending on your SDDM theme) and choose **i3**.
Log in.

`Super+Return` → opens alacritty  
`Super+d` → opens rofi launcher  
`Super+Shift+e` → exit i3 (returns to SDDM)

### Revert
```bash
cp -r ~/.config/i3.bak ~/.config/i3
# Then restart i3: Super+Shift+r, or log out and back in
```

---

## Step 2 — i3status (bar content)

**What this does:** Configures what appears in the right side of the i3bar:
disk space, CPU, memory, network, battery, volume, clock.

Already deployed with Step 1. This step is for adjusting it to your hardware.

### Customise for your machine

**No battery (desktop):** Open `~/.config/i3/i3status.conf` and comment out:
```
# order += "battery all"
# battery all { ... }
```

**No wireless:** Comment out:
```
# order += "wireless _first_"
# wireless _first_ { ... }
```

**PipeWire instead of ALSA:** The `volume master` block may not work. Replace with:
```
order += "tztime local"
# remove the volume block entirely
```
Volume will still work via the media keys in i3/config — just won't show in the bar.

### Reload bar without logging out
```bash
i3-msg reload
```

### Revert
```bash
cp ~/Development/Ricing/i3/i3status.conf ~/.config/i3/i3status.conf
i3-msg reload
```

---

## Step 3 — Alacritty (terminal)

**What this does:** Gives alacritty Tokyo Night Dark colours, JetBrains Mono
font at 12pt, subtle transparency (96%), block cursor with blink, and sane
keyboard shortcuts. No menu bar — that is the entire point of alacritty.

### Backup
```bash
cp -r ~/.config/alacritty ~/.config/alacritty.bak 2>/dev/null || true
```

### Deploy
```bash
mkdir -p ~/.config/alacritty
cp ~/Development/Ricing/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
```

### Verify
Alacritty hot-reloads its config — open a terminal and the colours change
immediately. No restart needed.

If the terminal looks wrong (wrong colours, font fallback boxes for icons):
- Wrong colours → confirm `alacritty --version` is ≥ 0.12
- Box characters instead of icons → Nerd Font not installed (see Step 0c below)

### Font fallback
If JetBrainsMono Nerd Font is not yet installed, the config will fall back
gracefully to whatever monospace font is available. Icons in the bar will show
as □ but the terminal itself will work fine.

### Revert
```bash
cp -r ~/.config/alacritty.bak ~/.config/alacritty
```

---

## Step 0c — Nerd Font (do this if you see □ characters)

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

Alacritty hot-reloads — icons appear immediately without restart.

**Revert:** Delete `~/.local/share/fonts/JetBrainsMono/` and run `fc-cache -fv`.

---

## Step 4 — Rofi (application launcher)

**What this does:** Styles the `Super+d` launcher as a centred Tokyo Night
spotlight panel — fixed 600px wide, 8 results visible, blue left-border on
selection.

### Backup
```bash
cp -r ~/.config/rofi ~/.config/rofi.bak 2>/dev/null || true
```

### Deploy
```bash
mkdir -p ~/.config/rofi
cp ~/Development/Ricing/rofi/config.rasi ~/.config/rofi/config.rasi
```

### Verify
```bash
rofi -show drun
```
Press `Escape` to dismiss. The panel should appear centred with the dark
Tokyo Night background and blue border.

If rofi opens but looks unstyled (grey default theme): confirm the file is at
`~/.config/rofi/config.rasi` exactly — rofi is strict about the path.

### Revert
```bash
cp -r ~/.config/rofi.bak ~/.config/rofi
# or to go back to rofi defaults:
rm ~/.config/rofi/config.rasi
```

---

## Step 5 — Picom (compositor)

**What this does:** Adds window shadows, fade animations on open/close, and
rounded corners (6px). Alacritty's 96% opacity also requires picom to be
running. Started automatically by i3 on login.

### Backup
```bash
cp ~/.config/picom/picom.conf ~/.config/picom.conf.bak 2>/dev/null || true
```

### Deploy
```bash
mkdir -p ~/.config/picom
cp ~/Development/Ricing/picom/picom.conf ~/.config/picom/picom.conf
```

### Start / restart picom manually (without logging out)
```bash
# Kill existing instance if running
pkill picom 2>/dev/null || true
# Start fresh
picom --backend glx -b
```

### If you see screen tearing or glx errors
Switch the backend to xrender:
```bash
# In ~/.config/picom/picom.conf change:
backend = "xrender";
# and remove: glx-no-stencil and glx-copy-from-front lines
```

### If corner-radius causes an error (picom < 8.0)
```bash
sed -i '/corner-radius/d; /rounded-corners-exclude/,/};/d' ~/.config/picom/picom.conf
pkill picom; picom --backend glx -b
```

### Disable picom entirely (if you hit driver issues)
```bash
pkill picom
# Comment out in ~/.config/i3/config:
# exec --no-startup-id picom --backend glx -b
i3-msg reload
```

### Revert
```bash
pkill picom
cp ~/.config/picom.conf.bak ~/.config/picom/picom.conf
picom --backend glx -b
```

---

## Step 6 — Dunst (notifications)

**What this does:** Replaces KDE's notification daemon with dunst. Notifications
appear top-right with Tokyo Night colours: grey border for low urgency, blue for
normal, red for critical. Started automatically by i3 on login.

### Backup
```bash
cp -r ~/.config/dunst ~/.config/dunst.bak 2>/dev/null || true
```

### Deploy
```bash
mkdir -p ~/.config/dunst
cp ~/Development/Ricing/dunst/dunstrc ~/.config/dunst/dunstrc
```

### Start / restart dunst manually
```bash
pkill dunst 2>/dev/null || true
dunst &
```

### Test it
```bash
# Low urgency
notify-send -u low "Test" "This is a low urgency notification"

# Normal
notify-send "Test" "This is a normal notification"

# Critical — stays until clicked
notify-send -u critical "Test" "Critical — click to dismiss"
```

### Revert
```bash
pkill dunst
cp -r ~/.config/dunst.bak ~/.config/dunst
dunst &
```

---

## Step 7 — Wallpaper (feh)

**What this does:** feh sets the desktop wallpaper on i3 start. No daemon,
no config file — just a single command in `~/.config/i3/config`.

### Add your wallpaper
```bash
mkdir -p ~/Pictures
cp /path/to/your/image.jpg ~/Pictures/wallpaper.jpg
```

### Change wallpaper without logging out
```bash
feh --no-fehbg --bg-fill ~/Pictures/wallpaper.jpg
```

### Point i3 to a different path
Edit `~/.config/i3/config` and change the feh line:
```
exec --no-startup-id feh --no-fehbg --bg-fill ~/Pictures/wallpaper.jpg
```
Then `Super+Shift+r` to reload i3.

### Recommended wallpapers for Tokyo Night
Dark, minimal, abstract — anything with deep blues and purples.
- Search: `unsplash.com` → "dark abstract blue"
- Or grab one of the wallpapers shipped with Omarchy themes (they're MIT licensed)

---

## Step 8 — Tokyo Night GTK theme

**What this does:** Makes all GTK3/GTK4 apps (Nautilus, Thunar, GTK-based settings
panels) use Tokyo Night Dark colours and styling. No compilation — extract and copy.

### Install the theme
```bash
mkdir -p ~/.themes
wget https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme/archive/refs/heads/master.zip \
    -O /tmp/tokyonight-gtk.zip
unzip /tmp/tokyonight-gtk.zip -d /tmp/tokyonight-gtk
cp -r /tmp/tokyonight-gtk/Tokyo-Night-GTK-Theme-master/themes/* ~/.themes/
rm -rf /tmp/tokyonight-gtk /tmp/tokyonight-gtk.zip
```

Verify theme files are present:
```bash
ls ~/.themes/ | grep Tokyonight
# Should show: Tokyonight-Dark-B, Tokyonight-Storm-B, and others
```

We use `Tokyonight-Dark-B` — the darkest, closest to the i3 palette we set.

**Revert:** `rm -rf ~/.themes/Tokyonight*`

---

## Step 9 — Icons and cursor

**What this does:** Switches icons to Papirus-Dark (clean, flat, dark-friendly) and
the cursor to capitaine-cursors (minimal, legible on dark backgrounds).

### Icons
```bash
sudo apt install papirus-icon-theme
```

If missing from mirror — Papirus is also available as a direct install:
```bash
wget -qO- https://git.io/papirus-icon-theme-install | DESTDIR="$HOME/.local/share/icons" sh
```

### Cursor
```bash
sudo apt install capitaine-cursors
```

If missing from mirror, see `SOURCES.md → capitaine-cursors`.

**Revert:** `sudo apt remove papirus-icon-theme capitaine-cursors`

---

## Step 10 — Apply GTK settings

**What this does:** Writes the theme, icon, cursor, and font choices into the GTK
config files and starts `xsettingsd` so running apps pick up the changes without
needing a full logout.

### Install xsettingsd
```bash
sudo apt install xsettingsd
```
If missing: see `SOURCES.md → xsettingsd`.

### Backup existing GTK config
```bash
cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini.bak 2>/dev/null || true
cp ~/.config/gtk-4.0/settings.ini ~/.config/gtk-4.0/settings.ini.bak 2>/dev/null || true
cp ~/.gtkrc-2.0 ~/.gtkrc-2.0.bak 2>/dev/null || true
cp ~/.config/xsettingsd/xsettingsd.conf ~/.config/xsettingsd/xsettingsd.conf.bak 2>/dev/null || true
```

### Deploy
```bash
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0 ~/.config/xsettingsd

cp ~/Development/Ricing/gtk/settings.ini      ~/.config/gtk-3.0/settings.ini
cp ~/Development/Ricing/gtk/gtk4-settings.ini ~/.config/gtk-4.0/settings.ini
cp ~/Development/Ricing/gtk/gtkrc-2.0         ~/.gtkrc-2.0
cp ~/Development/Ricing/xsettingsd/xsettingsd.conf ~/.config/xsettingsd/xsettingsd.conf
```

### Apply without logging out
```bash
pkill xsettingsd 2>/dev/null || true
xsettingsd &
```

Open any GTK app (Thunar, a settings panel) — it should immediately show the new theme.

> **GTK4 caveat:** Apps built with libadwaita (newer GNOME apps) largely ignore
> the GTK4 settings file and require an additional override. If you see a GNOME
> app that refuses to theme, add this to your i3 autostart (already in i3/config):
> ```
> exec --no-startup-id gsettings set org.gnome.desktop.interface color-scheme prefer-dark
> ```
> Then `Super+Shift+r`. This forces dark mode in libadwaita apps.

### Also apply via gsettings (belt and braces)
```bash
gsettings set org.gnome.desktop.interface gtk-theme        'Tokyonight-Dark-B'
gsettings set org.gnome.desktop.interface icon-theme       'Papirus-Dark'
gsettings set org.gnome.desktop.interface cursor-theme     'capitaine-cursors'
gsettings set org.gnome.desktop.interface cursor-size      24
gsettings set org.gnome.desktop.interface font-name        'JetBrains Mono 10'
gsettings set org.gnome.desktop.interface color-scheme     'prefer-dark'
```

### Revert
```bash
cp ~/.config/gtk-3.0/settings.ini.bak ~/.config/gtk-3.0/settings.ini
cp ~/.config/gtk-4.0/settings.ini.bak ~/.config/gtk-4.0/settings.ini
cp ~/.gtkrc-2.0.bak ~/.gtkrc-2.0
pkill xsettingsd; xsettingsd &
```

---

## Step 11 — Qt / KDE apps (Dolphin, KDE settings, etc.)

**What this does:** KDE apps like Dolphin use Qt, not GTK. Without this step they
will ignore the GTK theme and render in the default Breeze style (light or dark
depending on KDE settings). Kvantum lets you apply a matching Tokyo Night skin.

### Install Kvantum
```bash
sudo apt install qt5-style-kvantum qt5-style-kvantum-themes
```

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
```bash
# For Qt5
echo 'QT_STYLE_OVERRIDE=kvantum' >> ~/.profile

# For Qt6 (if needed)
echo 'QT6_STYLE_OVERRIDE=kvantum' >> ~/.profile
```

Log out and back in (to i3), or source your profile and relaunch the app:
```bash
source ~/.profile
```

### Revert
```bash
# Remove the QT_STYLE_OVERRIDE line from ~/.profile
# Open kvantummanager and switch back to Default
```

---

## Step 12 — Zen browser (Tokyo Night)

Zen is a Firefox fork — it supports Firefox themes and `userChrome.css`.

### Option A — Firefox/Zen theme add-on (quickest)

1. Open Zen
2. Go to `about:addons` → Extensions → search **"Tokyo Night"**
3. Install the theme by **enkia** (the reference implementation)
4. Activate it from the Themes tab

This themes the browser chrome (tabs, toolbar, sidebar) to Tokyo Night.

### Option B — userChrome.css (full control, no add-on)

Enable userChrome.css first:
1. Open `about:config`
2. Search `toolkit.legacyUserProfileCustomizations.stylesheets`
3. Set to `true`

Find your profile folder:
```bash
# Open about:support in Zen, look for "Profile Directory", then:
ls ~/.zen/  # or ~/.mozilla/firefox/ depending on Zen version
# The profile folder contains a 'chrome' subdirectory
```

Create `chrome/userChrome.css` in your profile folder. A minimal Tokyo Night
override that colours the toolbar and tabs:

```css
/* Tokyo Night Dark — Zen / Firefox userChrome.css */
:root {
    --tn-bg:      #1a1b26;
    --tn-bg-dark: #16161e;
    --tn-bg-hi:   #292e42;
    --tn-fg:      #c0caf5;
    --tn-blue:    #7aa2f7;
    --tn-comment: #565f89;
}

/* Toolbar */
#nav-bar, #toolbar-menubar, #TabsToolbar {
    background-color: var(--tn-bg-dark) !important;
    color: var(--tn-fg) !important;
    border-color: var(--tn-bg-hi) !important;
}

/* Active tab */
.tabbrowser-tab[selected] .tab-background {
    background-color: var(--tn-bg) !important;
}

/* Inactive tabs */
.tabbrowser-tab:not([selected]) .tab-background {
    background-color: var(--tn-bg-dark) !important;
}

/* URL bar */
#urlbar-background {
    background-color: var(--tn-bg-hi) !important;
    border-color: var(--tn-blue) !important;
}

/* Sidebar (Zen-specific) */
#sidebar-box {
    background-color: var(--tn-bg-dark) !important;
}
```

Restart Zen to apply.

> **Note:** Zen ships with its own sidebar and workspace UI. The userChrome.css
> above targets standard Firefox elements. Some Zen-specific panels may need
> additional selectors — use the Browser Toolbox (`Ctrl+Alt+Shift+I`) to inspect
> element IDs if something doesn't match.

### Revert Option A
Switch back to default theme in `about:addons` → Themes.

### Revert Option B
Delete `chrome/userChrome.css` from your profile folder and restart Zen.

---

## Step 13 — Lock screen (i3lock-color)

**What this does:** Replaces the flat dark rectangle from bare `i3lock` with a blurred
screenshot of your current screen, a large Tokyo Night–styled clock, and a subtle
ring indicator. Notifications are paused while locked and resume on unlock.

`Super+Shift+x` triggers it (already wired in i3/config).

### Build i3lock-color from source
i3lock-color is not on apt. See `SOURCES.md → i3lock-color` for the full build steps.
It installs to `/usr/local/bin/i3lock-color`.

Verify the build worked:
```bash
i3lock-color --version
```

### Backup
```bash
cp ~/.config/i3/lock.sh ~/.config/i3/lock.sh.bak 2>/dev/null || true
```

### Deploy
```bash
cp ~/Development/Ricing/lock/lock.sh ~/.config/i3/lock.sh
chmod +x ~/.config/i3/lock.sh
```

### Test without locking yourself out
Open a second TTY first (`Ctrl+Alt+F2`), then test the lock from your i3 session.
If the lock screen hangs or looks wrong, switch to the TTY and kill it:
```bash
pkill i3lock-color
```

### Fallback — if i3lock-color can't be compiled
Keep bare i3lock as the fallback. Edit `~/.config/i3/config` and change the lock line:
```
bindsym $mod+Shift+x exec i3lock -c 16161e
```

### Revert
```bash
cp ~/.config/i3/lock.sh.bak ~/.config/i3/lock.sh
# or to go back to bare i3lock:
# edit ~/.config/i3/config and replace the lock line as shown above
```

---

## Step 14 — Display management (autorandr + arandr)

**What this does:** `arandr` gives you a drag-and-drop GUI to arrange monitors.
`autorandr` saves those arrangements as named profiles and automatically applies
the right one when you plug or unplug a monitor — no manual `xrandr` commands needed.

### Install
```bash
sudo apt install autorandr arandr
```
If missing from mirror, see `SOURCES.md → autorandr`.

### One-time setup — save your display profiles

**Step 1:** Open arandr and arrange your displays visually:
```bash
arandr
```
Apply the layout you want (primary monitor, resolution, orientation, position).
Close arandr — you don't need to save its `.sh` script.

**Step 2:** Save the current state as an autorandr profile:
```bash
# Replace <name> with something meaningful
autorandr --save laptop        # just the built-in screen
autorandr --save home          # docked with external monitor(s)
autorandr --save external      # external only, lid closed
```

Run this for each physical configuration you use.

**Step 3:** Test switching works:
```bash
autorandr --list               # show saved profiles
autorandr --change             # auto-detect and apply matching profile
autorandr home                 # force a specific profile
```

### Add to i3 autostart
The i3 config already has a slot for autostart. Add this line to `~/.config/i3/config`:
```
exec --no-startup-id autorandr --change
```
Also add it to the reload binding section so it fires on `Super+Shift+r`:
```
exec_always --no-startup-id autorandr --change
```

### Switching profiles manually
```bash
autorandr --change             # auto-detect
autorandr laptop               # force laptop-only
autorandr home                 # force docked layout
```

Or bind it in i3:
```
bindsym $mod+F7 exec autorandr --change
```

### Revert
```bash
# autorandr only ever runs xrandr — removing it just means no auto-switching
# To delete a saved profile:
autorandr --remove home
```

---

## Step 15 — SDDM login screen (Tokyo Night)

**What this does:** Replaces the stock Kubuntu SDDM theme with a Tokyo Night–styled
login screen so the full boot-to-desktop experience is consistent.

> This step requires `sudo` and edits a system file. It has no effect on the i3 or
> KDE Plasma sessions themselves — only the login screen changes.

### Check your SDDM version
```bash
sddm --version
```
The astronaut theme requires SDDM ≥ 0.19. Ubuntu 24.04 ships 0.21 — you're fine.

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

The astronaut theme ships multiple variants. Switch to Tokyo Night:
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
Press `Ctrl+C` or close the window to dismiss the preview.

### Backup the SDDM config
```bash
sudo cp /etc/sddm.conf.d/theme.conf /etc/sddm.conf.d/theme.conf.bak 2>/dev/null || true
```

### Revert
```bash
# Remove the theme config — SDDM falls back to its default Breeze theme
sudo rm /etc/sddm.conf.d/theme.conf
```

Or restore the Breeze theme explicitly:
```bash
sudo tee /etc/sddm.conf.d/theme.conf > /dev/null <<'EOF'
[Theme]
Current=breeze
EOF
```

---

## Step 16 — Starship prompt (Tokyo Night)

**What this does:** Applies a Tokyo Night–styled prompt to starship. Shows directory,
git branch/status, command duration, and language context (right prompt). Clean
single-line layout with a `❯` character that turns red on error.

### Backup
```bash
cp ~/.config/starship.toml ~/.config/starship.toml.bak 2>/dev/null || true
```

### Option A — starship's built-in preset (quickest sanity check)
```bash
starship preset tokyo-night -o /tmp/starship-preview.toml
# Preview it first, then apply if you like it:
cp /tmp/starship-preview.toml ~/.config/starship.toml
```

### Option B — the custom config from this repo (recommended)
More control: right prompt with language versions, cleaner git indicators,
command duration only shown if > 2 seconds, username/hostname hidden.
```bash
cp ~/Development/Ricing/starship/starship.toml ~/.config/starship.toml
```

Apply immediately — open a new fish session or:
```fish
exec fish
```

### Revert
```bash
cp ~/.config/starship.toml.bak ~/.config/starship.toml
exec fish
```

---

## Step 17 — Fish shell colours (Tokyo Night)

**What this does:** Sets fish's universal colour variables so syntax highlighting,
autosuggestions, tab completions, and the pager all match Tokyo Night. These are
stored as universal variables — persistent, no config.fish edits needed.

### Backup
Fish stores these in `~/.local/share/fish/fish_variables`. Back it up:
```bash
cp ~/.local/share/fish/fish_variables ~/.local/share/fish/fish_variables.bak
```

### Apply
Run the colour script directly with fish (not bash):
```fish
fish ~/Development/Ricing/fish/tokyo-night-colors.fish
```

The changes are immediate — open a new terminal and the syntax highlighting
should be Tokyo Night.

### Verify
Type a command in fish — commands should be blue (`#7aa2f7`), strings green
(`#9ece6a`), comments grey (`#565f89`), errors red (`#f7768e`).

### Revert
```bash
cp ~/.local/share/fish/fish_variables.bak ~/.local/share/fish/fish_variables
exec fish
```

Or reset to fish defaults entirely:
```fish
set -U fish_color_command    # (empty resets to default)
# Repeat for each variable listed in the script
```

---

## Step 18 — btop (Tokyo Night)

**What this does:** Adds a Tokyo Night theme file to btop and switches to it.
CPU/memory/network graphs use the full Tokyo Night palette with meaningful
colour progressions (green → yellow → red as load increases).

### Backup
```bash
cp ~/.config/btop/btop.conf ~/.config/btop/btop.conf.bak 2>/dev/null || true
```

### Deploy
```bash
mkdir -p ~/.config/btop/themes
cp ~/Development/Ricing/btop/tokyo-night.theme ~/.config/btop/themes/tokyo-night.theme
```

### Apply inside btop
```
ESC → Options → Color theme → select "tokyo-night" → apply
```

Or set it directly in btop's config file:
```bash
# Find the color_theme line and change it:
sed -i 's/^color_theme =.*/color_theme = "tokyo-night"/' ~/.config/btop/btop.conf
```

Restart btop to confirm.

### Revert
```bash
cp ~/.config/btop/btop.conf.bak ~/.config/btop/btop.conf
# or inside btop: ESC → Options → Color theme → Default
```

---

## Step 19 — CLion (Tokyo Night)

**What this does:** Applies Tokyo Night to the CLion editor, UI chrome, and terminal.
JetBrains IDEs have first-party Tokyo Night support via a marketplace plugin.

### Install the plugin
1. Open CLion
2. `File` → `Settings` → `Plugins` → `Marketplace`
3. Search **"Tokyo Night"** — install the one by **enkia** (same author as the Neovim/VSCode themes)
4. Restart CLion when prompted

### Apply the theme
`File` → `Settings` → `Appearance & Behavior` → `Appearance`  
Theme: **Tokyo Night** (or **Tokyo Night Storm** for the slightly lighter variant)

### Match the editor font
`File` → `Settings` → `Editor` → `Font`  
- Font: **JetBrains Mono** (already installed on the system)
- Size: 13
- Line height: 1.4

### Match the terminal inside CLion
`File` → `Settings` → `Tools` → `Terminal`  
Shell path: `/usr/bin/fish`  
The terminal will inherit the Tokyo Night colour scheme automatically once the
plugin is active.

### Revert
`File` → `Settings` → `Plugins` → disable or uninstall Tokyo Night  
Switch theme back to Darcula or IntelliJ Light.

---

## Full revert — back to KDE Plasma

If at any point you want to abandon the rice entirely:

```bash
# Restore all backed-up configs
cp -r ~/.config/i3.bak                         ~/.config/i3                         2>/dev/null || true
cp -r ~/.config/alacritty.bak                  ~/.config/alacritty                  2>/dev/null || true
cp -r ~/.config/rofi.bak                       ~/.config/rofi                       2>/dev/null || true
cp    ~/.config/picom.conf.bak                 ~/.config/picom/picom.conf           2>/dev/null || true
cp -r ~/.config/dunst.bak                      ~/.config/dunst                      2>/dev/null || true
cp    ~/.config/gtk-3.0/settings.ini.bak       ~/.config/gtk-3.0/settings.ini       2>/dev/null || true
cp    ~/.config/gtk-4.0/settings.ini.bak       ~/.config/gtk-4.0/settings.ini       2>/dev/null || true
cp    ~/.gtkrc-2.0.bak                         ~/.gtkrc-2.0                         2>/dev/null || true
cp    ~/.config/xsettingsd/xsettingsd.conf.bak ~/.config/xsettingsd/xsettingsd.conf 2>/dev/null || true
cp    ~/.config/starship.toml.bak              ~/.config/starship.toml              2>/dev/null || true
cp    ~/.config/btop/btop.conf.bak             ~/.config/btop/btop.conf             2>/dev/null || true
cp    ~/.local/share/fish/fish_variables.bak   ~/.local/share/fish/fish_variables   2>/dev/null || true
pkill xsettingsd 2>/dev/null || true

# Remove theme files (won't affect KDE Plasma — it uses its own theme store)
rm -rf ~/.themes/Tokyonight*
rm -rf ~/.config/Kvantum/TokyoNight*
rm -f  ~/.config/btop/themes/tokyo-night.theme

# Restore SDDM to Breeze (if Step 15 was done)
sudo tee /etc/sddm.conf.d/theme.conf > /dev/null <<'EOF'
[Theme]
Current=breeze
EOF
```

Then log out and select **Plasma** from the SDDM session menu.
KDE Plasma is entirely separate — switching sessions leaves it exactly as you
left it.

---

## Quick reference — i3 keybindings

| Key | Action |
|-----|--------|
| `Super+Return` | Open terminal (alacritty) |
| `Super+d` | Open launcher (rofi) |
| `Super+Shift+q` | Close window |
| `Super+h/j/k/l` | Focus left/down/up/right |
| `Super+Shift+h/j/k/l` | Move window |
| `Super+1…0` | Switch workspace |
| `Super+Shift+1…0` | Move window to workspace |
| `Super+f` | Fullscreen toggle |
| `Super+b` / `Super+v` | Split horizontal / vertical |
| `Super+r` | Resize mode (then h/j/k/l) |
| `Super+Shift+space` | Toggle floating |
| `Super+Shift+x` | Lock screen |
| `Super+Shift+r` | Reload i3 config |
| `Super+Shift+e` | Exit i3 |
| `Print` | Screenshot (saved to ~/Pictures/screenshots/) |
