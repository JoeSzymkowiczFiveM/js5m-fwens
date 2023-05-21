local kvp = GetResourceKvpString('fwens')
local fwens = kvp and json.decode(kvp) or {}

-- AddEventHandler('onResourceStop', function(resourceName) --uncommenting this eventhandler will erase the `fwens` kvp, is used this for testing
--     if (GetCurrentResourceName() ~= resourceName) then return end
--     SetResourceKvp('fwens', json.encode({}))
-- end)

local function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

local function requestFwen(data)
    local id = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
    TriggerServerEvent('js5m-fwens:server:requestFwen', id)
end

local function cancelFwen(data)
    local id = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
    TriggerServerEvent('js5m-fwens:server:cancelFwen', id)
end

local function requestFwenTarget(entity)
    local retval = false
    local name = GetPlayerName(NetworkGetPlayerIndexFromPed(entity))
    if not fwens[name] then
        retval = true
    end
    return retval
end

local function cancelFwenTarget(entity)
    local retval = false
    local name = GetPlayerName(NetworkGetPlayerIndexFromPed(entity))
    if fwens[name] then
        retval = true
    end
    return retval
end

CreateThread(function()
    while true do
        local myCoords = GetEntityCoords(cache.ped)
        local players = lib.getNearbyPlayers(myCoords, 15, false)
        if #players > 0 then
            for i = 1, #players do
                local player = players[i]
                local playerName = GetPlayerName(NetworkGetPlayerIndexFromPed(player.ped))
                if fwens[playerName] ~= nil then
                    DrawText3D(player.coords.x, player.coords.y, player.coords.z + 1.0, playerName)
                else
                    DrawText3D(player.coords.x, player.coords.y, player.coords.z + 1.0, 'Unknown #'..GetPlayerServerId(player.id))
                end
            end
        else
            Wait(1500)
        end
        Wait(1)
    end
end)

RegisterNetEvent("js5m-fwens:client:requestFwen", function(id, name)
    local incId = id
    local alert = lib.alertDialog({
        header = 'Incoming Fwen Request',
        content = name .. ' wishes to be your fwen.',
        centered = true,
        cancel = true,
        labels = {
            ['cancel'] = 'Decline',
            ['confirm'] = 'Accept',
        }
    })

    TriggerServerEvent('js5m-fwens:server:respondFwen', incId, alert)
end)

RegisterNetEvent("js5m-fwens:client:acceptFwen", function(name)
    lib.notify({
        title = 'New Fwen!',
        description = name .. ' has been added as a fwen',
        type = 'success'
    })

    fwens[name] = true
    SetResourceKvp('fwens', json.encode(fwens))
end)

RegisterNetEvent("js5m-fwens:client:cancelFwen", function(name, ender)
    local newFwens = {}
    for k, _ in pairs(fwens) do
        if k ~= name then
            newFwens[k] = true
        end
    end
    fwens = newFwens

    SetResourceKvp('fwens', json.encode(fwens))
    if GetPlayerServerId(NetworkGetPlayerIndexFromPed(cache.ped)) == ender then
        lib.notify({
            title = 'Fwenship Ended!',
            description = name .. ' ended your fwenship.',
            type = 'error',
        })
    else
        lib.notify({
            title = 'Fwenship Ended!',
            description = 'You ended your fwenship with ' .. name,
            type = 'error',
        })
    end
end)

RegisterNetEvent("js5m-fwens:client:denyFwen", function(name)
    lib.notify({
        title = 'Request Denied!',
        description = name .. ' denied your fwen request. #SADGE',
        type = 'error',
    })
end)

local options = {
    {
        name = 'js5m:requestFwen',
        icon = 'fa-solid fa-user-plus',
        label = 'Request Fwenship',
        canInteract = function(entity)
            return requestFwenTarget(entity)
        end,
        onSelect = function(entity)
            requestFwen(entity)
        end
    },
    {
        name = 'js5m:cancelFwen',
        icon = 'fa-solid fa-user-xmark',
        label = 'Cancel Fwenship',
        canInteract = function(entity)
            return cancelFwenTarget(entity)
        end,
        onSelect = function(entity)
            cancelFwen(entity)
        end
    }
}

exports.ox_target:addGlobalPlayer(options)