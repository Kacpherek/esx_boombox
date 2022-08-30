local boomboxZones = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('boombox', function(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    xPlayer.removeInventoryItem('boombox', 1)
    TriggerClientEvent('esx_boombox:UseItem', playerId)
end)


RegisterServerEvent('esx_boombox:soundStatus')
AddEventHandler('esx_boombox:soundStatus', function(type, songIdentificator, data)
    if type == 'play' then
        boomboxZones[songIdentificator] = data
    elseif type == 'placed_boombox' then
        boomboxZones[songIdentificator] = data
    end
    TriggerClientEvent('esx_boombox:soundStatus', -1, type, songIdentificator, data)

end)


RegisterServerEvent('esx_boombox:getZones')
AddEventHandler('esx_boombox:getZones', function()
    if next(boomboxZones) then
        TriggerClientEvent('esx_boombox:getZones', boomboxZones)
    end
end)


RegisterServerEvent('esx_boombox:destroyBoombox')
AddEventHandler('esx_boombox:destroyBoombox', function(songIdentificator)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    boomboxZones[songIdentificator] = nil
    xPlayer.addInventoryItem('boombox', 1)
    TriggerClientEvent('esx_boombox:soundStatus', -1, 'deleteBoombox', songIdentificator)
end)
