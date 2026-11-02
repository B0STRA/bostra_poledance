return {
    Debug = false,
    UseModels = false,
    Tips = { min = 1, max = 1000, cooldown = 3, distance = 4.5, range = 5.0 },
    -- Tips: amount limits, seconds between tips, target distance for dancers, server max distance check
    -- Pole fields: position (vec4, w = heading), spawn (create the prop), job (optional job lock),
    -- dancer / dancerDance (set by /newdancer, offset of the dancer and dance number 1-3)
    -- Add poles with /newpole, then paste its line here. Example:
    -- { position = vec4(x, y, z, 0.0), spawn = true, job = 'unicorn', dancer = vec4(0.0330, 0.2520, 1.1500, 0.0), dancerDance = 3 },
    Poles = {
        { position = vec4(-1388.7698974609, -674.28186035156, 27.856121063232, 0.0), spawn = true },
        { position = vec4(104.16384124756, -1294.2568359375, 28.26, 30) },
        { position = vec4(102.25046539307, -1290.8802490234, 28.25, 30) },
        { position = vec4(112.580322265631, -1287.0412597656, 27.46, 30) },
    },
}
