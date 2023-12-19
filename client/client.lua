local polePoints = {}

lib.registerContext({
    id = 'dance_menu',
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
    polePoints[#polePoints + 1] = v
end

function StartRay()
    local run = true
    while run do
        local Wait = 1
        local hit, entityHit, endCoords, surfaceNormal, matHash = lib.raycast.cam(511, 4, 10)
        lib.showTextUI('Raycast Coords:  \n X:  ' ..
        endCoords.x .. ',  \n Y:  ' .. endCoords.y .. ',  \n Z:  ' .. endCoords.z .. '  \n[E] to copy  \n[DEL] to cancel')
        DrawMarker(21, endCoords.x, endCoords.y, endCoords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, 255, 255,
        255, 255, false, true, 2, nil, nil, false, false)
        if IsControlJustReleased(0, 38) then
            lib.hideTextUI()
            run = false
            return endCoords
        end

        if IsControlJustReleased(0, 178) then
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

local poleProps = {}
local modelTargs = {}

function CreateTargets()
        DestroyTargets()
    if Config.Target == 'ox' then
        if Config.UseModels then
            local modelTarg = exports.ox_target:addModel('prop_strip_pole_01', {
                {
                    label = "Pole Dance",
                    icon = "fas fa-shoe-prints",
                    distance = 3.0,
                    offsetSize = 2.0,
                    offset = vec3(1, 1, 1),
                    onSelect = function() lib.showContext('dance_menu') end
                }
            })
            modelTargs[#modelTargs + 1] = modelTarg
        end

        for k, v in pairs(Config.Poles) do
            if v.spawn then
                lib.requestModel('prop_strip_pole_01')
               local pole =  CreateObject(joaat('prop_strip_pole_01'), v.position.x, v.position.y, v.position.z, false, false,
                    false)
                poleProps[#poleProps + 1] = pole
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
            local poleZone = exports.ox_target:addBoxZone(params)
            polePoints[#polePoints + 1] = poleZone
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
                local pole = CreateObject(joaat('prop_strip_pole_01'), v.position.x, v.position.y, v.position.z, false, false,
                    false)
                poleProps[#poleProps + 1] = pole
            end
           local poleZone = exports['qb-target']:AddBoxZone('pole' .. k, v.position.xyz, 1.5, 1.5, {
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
            polePoints[#polePoints + 1] = poleZone
        end
    elseif Config.Target == 'lib' then
        for k, v in pairs(Config.Poles) do
            if v.spawn then
                lib.requestModel('prop_strip_pole_01')
               local pole = CreateObject(joaat('prop_strip_pole_01'), v.position.x, v.position.y, v.position.z, false, false,
                    false)
                poleProps[#poleProps + 1] = pole
            end
            local params = {
                coords = vec3(v.position.x, v.position.y, v.position.z + 1.0),
                size = vec3(1, 1, 1),
                rotation = v.position.w,
                onEnter = function()
                    lib.showTextUI('Press [E] to dance')
                end,
                inside = function()
                    if IsEntityPlayingAnim(cache.ped, 'mini@strip_club@pole_dance@pole_dance1', 'pd_dance_01', 3) or IsEntityPlayingAnim(cache.ped, 'mini@strip_club@pole_dance@pole_dance2', 'pd_dance_02', 3) or IsEntityPlayingAnim(cache.ped, 'mini@strip_club@pole_dance@pole_dance3', 'pd_dance_03', 3) then
                        lib.hideTextUI()
                        lib.showTextUI('Press [X] to stop dancing')
                        if IsControlJustPressed(0, 73) then
                            ClearPedTasks(cache.ped)
                            lib.hideTextUI()
                        end
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
            local poleZone = lib.zones.box(params)
            polePoints[#polePoints + 1] = poleZone
        end
    end
end

function DestroyTargets()
    for i = 1, #polePoints do
        local pole = polePoints[i]
        if Config.Target == 'ox' then
            exports.ox_target:removeZone(pole)
            if Config.UseModels then
                for k, v in pairs(modelTargs) do
                    print(k, v)
                exports.ox_target:removeModel('prop_strip_pole_01', modelTargs[k])
                end
            end
        elseif Config.Target == 'qb' then
            exports['qb-target']:RemoveZone(pole)
        elseif Config.Target == 'lib' then
            pole:remove()
        end
    end
    for i = 1, #poleProps do
        local pole = poleProps[i]
        if DoesEntityExist(pole) then
            DeleteObject(pole)
            DeleteEntity(pole)
    end
    end
end


RegisterNetEvent('bm_dance:start', function(args)
    local position = GetEntityCoords(cache.ped)
    local usePolePosition = false
    if not args.coords then args.coords = position end
    if args.dance then
        local nearbyObjects = lib.getNearbyObjects(args.coords, 1.5)
        if #nearbyObjects > 0 then
            local closestObject = nearbyObjects[1]
            local scene = NetworkCreateSynchronisedScene(closestObject.coords.x + 0.07, closestObject.coords.y + 0.3,
                closestObject.coords.z + 1.15, 0.0, 0.0, 0.0, 2, false, true, 1065353216, 0, 1.3)
            NetworkAddPedToSynchronisedScene(cache.ped, scene, 'mini@strip_club@pole_dance@pole_dance' .. args.dance,
                'pd_dance_0' .. args.dance, 1.5, -4.0, 1, 1, 1148846080, 0)
            NetworkStartSynchronisedScene(scene)
        else
            usePolePosition = true
        end
    elseif args.lapdance then
        lib.requestAnimDict(args.dict)
        TaskPlayAnim(cache.ped, args.dict, args.anim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
    else
        for _, point in ipairs(polePoints) do
            local distance = #(point.coords - GetEntityCoords(cache.ped))
            if distance <= point.distance then
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
            NetworkAddPedToSynchronisedScene(cache.ped, scene, 'mini@strip_club@pole_dance@pole_dance' .. args.dance,
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
        Config.Poles[#Config.Poles + 1] = poleConfig
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
AddEventHandler('onClientResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    DestroyTargets()
end)

if GetResourceState('qb-core') == 'started' then
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
            Wait(3000)
            CreateTargets()
    end)
end