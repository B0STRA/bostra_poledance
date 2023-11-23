lib.addCommand('newpole', {
    help = 'Add a new dance pole',
    params = {},
    restricted = 'group.admin'
}, function(source, args, raw)
    TriggerClientEvent('bm_dance:pole', source)
end)
