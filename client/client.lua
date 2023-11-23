local polePoints = {}
lib.registerContext({
    id = 'dance_menu',
    menu = 'dance_menu',
    title = 'Select Your Dance',
    options = {
        { title = 'Dance Options' }, {
        title = 'Pole Dance #1',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = { dance = 1 }
    }, {
        title = 'Pole Dance #2',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = { dance = 2 }
    }, {
        title = 'Pole Dance #3',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = { dance = 3 }
    }, {
        title = 'Lap Dance #1',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 1,
            anim = 'lap_dance_girl',
            dict = 'mp_safehouse'
        }
    }, {
        title = 'Lap Dance #2',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 2,
            anim = 'priv_dance_idle',
            dict = 'mini@strip_club@private_dance@idle'
        }
    }, {
        title = 'Lap Dance #3',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 3,
            anim = 'priv_dance_p1',
            dict = 'mini@strip_club@private_dance@part1'
        }
    }, {
        title = 'Lap Dance #4',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 4,
            anim = 'priv_dance_p2',
            dict = 'mini@strip_club@private_dance@part2'
        }
    }, {
        title = 'Lap Dance #5',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 5,
            anim = 'priv_dance_p3',
            dict = 'mini@strip_club@private_dance@part3'
        }
    }, {
        title = 'Lap Dance #6',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 6,
            anim = 'yacht_ld_f',
            dict = 'oddjobs@assassinate@multi@yachttarget@lapdance'
        }
    }
    }
})

for _, v in ipairs(Config.Poles) do
    local polePoints = lib.points.new({
        coords = v.position,
        distance = 3.0,
    })
end

function IsPlayerNearCoords(playerCoords, vector, distance)
    local playerDistance = GetDistanceBetweenCoords(playerCoords, vector, true)
    return playerDistance <= distance
end

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination =
    {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination
        .x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end

function RotationToDirection(rotation)
    local adjustedRotation =
    {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction =
    {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

function StartRay()
    local run = true
    while run do
        local Wait = 5
        local color = { r = 0, g = 255, b = 0, a = 200 }
        local hit, coords, entity = RayCastGamePlayCamera(1000.0)
        lib.showTextUI('Raycast Coords:  \n X:  ' ..
            coords.x .. ',  \n Y:  ' .. coords.y .. ',  \n Z:  ' .. coords.z .. '  \n[E] to copy  \n[DEL] to cancel')
        DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g,
            color.b, color.a, false, true, 2, nil, nil, false)

        if IsControlJustReleased(0, 38) then
            lib.hideTextUI()
            run = false
            return coords
        end

        if IsControlJustReleased(0, 178) then -- [DEL CANCEL]
            lib.hideTextUI()
            run = false
            return nil
        end

        Citizen.Wait(Wait)
    end
end

function ToConfigFormat(poleConfig)
    local formattedConfig = "{ position = vec4(" ..
        poleConfig.position.x .. "," .. poleConfig.position.y .. "," .. poleConfig.position.z .. ",0.0),"
    if poleConfig.spawn then
        formattedConfig = formattedConfig .. " spawn = true },"
    else
        formattedConfig = formattedConfig .. " },"
    end
    return formattedConfig
end

function CreateTargets()
    if Config.Target == 'ox' then
        if Config.UseModels then
            exports.ox_target:addModel('prop_strip_pole_01', {
                {
                    label = "Pole Dance",
                    icon = "fas fa-shoe-prints",
                    distance = 3.0,
                    offsetSize = 2.0,
                    offset = vec3(1, 1, 1),
                    onSelect = function() lib.showContext('dance_menu') end
                }
            })
        end

        for k, v in pairs(Config.Poles) do
            if v.spawn then
                lib.requestModel('prop_strip_pole_01')
                CreateObject(GetHashKey('prop_strip_pole_01'), v.position.x, v.position.y, v.position.z, false, false,
                    false)
            end
            local params = {
                coords = v.position,
                size = vec3(1, 1, 3) or v.size,
                rotation = v.position.w,
                debug = Config.Debug,
                options = {
                    {
                        label = 'Pole Dance',
                        name = 'Pole' .. k,
                        icon = 'fas fa-shoe-prints',
                        distance = 3.0,
                        groups = nil or v.job,
                        onSelect = function()
                            lib.showContext('dance_menu')
                        end
                    }
                }
            }
            exports.ox_target:addBoxZone(params)
        end
    elseif Config.Target == 'qb' then
        if Config.UseModels then
            exports['qb-target']:AddTargetModel('prop_strip_pole_01', {
                options = {
                    {
                        icon = 'fas fa-shoe-prints',
                        label = 'Pole Dance',
                        action = function()
                            lib.showContext('dance_menu')
                        end
                    }
                },
                distance = 1.5
            })
        end
        for k, v in pairs(Config.Poles) do
            if v.spawn then
                lib.requestModel('prop_strip_pole_01')
                CreateObject(GetHashKey('prop_strip_pole_01'), v.position.x, v.position.y, v.position.z, false, false,
                    false)
            end
            exports['qb-target']:AddBoxZone('pole' .. k, v.position.xyz, 1.5, 1.5, {
                name = "pole" .. k,
                heading = v.position.w,
                debugPoly = Config.Debug,
                minZ = v.position.z - 2.0,
                maxZ = v.position.z + 2.0
            }, {
                options = {
                    {
                        icon = 'fas fa-shoe-prints',
                        label = 'Pole Dance',
                        action = function()
                            lib.showContext('dance_menu')
                        end
                    }
                },
                distance = 2.0
            }
            )
        end
    elseif Config.Target == 'lib' then
        for k, v in pairs(Config.Poles) do
            if v.spawn then
                lib.requestModel('prop_strip_pole_01')
                CreateObject(GetHashKey('prop_strip_pole_01'), v.position.x, v.position.y, v.position.z, false, false,
                    false)
            end
            local params = {
                coords = vec3(v.position.x, v.position.y, v.position.z + 1.0),
                size = vec3(1, 1, 1),
                rotation = v.position.w,
                onEnter = function()
                    lib.showTextUI('Press [E] to dance')
                end,
                inside = function()
                    if IsEntityPlayingAnim(PlayerPedId(), 'mini@strip_club@pole_dance@pole_dance1', 'pd_dance_01', 3) or IsEntityPlayingAnim(PlayerPedId(), 'mini@strip_club@pole_dance@pole_dance2', 'pd_dance_02', 3) or IsEntityPlayingAnim(PlayerPedId(), 'mini@strip_club@pole_dance@pole_dance3', 'pd_dance_03', 3) then
                        lib.hideTextUI()
                    end
                    if IsControlJustReleased(0, 38) then
                        lib.showContext('dance_menu')
                    end
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                debug = Config.Debug,
            }
            lib.zones.box(params)
        end
    end
end

RegisterNetEvent('bm_dance:start', function(args)
    local position = GetEntityCoords(PlayerPedId())
    local usePolePosition = false
    if not args.coords then args.coords = position end
    if args.dance then
        local nearbyObjects = lib.getNearbyObjects(args.coords, 1.5)
        if #nearbyObjects > 0 then
            local closestObject = nearbyObjects[1]
            local scene = NetworkCreateSynchronisedScene(closestObject.coords.x + 0.07, closestObject.coords.y + 0.3,
                closestObject.coords.z + 1.15, 0.0, 0.0, 0.0, 2, false, true, 1065353216, 0, 1.3)
            NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, 'mini@strip_club@pole_dance@pole_dance' .. args.dance,
                'pd_dance_0' .. args.dance, 1.5, -4.0, 1, 1, 1148846080, 0)
            NetworkStartSynchronisedScene(scene)
        else
            usePolePosition = true
        end
    elseif args.lapdance then
        lib.requestAnimDict(args.dict)
        TaskPlayAnim(PlayerPedId(), tostring(args.dict), tostring(args.anim), 1.0, 1.0, -1, 1, 0, 0, 0, 0)
    else
        for _, point in ipairs(polePoints) do
            if IsPlayerNearCoords(position, point.coords, point.distance) then
                usePolePosition = true
                break
            end
        end
    end
    if usePolePosition then
        local closestPoint = lib.points.getClosestPoint()
        if closestPoint then
            if Config.Debug then print('Close') end
            args.coords = closestPoint.coords

            local scene = NetworkCreateSynchronisedScene(args.coords.x + 0.07, args.coords.y + 0.3,
                args.coords.z + 1.15, 0.0, 0.0, 0.0, 2, false, true, 1065353216, 0, 1.3)
            NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, 'mini@strip_club@pole_dance@pole_dance' .. args.dance,
                'pd_dance_0' .. args.dance, 1.5, -4.0, 1, 1, 1148846080, 0)
            NetworkStartSynchronisedScene(scene)
        else
            if Config.Debug then print('Not close') end
        end
    end
end)

RegisterNetEvent('bm_dance:pole', function()
    local polePosition = StartRay()
    if polePosition then
        local poleConfig = {
            position = vec4(polePosition.x, polePosition.y, polePosition.z, 0.0),
            spawn = true,
        }
        table.insert(Config.Poles, poleConfig) --temporary
        if Config.Debug then
            print("New pole added to Config.Poles:")
            print(ToConfigFormat(poleConfig))
        end
        lib.setClipboard(ToConfigFormat(poleConfig))
        lib.notify({ title = 'Dance', description = 'New pole added to clipboard', type = 'success' })
        CreateTargets()
    else
        print("Action canceled.")
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    CreateTargets()
end)
