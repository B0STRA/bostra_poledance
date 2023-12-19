![poledance,png](https://github.com/B0STRA/bostra_poledance/assets/119994243/76e5d08d-5d5d-4903-8bcf-8392f508eebe)
# bostra_poledance

FiveM Pole / Dancing script.

## Features
- Target or Zone text ui supported
- 3 unique pole dances
- 6 enticing lap dances
- Job locks with target
- Dynamic tool for creating new poles
- Easy new locaiton adding


## Dependencies
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox](https://github.com/overextended/ox_target) or [qb](https://github.com/qbcore-framework/qb-target) target

## Installation
1. Drag the `bostra_poledance` folder into your resources.
2. Ensure `ox_lib`, and the target resource (if in use) are ensured **before** `bostra_poledance`.
3. `newpole` admin command creates a pole and copys the pole coordinates to your clipboard, paste it in your config if you want it permanent.
4. Optional addition to use in [ps-housing](https://github.com/Project-Sloth/ps-housing), Add to your ```shared\config.lua``` under a category's items like so: 
```lua        
        category = "Misc",
        items = {
            { ["object"] = "v_corp_facebeanbag", ["price"] = 100, ["label"] = "Bean Bag 1" },
            { ["object"] = "prop_strip_pole_01", ["price"] = 2500, ["label"] = "Dance Pole" }, --Added line
```

## Preview
- ([Streamable](https://streamable.com/fphors))

## Known Issues
- Spawned props duplicate target options, scene coords could be better...

## Troubleshooting & Support
[Mustache Scripts - Discord](https://discord.gg/RVx8nVwcEG)


## Tip / Commission Me
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/A0A46AZW4)
