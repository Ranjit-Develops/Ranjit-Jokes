local QBCore = exports['qb-core']:GetCoreObject()


local jokeCooldown = {}

QBCore.Commands.Add(Config.CommandName, 'Tell a random joke', {}, false, function(source, args)
    local currentTime = os.time()

    if jokeCooldown[source] and jokeCooldown[source] > currentTime then
        local timeRemaining = jokeCooldown[source] - currentTime
        TriggerClientEvent('QBCore:Notify', source, 'Please wait ' .. timeRemaining .. ' seconds before telling another joke.', 'error')
        return
    end

    PerformHttpRequest('https://icanhazdadjoke.com/', function(errorCode, resultData, resultHeaders)
        if errorCode == 200 then
            local responseData = json.decode(resultData)
            local joke = responseData.joke

            local ped = GetPlayerPed(source)
            local pCoords = GetEntityCoords(ped)

            local Players = QBCore.Functions.GetPlayers()
            for i = 1, #Players do
                local Player = Players[i]
                local target = GetPlayerPed(Player)
                local tCoords = GetEntityCoords(target)
                if target == ped or #(pCoords - tCoords) < 20 then
                    TriggerClientEvent('QBCore:Command:ShowMe3D', Player, source, joke)
                end
            end

            -- Set cooldown for the player
            jokeCooldown[source] = currentTime + Config.CooldownTime
        else
            print('Error fetching joke from API')
        end
    end, 'GET', '', { ['Accept'] = 'application/json' })
end, 'user')
