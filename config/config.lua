return {
    Debug = false,
    UseModels = false,                                    --UseModels true for all prop instances
    Target = 'qb',                                        --Target 'qb' or 'ox' or 'lib'
    Poles = {
        { position = vec4(-1388.7698974609, -674.28186035156, 27.856121063232, 0.0), spawn = true }, -- position required, job optional, spawn optional
        -- Vanilla VU Poles
        { position = vector4(104.16384124756, -1294.2568359375, 28.26, 30),  job = 'unicorn' },
        { position = vector4(102.25046539307, -1290.8802490234, 28.25, 30),  job = 'unicorn' },
        { position = vector4(112.580322265631, -1287.0412597656, 27.46, 30), job = 'unicorn' }
    }

}
