local xSound = exports.xsound

local boomboxZones = {}

TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

ESX.RegisterUsableItem("hifi", function(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    xPlayer.removeInventoryItem("hifi", 1)
    TriggerClientEvent("esx_boombox:UseItem", playerId)
end)


RegisterServerEvent("esx_boombox:soundStatus")
AddEventHandler("esx_boombox:soundStatus", function(type, songIdentificator, data)
    if type == "play" then
        boomboxZones[data.songIdentificator] = data
    elseif type == "placed_boombox" then
        boomboxZones[data.songIdentificator] = data
    end
    TriggerClientEvent("esx_boombox:soundStatus", -1, type, songIdentificator, data)

end)


RegisterServerEvent("esx_boombox:getZones")
AddEventHandler("esx_boombox:getZones", function()
    if next(boomboxZones) then
        TriggerClientEvent("esx_boombox:getZones", boomboxZones)
    end
end)


RegisterServerEvent("esx_boombox:destroyBoombox")
ADdEventHandler("esx_boombox:destroyBoombox", function(songIdentificator)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    boomboxZones[songIdentificator] = nil
    xPlayer.addInventoryItem("hifi", 1)
    TriggerClientEvent("esx_boombox:soundStatus", -1, "deleteBoombox", songIdentificator)
end)
