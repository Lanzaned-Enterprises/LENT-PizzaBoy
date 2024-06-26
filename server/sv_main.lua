-- [[ QBCore ]] --
local QBCore = exports['qb-core']:GetCoreObject()

-- [[ Variables ]] --
local Jobs = {}
local NewPayment

-- [[ Resource Metadata ]] --


-- [[ Events ]] --
RegisterNetEvent('LENT-PizzaJob:Server:StartJob', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Config.ResourceSettings['Job']['Required'] then
        if Player.PlayerData.job.name == Config.ResourceSettings['Job']['JobName'] then
            TriggerEvent('LENT-PizzaJob:Server:StartJobProcess', src)
        else
            exports['LENT-Library']:ServerNotification('You are not employed by `Pizza This..`!', 'error')
        end
    else
        TriggerEvent('LENT-PizzaJob:Server:StartJobProcess', src)
    end
end)

RegisterNetEvent('LENT-PizzaJob:Server:StartJobProcess', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src).PlayerData.citizenid
    Jobs[Player] = {
        ['HouseLocation'] = vector4(0, 0, 0, 0),
        ['VehicleId'] = 0,
        ['Payment'] = 0,
    }

    local coords, payment = GetLocationInfo()

    Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid]['HouseLocation'] = coords
    Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid]['Payment'] = payment

    TriggerClientEvent('LENT-PizzaJob:Client:CreateJob', src)
end)

RegisterNetEvent('LENT-PizzJob:Server:GiveVehicleKeys', function(Plate, Network)
    local src = source

    Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid]['VehicleId'] = Network

    local BlipCoords = Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid]['HouseLocation']
    local PlayerCitizenId = QBCore.Functions.GetPlayer(src).PlayerData.citizenid

    TriggerClientEvent('vehiclekeys:client:SetOwner', src, Plate)
    TriggerClientEvent('LENT-PizzaJob:Client:AddBoxTarget', src, PlayerCitizenId, BlipCoords)

    TriggerClientEvent('LENT-PizzaJob:Client:DrawWaypoint', src, BlipCoords)
end)

RegisterNetEvent('LENT-PizzaJob:Server:DeliverPizza', function()
    local src = source

    TriggerClientEvent('LENT-PizzaJob:Client:CanReturn', src)
    TriggerEvent('LENT-PizzaJob:Server:NewJob', src)
    TriggerClientEvent('LENT-PizzaJob:Client:GetPlaySlip', src)
end)

RegisterNetEvent('LENT-PizzaJob:Server:NewJob', function(source)
    local src = source

    local coords, payment = GetLocationInfo()

    Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid]['HouseLocation'] = coords
    NewPayment = Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid]['Payment'] + payment

    local BlipCoords = Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid]['HouseLocation']
    local PlayerCitizenId = QBCore.Functions.GetPlayer(src).PlayerData.citizenid

    TriggerClientEvent('LENT-PizzaJob:Client:AddBoxTarget', src, PlayerCitizenId, BlipCoords)

    TriggerClientEvent('LENT-PizzaJob:Client:DrawWaypoint', src, BlipCoords)
end)

RegisterNetEvent('LENT-PizzaJob:Server:CancelJob', function()
    local src = source

    Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid] = nil

    TriggerClientEvent('LENT-PizzaJob:Client:ClearVehcile', src)
    TriggerClientEvent('LENT-PizzaJob:Client:ClearAll', src)
end)

RegisterNetEvent('LENT-PizzaJob:Server:ReturnVehicle', function(JobsDone)
    local src = source

    TriggerClientEvent('LENT-PizzaJob:Client:ClearVehcile', src)
    TriggerClientEvent('LENT-PizzaJob:Client:ClearAll', src)

    TriggerEvent('LENT-PizzaJob:Server:GetPayment', src, JobsDone)
end)

RegisterNetEvent('LENT-PizzaJob:Server:GetPayment', function(source, JobsDone)
    local src = source
    JobsDone = tonumber(JobsDone)

    if JobsDone == 0 then
        Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid] = nil
        return
    end

    local bonus = 0
    local pay = Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid]['Payment']

    if JobsDone > 5 then
        bonus = math.ceil((pay / 10) * 5)
    elseif JobsDone > 10 then
        bonus = math.ceil((pay / 10) * 7)
    elseif JobsDone > 15 then
        bonus = math.ceil((pay / 10) * 10)
    elseif JobsDone > 20 then
        bonus = math.ceil((pay / 10) * 12)
    end

    local check = bonus + pay

    local Player = QBCore.Functions.GetPlayer(src)

    if Config.ResourceSettings['Payment']['Type'] == 'bank' then
        if Config.QBCoreSettings['Renewed-Banking'] then
            local cid = Player.PlayerData.citizenid
            local title = 'Salary Pizza This...'
            local name = ('%s %s'):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
            local txt = 'Received Pay for working for Pizza This...'
            local issuer = 'Jack Roch @ Pizza This...'
            local reciver = name
            local type = 'deposit'
            exports['Renewed-Banking']:handleTransaction(cid, title, check, txt, issuer, reciver, type)
        end

        Player.Functions.AddMoney('bank', check, 'Pizza-Deliveries')
    else
        Player.Functions.AddMoney('cash', check, 'Pizza-Deliveries')
    end

    Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid] = nil
end)

RegisterNetEvent('LENT-PizzaJob:Server:RemoveAllZones', function(PlayerCitizenId)
    TriggerClientEvent('LENT-PizzaJob:Client:RemoveZoneSync', -1, PlayerCitizenId)
end)

RegisterNetEvent('LENT-PizzaJob:Server:TipPlayer', function()
    local src = source
    if Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid] ~= nil then
        local Player = QBCore.Functions.GetPlayer(src)

        local Tip = Config.ResourceSettings['Payment']['TipsAmount']

        Player.Functions.AddMoney('cash', Tip)
        exports['LENT-Library']:SendNotification("You just made: " .. Tip .. " In tips!", "success", 2500)
        exports['LENT-Library']:SendServerPhoneEmail('Pizza This', 'Tips', 'You\'ve received: $' ..Tip.. ' from the customer! Put that in your pocket and keep it safe!')
    else
        return
    end
end)

-- [[ Functions ]] --
function GetLocationInfo()
    local data = Config.ResourceSettings['DeliveryData'][math.random(#Config.ResourceSettings['DeliveryData'])]
    local coords = data.Coords[math.random(#data.Coords)]
    local payment = data.Payment

    return coords, payment
end

-- [[ Threads ]] --


-- [[ Other ]] --