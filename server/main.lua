RegisterServerEvent('js5m-fwens:server:requestFwen', function(id)
    local src = source
    local playerName = GetPlayerName(src)
    TriggerClientEvent('js5m-fwens:client:requestFwen', id, src, playerName)
end)

RegisterServerEvent('js5m-fwens:server:respondFwen', function(id, response)
    local src = source
    local sourceName = GetPlayerName(src)
    local targetName = GetPlayerName(id)
    if response == 'confirm' then
        TriggerClientEvent('js5m-fwens:client:acceptFwen', src, targetName)
        TriggerClientEvent('js5m-fwens:client:acceptFwen', id, sourceName)
    elseif response == 'cancel' then
        TriggerClientEvent('js5m-fwens:client:denyFwen', id, sourceName)
    end
end)

RegisterServerEvent('js5m-fwens:server:cancelFwen', function(id)
    local src = source
    local sourceName = GetPlayerName(src)
    local targetName = GetPlayerName(id)
    TriggerClientEvent('js5m-fwens:client:cancelFwen', src, targetName, id)
    TriggerClientEvent('js5m-fwens:client:cancelFwen', id, sourceName, id)
end)