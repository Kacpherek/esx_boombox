-- Variables
local xSound = exports.xsound
local musicZones = {}
local isDead = false
local menuOpen = false;
local lastEntity = nil
local currentAction = nil
local closestEntity;
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end
    TriggerServerEvent('esx_boombox:getZones')
end)

-- Functions
local function playMusic(boombox)
    menuOpen = true
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'boomboxPlayMusic', {
        title = _U('play_music'),
        align = 'center',
    }, function(data, menu)
        local value = data.value
        if value then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local object = GetClosestObjectOfType(playerCoords, 3.0, GetHashKey('prop_boombox_01'), false, false, false)
            if DoesEntityExist(object) then
                local boobmoxCoords = GetEntityCoords(object)
                local musicData = {
                    boobmoxCoords = boobmoxCoords,
                    entityId = object,
                    link = value,
                    volume = 0.5
                }
                local songIdentificator = musicData.entityId
                TriggerServerEvent('esx_boombox:soundStatus', 'play', songIdentificator, musicData)
                menu.close()
            end
        else
            ESX.ShowNotification(_U('url_missing'))
        end
    end, function(data, menu)
        menu.close()
    end)
end

local function startAnimation(lib, anim)
    ESX.Streaming.RequestAnimDict(lib, function()
        TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    end)
end

local function stopMusic(songIdentificator)
    TriggerServerEvent('esx_boombox:soundStatus', 'stop', songIdentificator)
end

local function changeVolume(songIdentificator)
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'boomboxChangeVolume', {
        title = _U('change_volume') .. ' 1-100',
        align = 'center',
    }, function(data, menu)
        menu.close()
        local value = data.value
        if type(tonumber(data.value)) then
            musicZones[songIdentificator].volume = value / 100
            TriggerServerEvent('esx_boombox:soundStatus', 'volume', songIdentificator, musicZones[songIdentificator])
        else
            ESX.ShowNotification(_U('invalid_volume'))
        end
    end, function(data, menu)

        menu.close()
    end)

end

local function pickup_Boombox(songIdentificator)
    TriggerEvent('esx_boombox:pickupBoombox', songIdentificator)
end

local function openBoomboxMenu(boombox)
    menuOpen = true
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boomboxMenu', {
        title = _U('boombox_menu'),
        align = 'center',
        elements = {
            { label = _U('play_music'), value = 'play_music' },
            { label = _U('stop_music'), value = 'stop_music' },
            { label = _U('change_volume'), value = 'change_volume' },
            { label = _U('pickup_boombox'), value = 'pickup_boombox' },
        }
    }, function(data, menu)
        local currentVal = data.current.value
        if currentVal == 'play_music' then
            playMusic(boombox)
        elseif currentVal == 'stop_music' then
            stopMusic(boombox)
        elseif currentVal == 'change_volume' then
            changeVolume(boombox)
        elseif currentVal == 'pickup_boombox' then
            menu.close()
            menuOpen = false
            pickup_Boombox(boombox)
        end
    end, function(data, menu)
        menuOpen = false
        menu.close()
    end)
end

-- Events
RegisterNetEvent('esx_boombox:soundStatus')
AddEventHandler('esx_boombox:soundStatus', function(type, songIdentificator, data)
    if type == 'play' then
        musicZones[songIdentificator] = data
        xSound:PlayUrlPos(songIdentificator, data.link, 1, data.boobmoxCoords)
        xSound:setSoundDynamic(songIdentificator, true)
        xSound:Position(songIdentificator, data.boobmoxCoords)
        xSound:Distance(songIdentificator, Config.Distance)
        xSound:setSoundLoop(songIdentificator, false)
        xSound:setVolumeMax(songIdentificator, data.volume)
    elseif type == 'stop' then
        xSound:Destroy(songIdentificator)
    elseif type == 'volume' then
        xSound:setVolumeMax(songIdentificator, data.volume)
    elseif type == 'placed_boombox' then
        musicZones[songIdentificator] = data
    elseif type == 'deleteBoombox' then
        musicZones[songIdentificator] = nil
        if xSound:soundExists(songIdentificator) then
            xSound:Destroy(songIdentificator)
        end
    end
end)
RegisterNetEvent("esx_boombox:UseItem")
AddEventHandler('esx_boombox:UseItem', function()
    startAnimation('anim@heists@money_grab@briefcase', 'put_down_case')
    Citizen.Wait(1000)
    ClearPedTasks(PlayerPedId())
    ESX.Game.SpawnObject('prop_boombox_01', GetEntityCoords(PlayerPedId()), function(object)
        if DoesEntityExist(object) then
            local boobmoxCoords = GetEntityCoords(object)
            local musicData = {
                boobmoxCoords = boobmoxCoords,
                entityId = object,
                link = ''
            }
            local songIdentificator = musicData.entityId
            TriggerServerEvent('esx_boombox:soundStatus', 'placed_boombox', songIdentificator, musicData)
        end
    end)
end)
RegisterNetEvent('esx_boombox:pickupBoombox')
AddEventHandler('esx_boombox:pickupBoombox', function(entityId)
    NetworkRequestControlOfEntity(entityId)
    startAnimation('anim@heists@narcotics@trash', 'pickup')
    Citizen.Wait(700)
    SetEntityAsMissionEntity(entityId, false, true)
    DeleteEntity(entityId)
    if not DoesEntityExist(entityId) then
        TriggerServerEvent('esx_boombox:destroyBoombox', entityId)
    end
    Citizen.Wait(500)
    ClearPedTasks(PlayerPedId())
end)
RegisterNetEvent('esx_boombox:getZones')
AddEventHandler('esx_boombox:getZones', function(data)
    musicZones = data
end)
RegisterNetEvent("esx_ambulancejob:revive")
AddEventHandler('esx_ambulancejob:revive', function(data)
    isDead = false
end)
RegisterNetEvent("esx:onPlayerDeath")
AddEventHandler('esx:onPlayerDeath', function(data)
    IsDead = true
end)
-- Threads
Citizen.CreateThread(function()
    local sleep = 500;
    while not isDead do
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local closestDistance = -1
        closestEntity = nil
        local object = GetClosestObjectOfType(coords, 3.0, GetHashKey('prop_boombox_01'), false, false, false)
        if DoesEntityExist(object) then
            if musicZones[object] then
                local dist = GetEntityCoords(object).xy - coords.xy
                if closestDistance == -1 or closestDistance > dist then
                    closestDistance = #dist
                    closestEntity = object
                end
            end
        end
        if closestDistance ~= -1 and closestDistance <= 3.0 then
            if lastEntity ~= closestEntity and not menuOpen then
                SetTextComponentFormat('STRING')
                AddTextComponentString(_U('help_prompt'))
                DisplayHelpTextFromStringLabel(0, 0, 1, -1)
                lastEntity = closestEntity
                currentAction = 'music'
            end
        else
            if lastEntity then
                lastEntity, currentAction = nil, nil
            end
        end
        Citizen.Wait(sleep)
    end
end)
RegisterCommand('interact', function()
    if currentAction == 'music' then
        openBoomboxMenu(closestEntity)
    end
end, false)
RegisterKeyMapping('interact', _U('interact'), 'keyboard', 'e')
