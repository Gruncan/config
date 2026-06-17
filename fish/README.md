# Fish — Tokyo Night + Omarchy-style terminal behaviour

| Piece | Purpose |
|--------|---------|
| [`tokyo-night-colors.fish`](tokyo-night-colors.fish) | Universal syntax-highlighting colours (run once; see [SETUP.md](../SETUP.md) Step 20). |
| [`functions/`](functions/) | **`ls` / `lsa` / `lt` / `lta`** matching [Omarchy bash aliases](https://github.com/basecamp/omarchy/blob/dev/default/bash/aliases) and [omarchy-fish](https://github.com/omacom-io/omarchy-fish) when **`eza`** is installed. |
| [`conf.d/99-omarchy-parity.fish`](conf.d/99-omarchy-parity.fish) | **Ctrl+C** on an empty line: Fish normally does nothing (reader skips an empty buffer). This snippet inserts a **zero-width space** so the built-in **`cancel-commandline`** runs — same **^C** path Fish uses for non-empty lines, so scrollback matches Bash (no hand-rolled `printf`/`repaint`). |

## Deploy (copy into `~/.config/fish/`)

From your clone path (set `REPO` to the directory that contains this `fish/` folder):

```bash
REPO=~/Development/Misc/config   # example — change if your clone lives elsewhere
sudo apt install eza             # Ubuntu 24.04+; optional but needed for icons + git column in lt

mkdir -p ~/.config/fish/functions ~/.config/fish/conf.d
cp -r "$REPO/fish/functions/." ~/.config/fish/functions/
cp "$REPO/fish/conf.d/99-omarchy-parity.fish" ~/.config/fish/conf.d/
```

Start a new Fish session (or `exec fish`).

### `^C` looks highlighted (block background)

Fish’s stock universal is `fish_color_cancel -r` (**reverse** video). This repo sets **`fish_color_cancel`** to plain Tokyo Night red in [`tokyo-night-colors.fish`](tokyo-night-colors.fish), and [`conf.d/99-omarchy-parity.fish`](conf.d/99-omarchy-parity.fish) overrides a lone default `-r` for the session. To fix without re-running the full theme: `set -U fish_color_cancel f7768e` then `exec fish`.

### If you already use `fish_user_key_bindings`

Your `config.fish` will override the function from `99-omarchy-parity.fish` if it defines `fish_user_key_bindings` **after** conf.d loads. Either remove the duplicate from this file and merge the `bind` lines into yours, or call `__fish_omarchy_ctrl_c` from your own `fish_user_key_bindings`.

### Revert

```bash
rm ~/.config/fish/conf.d/99-omarchy-parity.fish
rm ~/.config/fish/functions/{ls,lsa,lt,lta}.fish
exec fish
```

### `ls` / eza — 󰲋 on `~/Development` when listing home

When **`PWD` is `$HOME`** and you run **`ls`** (or **`ls .`**), the **`Development`** row swaps eza’s folder glyph for **󰲋**. Output is piped through a small filter, so eza would otherwise see **no TTY** and turn off **icons** and **colours** (`auto` modes). That path therefore uses **`--icons=always`** and **`--color=always`**, matching a normal interactive listing.

With **`--color=always`**, eza wraps the name column in ANSI escapes, so the filter does **not** look for a plain `␠icon␠Development` suffix. It finds the **first** occurrence of a known **folder glyph** on lines that contain **`Development`**, splits there, and inserts **󰲋**, leaving all colour codes untouched.

Default glyphs cover common Nerd Font / eza folder codepoints; override with universal **`folder_glyphs`** (a list) and **`icon_dev`** (first element is the replacement glyph) if your font uses something else. Copy the updated [`functions/ls.fish`](functions/ls.fish) into `~/.config/fish/functions/`.
