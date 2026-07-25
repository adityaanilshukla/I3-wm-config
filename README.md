# i3wm configuration

Config and helper scripts for my i3 setup. Lives at `~/.config/i3`.

Shared by three machines: `brovo` (desktop, NVIDIA, ultrawide) and two laptops,
`buffyx` (XPS 13 9310) and a T480. Scripts detect the machine at runtime rather
than being forked per host.

## Layout

| Path | What it is |
|---|---|
| `config` | the i3 config itself |
| `bash-files/` | helper scripts invoked by keybindings |
| `python-scripts/` | `rofi-beats-linux.py`, bound to `$mod+b` |
| `images/` | wallpapers, set by `bash-files/main-monitor.sh` |

## Volume and brightness

The on-screen display is defined **once**, in `bash-files/hud.sh`, and sourced by
all three scripts that draw it:

- `volume.sh` — volume and mute
- `brightness.sh` — a laptop's own backlight, via `xbacklight`
- `external-brightness.sh` — an external monitor over DDC/CI, via `ddcutil`

`fn-brightness.sh` picks between the two brightness paths.

They share `hud.sh` because they previously each carried their own copy of the
`dunstify` call. One copy was redesigned and the others were not, so the laptops
showed an outdated popup for months while the desktop looked correct. Add new
display code to `hud.sh`, not to the callers.

The HUD needs a Nerd Font and `progress_bar = true` in `dunstrc`, both of which
come from the [dotfiles](https://github.com/adityaanilshukla/dotfiles) repo.

## Related repo

Packages, fonts, GTK theming and every other config live in `dotfiles`. Its
`bootstrap.sh` clones and updates **both** repos; use it rather than pulling this
one on its own, or the two drift apart.

## Requirements

Beyond i3 itself: `dunst`, `polybar`, `rofi`, `picom`, `alacritty`, `feh`,
`maim`, `xclip`, `pactl` (pipewire), `betterlockscreen`, `ddcutil` (desktop) or
`xbacklight` (laptops). Installed from `dotfiles/packagelist/` by
`dotfiles/setup-packages.sh`.
