# feh wallpaper

feh has no config file — it is controlled entirely by the command in i3/config:

```
exec --no-startup-id feh --no-fehbg --bg-fill ~/Pictures/wallpaper.jpg
```

Drop any image at `~/Pictures/wallpaper.jpg` before starting i3.

## Fill modes
| Flag         | Behaviour                                      |
|--------------|------------------------------------------------|
| `--bg-fill`  | Scale to fill, crop edges (recommended)        |
| `--bg-scale` | Stretch to fit, may distort                    |
| `--bg-max`   | Scale to fit, letterbox with black bars        |
| `--bg-center`| Centre at original size, black surround        |
| `--bg-tile`  | Tile                                           |

## Multiple monitors
```bash
feh --no-fehbg --bg-fill ~/Pictures/wallpaper.jpg ~/Pictures/wallpaper2.jpg
```
Assign one path per monitor in output order.
