Config = { Debug = false, UseModels = true, Target = 'lib' } --UseModels true for all prop instances, Target 'qb' or 'ox' or 'lib'

Config.Poles = {
    { position = vec4(104.07, -1292.23, 28.26, 301.77),                  spawn = true }, --position vec4, spawn optional, job optional
    -- Vanilla VU Poles
    { position = vector4(104.16384124756, -1294.2568359375, 28.26, 30),  job = 'unicorn' },
    { position = vector4(102.25046539307, -1290.8802490234, 28.25, 30),  job = 'unicorn' },
    { position = vector4(112.580322265631, -1287.0412597656, 27.46, 30), job = 'unicorn' }
}
