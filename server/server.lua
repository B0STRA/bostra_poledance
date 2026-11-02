local Config = require 'config.config'

local lastTipAt = {}
local occupiedPoles = {}

local function syncOccupiedPoles()
    local snapshot = {}
    for key, owner in pairs(occupiedPoles) do
        snapshot[key] = owner
    end
    GlobalState:set('bm_dance_occupied', snapshot, true)
end

local function releasePolesOf(owner)
    for key, poleOwner in pairs(occupiedPoles) do
        if poleOwner == owner then
            occupiedPoles[key] = nil
        end
    end
    syncOccupiedPoles()
end

lib.callback.register('bm_dance:claimPole', function(source, key)
    local owner = occupiedPoles[key]
    if owner and owner ~= source then return false end
    occupiedPoles[key] = source
    syncOccupiedPoles()
    return true
end)

local function onReleasePole(key)
    local src = source
    if occupiedPoles[key] ~= src then return end
    occupiedPoles[key] = nil
    syncOccupiedPoles()
end

local function sendNewPole(source)
    TriggerClientEvent('bm_dance:pole', source)
end

local function sendNewDancer(source)
    TriggerClientEvent('bm_dance:dancer', source)
end

local function notifyPlayer(playerId, description, notifyType)
    TriggerClientEvent('ox_lib:notify', playerId, { description = description, type = notifyType })
end

local function isTipValid(patron, dancerId, amount)
    if type(amount) ~= 'number' or amount ~= math.floor(amount) then return false end
    if amount < Config.Tips.min or amount > Config.Tips.max then return false end
    if dancerId == patron or not GetPlayerName(dancerId) then return false end
    if not Player(dancerId).state.danceKind then return false end
    if (lastTipAt[patron] or 0) + Config.Tips.cooldown > os.time() then return false end

    local distance = #(GetEntityCoords(GetPlayerPed(patron)) - GetEntityCoords(GetPlayerPed(dancerId)))
    return distance <= Config.Tips.range
end

local function canCarry(playerId, amount)
    return exports.ox_inventory:CanCarryItem(playerId, 'money', amount)
end

local function onTip(dancerId, amount)
    local patron = source
    if not isTipValid(patron, dancerId, amount) then return end
    if not canCarry(dancerId, amount) then
        notifyPlayer(patron, 'The dancer cannot carry that much cash', 'error')
        return
    end
    if exports.ox_inventory:GetItemCount(patron, 'money') < amount then
        notifyPlayer(patron, 'You do not have enough cash', 'error')
        return
    end

    exports.ox_inventory:RemoveItem(patron, 'money', amount)
    exports.ox_inventory:AddItem(dancerId, 'money', amount)
    lastTipAt[patron] = os.time()
    notifyPlayer(patron, ('You tipped $%d'):format(amount), 'success')
    notifyPlayer(dancerId, ('You received a $%d tip'):format(amount), 'success')
end

local function onPlayerDropped()
    lastTipAt[source] = nil
    releasePolesOf(source)
end

lib.addCommand('newpole', {
    help = 'Add a new dance pole',
    restricted = 'group.admin',
}, sendNewPole)

lib.addCommand('newdancer', {
    help = 'Calibrate the dancer offset for the pole you are aiming at',
    restricted = 'group.admin',
}, sendNewDancer)

RegisterNetEvent('bm_dance:tip', onTip)
RegisterNetEvent('bm_dance:releasePole', onReleasePole)
AddEventHandler('playerDropped', onPlayerDropped)
