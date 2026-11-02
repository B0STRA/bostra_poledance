local Config = require 'config.config'

local POLE_MODEL = 'prop_strip_pole_01'
local DANCER_MODEL = 'mp_f_freemode_01'
local DEFAULT_DANCER = vec4(0.0330, 0.2520, 1.1500, 0.0)
local PLACE_RANGE = 5.0
local NUDGE = 0.001
local ROTATE = 0.1
local LAP_DANCES = {
    { anim = 'lap_dance_girl', dict = 'mp_safehouse' },
    { anim = 'priv_dance_idle', dict = 'mini@strip_club@private_dance@idle' },
    { anim = 'priv_dance_p1', dict = 'mini@strip_club@private_dance@part1' },
    { anim = 'priv_dance_p2', dict = 'mini@strip_club@private_dance@part2' },
    { anim = 'priv_dance_p3', dict = 'mini@strip_club@private_dance@part3' },
    { anim = 'yacht_ld_f', dict = 'oddjobs@assassinate@multi@yachttarget@lapdance' },
}
local NUDGES = {
    [32] = { 0, NUDGE, 0, 0 }, [33] = { 0, -NUDGE, 0, 0 },
    [35] = { NUDGE, 0, 0, 0 }, [34] = { -NUDGE, 0, 0, 0 },
    [45] = { 0, 0, NUDGE, 0 }, [49] = { 0, 0, -NUDGE, 0 },
    [46] = { 0, 0, 0, ROTATE }, [44] = { 0, 0, 0, -ROTATE },
}

local handles, handleCount = {}, 0
local modelTargets, modelTargetCount = {}, 0
local isDancing = false
local targetedPole
local placement

local currentPoleKey

local function poleKey(pole)
    local p = pole.position
    return ('%.2f:%.2f:%.2f'):format(p.x, p.y, p.z)
end

local function canUsePole(pole)
    local occupied = GlobalState.bm_dance_occupied
    local owner = occupied and occupied[poleKey(pole)]
    return owner == nil or owner == GetPlayerServerId(PlayerId())
end

local function releaseCurrentPole()
    if not currentPoleKey then return end
    TriggerServerEvent('bm_dance:releasePole', currentPoleKey)
    currentPoleKey = nil
end

local function claimPole(pole)
    local key = poleKey(pole)
    if currentPoleKey == key then return true end
    if not lib.callback.await('bm_dance:claimPole', false, key) then
        lib.notify({ title = 'Dance', description = 'Someone is already dancing on this pole', type = 'error' })
        return false
    end
    releaseCurrentPole()
    currentPoleKey = key
    return true
end

local function setDancing(kind)
    isDancing = kind ~= nil
    LocalPlayer.state:set('danceKind', kind, true)
end

local function cancelDance()
    releaseCurrentPole()
    setDancing(nil)
    ClearPedTasks(cache.ped)
end

local function getNearestPole(coords)
    local best, bestDist
    for i = 1, #Config.Poles do
        local pole = Config.Poles[i]
        local dist = #(pole.position.xyz - coords)
        if not bestDist or dist < bestDist then
            best, bestDist = pole, dist
        end
    end
    return best
end

local function playDance(dance)
    local pole, offset = dance.pole, dance.offset
    local scene = NetworkCreateSynchronisedScene(pole.position.x + offset.x, pole.position.y + offset.y,
        pole.position.z + offset.z, 0.0, 0.0, offset.w, 2, false, true, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(dance.ped, scene, ('mini@strip_club@pole_dance@pole_dance%d'):format(dance.id),
        ('pd_dance_0%d'):format(dance.id), 1.5, -4.0, 1, 1, 1148846080, 0)
    NetworkStartSynchronisedScene(scene)
end

local function playPoleDance(danceId)
    local pole = targetedPole or getNearestPole(GetEntityCoords(cache.ped))
    assert(pole, 'no pole to dance on')
    if not claimPole(pole) then return end
    playDance({ ped = cache.ped, pole = pole, offset = pole.dancer or DEFAULT_DANCER, id = danceId })
    setDancing('pole')
end

local function playLapDance(lap)
    lib.requestAnimDict(lap.dict)
    releaseCurrentPole()
    TaskPlayAnim(cache.ped, lap.dict, lap.anim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
    setDancing('lap')
end

local danceOptions = {
    { title = 'Dance Options' },
    { title = 'Cancel Dance', icon = 'times', onSelect = cancelDance },
}
local optionCount = #danceOptions
for i = 1, 3 do
    optionCount = optionCount + 1
    danceOptions[optionCount] = {
        title = ('Pole Dance #%d'):format(i),
        icon = 'shoe-prints',
        onSelect = function() playPoleDance(i) end,
    }
end
for i = 1, #LAP_DANCES do
    local lap = LAP_DANCES[i]
    optionCount = optionCount + 1
    danceOptions[optionCount] = {
        title = ('Lap Dance #%d'):format(i),
        icon = 'shoe-prints',
        onSelect = function() playLapDance(lap) end,
    }
end
lib.registerContext({ id = 'dance_menu', title = 'Select Your Dance', options = danceOptions })

local function onCancelKey()
    if isDancing then cancelDance() end
end

lib.addKeybind({
    name = 'cancelpoledance',
    description = 'Cancel PoleDance',
    defaultKey = 'x',
    onReleased = onCancelKey,
})

local function openMenu(pole)
    targetedPole = pole
    lib.showContext('dance_menu')
end

local function getAimPoint()
    local _, _, coords = lib.raycast.cam(1, 4, 10)
    return coords
end

local function pickPoleSpot()
    lib.showTextUI('[E] to copy  \n[DEL] to cancel')
    while true do
        local coords = getAimPoint()
        DrawMarker(21, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, 255, 255, 255, 255,
            false, true, 0, false, false, false, false)
        if IsControlJustPressed(0, 38) then
            lib.hideTextUI()
            return coords
        elseif IsControlJustPressed(0, 178) then
            lib.hideTextUI()
            return nil
        end
        Wait(0)
    end
end

local function spawnPoleProp(pole)
    local pos = pole.position
    lib.requestModel(POLE_MODEL)
    local prop = CreateObject(joaat(POLE_MODEL), pos.x, pos.y, pos.z, false, false, false)
    SetEntityHeading(prop, pos.w)
    PlaceObjectOnGroundProperly(prop)
    FreezeEntityPosition(prop, true)
    SetModelAsNoLongerNeeded(joaat(POLE_MODEL))
    return prop
end

local function destroyTargets()
    for i = 1, handleCount do
        local handle = handles[i]
        exports.ox_target:removeZone(handle.zone)
        if handle.prop and DoesEntityExist(handle.prop) then
            DeleteEntity(handle.prop)
        end
    end
    for i = 1, modelTargetCount do
        exports.ox_target:removeModel(POLE_MODEL, modelTargets[i])
    end
    handles, handleCount = {}, 0
    modelTargets, modelTargetCount = {}, 0
end

local TIP_ANIM_DICT = 'anim@mp_player_intupperraining_cash'
local TIP_ANIM = 'idle_a'

local function tipDancer(entity)
    local input = lib.inputDialog('Tip the dancer', {
        { type = 'number', label = 'Amount', default = 50, min = Config.Tips.min, max = Config.Tips.max, required = true },
    })
    if not input then return end

    lib.requestAnimDict(TIP_ANIM_DICT)
    TaskPlayAnim(cache.ped, TIP_ANIM_DICT, TIP_ANIM, 8.0, -8.0, 3000, 48, 0, false, false, false)
    TriggerServerEvent('bm_dance:tip', GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)), math.floor(input[1]))
end

local function canTipPlayer(entity)
    if entity == cache.ped then return false end
    local player = NetworkGetPlayerIndexFromPed(entity)
    return player ~= -1 and Player(GetPlayerServerId(player)).state.danceKind ~= nil
end

local function findPoleDancer(pole)
    local players = GetActivePlayers()
    for i = 1, #players do
        local ped = GetPlayerPed(players[i])
        local onPole = Player(GetPlayerServerId(players[i])).state.danceKind == 'pole'
        if ped ~= cache.ped and onPole and #(GetEntityCoords(ped) - pole.position.xyz) <= 4.0 then
            return ped
        end
    end
end

local function addPoleZone(pole)
    return exports.ox_target:addBoxZone({
        coords = pole.position,
        size = pole.size or vec3(1, 1, 3),
        rotation = pole.position.w,
        debug = Config.Debug,
        options = {
            {
                label = 'Pole Dance',
                icon = 'fas fa-shoe-prints',
                distance = 3.0,
                groups = pole.job,
                canInteract = function() return canUsePole(pole) end,
                onSelect = function() openMenu(pole) end,
            },
            {
                name = 'bm_dance_tip_pole',
                label = 'Leave Tip',
                icon = 'fas fa-dollar-sign',
                distance = Config.Tips.distance,
                canInteract = function() return findPoleDancer(pole) ~= nil end,
                onSelect = function() tipDancer(findPoleDancer(pole)) end,
            },
        },
    })
end

local function createTargets()
    destroyTargets()
    if Config.UseModels then
        modelTargetCount = modelTargetCount + 1
        modelTargets[modelTargetCount] = exports.ox_target:addModel(POLE_MODEL, {
            {
                label = 'Pole Dance',
                icon = 'fas fa-shoe-prints',
                distance = 3.0,
                offsetSize = 2.0,
                offset = vec3(1, 1, 1),
                onSelect = function(data)
                    openMenu(getNearestPole(GetEntityCoords(data.entity)))
                end,
            },
        })
    end
    for i = 1, #Config.Poles do
        local pole = Config.Poles[i]
        local prop = pole.spawn and spawnPoleProp(pole) or nil
        handleCount = handleCount + 1
        handles[handleCount] = { zone = addPoleZone(pole), prop = prop }
    end
end

local function formatPoleLine(pole)
    local p = pole.position
    return ('{ position = vec4(%.4f, %.4f, %.4f, %.4f), spawn = true },'):format(p.x, p.y, p.z, p.w)
end

local function formatDancerLine(pole)
    local o = pole.dancer
    return ('dancer = vec4(%.4f, %.4f, %.4f, %.4f), dancerDance = %d,'):format(o.x, o.y, o.z, o.w, pole.dancerDance)
end

local function stopPlacement()
    if not placement then return end
    lib.hideTextUI()
    FreezeEntityPosition(cache.ped, false)
    if DoesEntityExist(placement.ped) then
        DeleteEntity(placement.ped)
    end
    placement = nil
end

local function showPlacementHelp()
    if placement.menuFocus then
        lib.showTextUI(('[W/A/S/D] move  \n[R/Z] height  \n[Q/E] rotate  \n[G] dance #%d  \n[ENTER] save  \n[BACKSPACE] cancel  \n[H] free control')
            :format(placement.dance))
    else
        lib.showTextUI('FREE CONTROL - [H] back to the dancer menu')
    end
end

local function savePlacement()
    local p = placement
    p.pole.dancer = p.offset
    p.pole.dancerDance = p.dance
    local line = formatDancerLine(p.pole)
    stopPlacement()
    lib.setClipboard(line)
    lib.notify({ title = 'Dancer', description = line, type = 'success' })
end

local function nudgePlacement(d)
    local o = placement.offset
    placement.offset = vec4(o.x + d[1], o.y + d[2], o.z + d[3], o.w + d[4])
    placement.dirty = true
end

local function toggleFocus()
    placement.menuFocus = not placement.menuFocus
    FreezeEntityPosition(cache.ped, placement.menuFocus)
    showPlacementHelp()
end

local function cycleDance()
    placement.dance = placement.dance % 3 + 1
    placement.dirty = true
    showPlacementHelp()
end

-- Returns false when the placement has ended.
local function handleMenuInput()
    DisableAllControlActions(0)
    EnableControlAction(0, 1, true)
    EnableControlAction(0, 2, true)

    if IsDisabledControlJustPressed(0, 194) then
        stopPlacement()
        return false
    end
    if IsDisabledControlJustPressed(0, 18) then
        savePlacement()
        return false
    end
    if IsDisabledControlJustPressed(0, 47) then
        cycleDance()
    end
    for control, d in pairs(NUDGES) do
        if IsDisabledControlPressed(0, control) then
            nudgePlacement(d)
        end
    end
    return true
end

local function refreshDancer()
    local p = placement
    ClearPedTasksImmediately(p.ped)
    playDance({ ped = p.ped, pole = p.pole, offset = p.offset, id = p.dance })
    p.dirty = false
end

local function runPlacementLoop()
    while placement do
        if IsDisabledControlJustPressed(0, 74) then
            toggleFocus()
        end
        if placement.menuFocus and not handleMenuInput() then
            return
        end
        if placement.dirty then
            refreshDancer()
        end
        Wait(0)
    end
end

local function spawnDancerPed(pole)
    local pos = pole.position
    lib.requestModel(DANCER_MODEL)
    local ped = CreatePed(4, joaat(DANCER_MODEL), pos.x, pos.y, pos.z, 0.0, true, false)
    SetModelAsNoLongerNeeded(joaat(DANCER_MODEL))
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityCollision(ped, false, false)
    SetEntityAlpha(ped, 200, false)
    return ped
end

local function startPlacement()
    if placement then return end
    local aim = getAimPoint()
    local pole = getNearestPole(aim)
    if not pole or #(pole.position.xyz - aim) > PLACE_RANGE then
        lib.notify({ title = 'Dancer', description = 'Aim at a pole first (within 5 m)', type = 'error' })
        return
    end

    placement = {
        pole = pole,
        ped = spawnDancerPed(pole),
        offset = pole.dancer or DEFAULT_DANCER,
        dance = pole.dancerDance or 3,
        dirty = true,
        menuFocus = true,
    }
    FreezeEntityPosition(cache.ped, true)
    showPlacementHelp()
    CreateThread(runPlacementLoop)
end

local function onNewDancer()
    if GetInvokingResource() then return end
    startPlacement()
end

local function onNewPole()
    if GetInvokingResource() then return end
    local spot = pickPoleSpot()
    if not spot then
        print('Action canceled.')
        return
    end
    local pole = { position = vec4(spot.x, spot.y, spot.z, 0.0), spawn = true }
    Config.Poles[#Config.Poles + 1] = pole
    lib.setClipboard(formatPoleLine(pole))
    lib.notify({ title = 'Dance', description = 'New pole added to clipboard', type = 'success' })
    createTargets()
end

local function onResourceStart(resourceName)
    if GetCurrentResourceName() == resourceName then
        createTargets()
    end
end

local function onResourceStop(resourceName)
    if GetCurrentResourceName() == resourceName then
        stopPlacement()
        destroyTargets()
    end
end

exports.ox_target:addGlobalPlayer({
    {
        name = 'bm_dance_tip',
        label = 'Tip Dancer',
        icon = 'fas fa-dollar-sign',
        distance = Config.Tips.distance,
        canInteract = canTipPlayer,
        onSelect = function(data) tipDancer(data.entity) end,
    },
})

RegisterNetEvent('bm_dance:dancer', onNewDancer)
RegisterNetEvent('bm_dance:pole', onNewPole)
AddEventHandler('onClientResourceStart', onResourceStart)
AddEventHandler('onClientResourceStop', onResourceStop)
