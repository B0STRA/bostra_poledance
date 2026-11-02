![poledance,png](https://github.com/B0STRA/bostra_poledance/assets/119994243/76e5d08d-5d5d-4903-8bcf-8392f508eebe)
# bostra_poledance

FiveM Pole / Dancing script.

## Features
- ox_target interaction on poles and dancers
- 3 unique pole dances
- 6 lap dances
- One dancer per pole, so a claimed pole is locked until the dancer stops
- Patron tipping with a make-it-rain animation, paid from ox_inventory cash
- Job locks per pole
- Admin tools to create poles and calibrate the dancer position in-game

## Dependencies
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)
- [ox_inventory](https://github.com/overextended/ox_inventory) (for tipping)
- OneSync enabled on the server (players must see each other for tipping to work)

## Installation
1. Drag the `bostra_poledance` folder into your resources.
2. Ensure `ox_lib`, `ox_target` and `ox_inventory` are started **before** `bostra_poledance`.
3. Enable OneSync in your `server.cfg`, for example `set onesync on`.
4. Start the resource and add poles (see below).
5. Optional addition to use in [ps-housing](https://github.com/Project-Sloth/ps-housing), add to your ```shared\config.lua``` under a category's items like so:
```lua
        category = "Misc",
        items = {
            { ["object"] = "v_corp_facebeanbag", ["price"] = 100, ["label"] = "Bean Bag 1" },
            { ["object"] = "prop_strip_pole_01", ["price"] = 2500, ["label"] = "Dance Pole" }, --Added line
```

## Usage

### Dancing (players)
- Target a pole and choose **Pole Dance**. Pick a pole dance (#1-3) or a lap dance (#1-6).
- Press **X** or choose **Cancel Dance** to stop. Stopping a pole dance frees the pole.
- While someone is dancing on a pole, its **Pole Dance** option is hidden for everyone else.

### Tipping (patrons)
- Target a dancer, or a pole with a dancer on it, and choose **Leave Tip** / **Tip Dancer**.
- Enter an amount. Limits and cooldown are set in `config/config.lua` under `Tips`.
- The tip is taken from your cash and given to the dancer. If the dancer cannot carry the cash, the tip is refused.

### Admin commands
Both commands need the `group.admin` ACE group.

**`/newpole`** creates a pole where you aim.
1. Run `/newpole` and aim at the spot.
2. Press **E** to place it, or **DEL** to cancel.
3. The pole line is copied to your clipboard. Paste it into `Config.Poles` in `config/config.lua`.

**`/newdancer`** calibrates where the dancer stands on a pole.
1. Aim at a pole within 5 m and run `/newdancer`. A preview dancer appears on Pole Dance #3.
2. Controls while the dancer menu has focus:
   - **W / A / S / D**: move the dancer
   - **R / Z**: raise / lower
   - **Q / E**: rotate
   - **G**: cycle the dance (#1-3)
   - **ENTER**: save
   - **BACKSPACE**: cancel
   - **H**: toggle free control (you can move and act; the menu is ignored until you press H again)
3. On save, the `dancer = ..., dancerDance = ...` line is copied to your clipboard. Paste it into that pole's entry in `config/config.lua`.

## Config
See `config/config.lua`. Key options:
- `Debug`: show the pole target zones.
- `UseModels`: also target the pole prop model directly.
- `Tips`: `min` / `max` amount, `cooldown` in seconds, `distance` for the ox_target option, `range` for the server distance check.
- `Poles`: one entry per pole. Each entry has `position`, `spawn`, optional `job`, and optional `dancer` / `dancerDance`.

## Preview
- ([Streamable](https://streamable.com/fphors))

## Known Issues
- Spawned props duplicate target options, scene coords could be better...
- A pole's claim is keyed by its position. Two poles at the exact same coordinates share one claim.

## Troubleshooting & Support
[Mustache Scripts - Discord](https://discord.gg/RVx8nVwcEG)


## Tip / Commission Me
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/A0A46AZW4)
