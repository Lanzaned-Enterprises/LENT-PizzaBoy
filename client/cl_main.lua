-- [[ QBCore ]] --
local QBCore = exports['qb-core']:GetCoreObject()

-- [[ Variables ]] --
local CurrentlyOnJob = false
local returnVehicle = false

local JobsDone = 0

local DoorCoords = vector3(0, 0, 0)

local PizzaVehicle = nil
local DeliveryBlip = nil

-- [[ Resource Metadata ]] --
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        RemoveBlip(DeliveryBlip)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        PlayerJob = QBCore.Functions.GetPlayerData().job
    end
end)


-- [[ Events ]] --
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('LENT-PizzaBoy:Client:SendNotify', function(text, type, time)
    Notify('cl', text, type, time)
end)

RegisterNetEvent('LENT-PizzaJob:Client:CreateJob', function()
    local vehicleHash = Config.ResourceSettings['JobData']['Vehicle']['Model']
    QBCore.Functions.LoadModel(vehicleHash)
    local VehicleSpawn = Config.ResourceSettings['JobData']['Vehicle']['Coords']
    PizzaVehicle = CreateVehicle(vehicleHash, VehicleSpawn.x, VehicleSpawn.y, VehicleSpawn.z, VehicleSpawn.w, true, true)
    if Config.ResourceSettings['JobData']['Vehicle']['Customize'] then
        SetVehicleModKit(PizzaVehicle, 0)
        SetVehicleMod(PizzaVehicle, 48, 1)
        SetVehicleColours(PizzaVehicle, 131, 12)
    end

    if Config.ResourceSettings['JobData']['Vehicle']['Model'] == 'admiral3taxi' then
        SetVehicleLivery(PizzaVehicle, 1)
        SetVehicleExtra(PizzaVehicle, 0, 0)
    end

    local Plate = GetVehicleNumberPlateText(PizzaVehicle)
    local Network = NetworkGetNetworkIdFromEntity(PizzaVehicle)

    SetEntityAsMissionEntity(PizzaVehicle)
    SetNetworkIdExistsOnAllMachines(PizzaVehicle, true)
    NetworkRegisterEntityAsNetworked(PizzaVehicle)
    SetNetworkIdCanMigrate(Network, true)

    SetVehicleDirtLevel(PizzaVehicle, 0)
    SetVehicleEngineOn(PizzaVehicle, true, true)
    SetVehicleDoorsLocked(PizzaVehicle, 1)

    exports[Config.QBCoreSettings['Fuel']]:SetFuel(PizzaVehicle, 100)

    CurrentlyOnJob = true

    TriggerServerEvent('LENT-PizzJob:Server:GiveVehicleKeys', Plate, Network)
end)

RegisterNetEvent('LENT-PizzaJob:Client:AddBoxTarget', function(PlayerCitizenId, BlipCoords)
    DoorCoords = BlipCoords

    if Config.LENTSettings['Debug'] then
        exports['qb-target']:AddBoxZone(PlayerCitizenId, vector3(DoorCoords.x, DoorCoords.y, DoorCoords.z), 3.5, 2.0, {
            name = PlayerCitizenId,
            heading = DoorCoords.w,
            debugPoly = Config.LENTSettings['Debug'],
            minZ = DoorCoords.z - 1,
            maxZ = DoorCoords.z + 1,
            }, {
                options = {
                    { -- Deliver the pizza
                        icon = 'fas fa-circle',
                        label = 'Deliver Pizza',
                        canInteract = function()
                            return not cl_delivered
                        end,
                        action = function()
                            TriggerEvent('LENT-PizzaJob:Client:DeliverPizza', PlayerCitizenId)
                        end,
                    },
                },
            distance = 2.0
        })

        print('Zone with Name: ' .. PlayerCitizenId .. ' Was created at: ' .. DoorCoords)
    else
        exports['qb-target']:AddBoxZone(PlayerCitizenId, vector3(DoorCoords.x, DoorCoords.y, DoorCoords.z), 3.5, 2.0, {
            name = PlayerCitizenId,
            heading = DoorCoords.w,
            debugPoly = false,
            minZ = DoorCoords.z - 1,
            maxZ = DoorCoords.z + 1,
            }, {
                options = {
                    { -- Deliver the pizza
                        icon = 'fas fa-circle',
                        label = 'Deliver Pizza',
                        canInteract = function()
                            return not cl_delivered
                        end,
                        action = function()
                            TriggerEvent('LENT-PizzaJob:Client:DeliverPizza', PlayerCitizenId)
                        end,
                    },
                },
            distance = 2.0
        })
    end
end)

RegisterNetEvent('LENT-PizzaJob:Client:DeliverPizza', function(PlayerCitizenId)
    ExecuteCommand('e knock')

    QBCore.Functions.Progressbar('pizza_lent_delivery', 'Knocking on Door...', Config.ResourceSettings['ProggressTime'], false, true, { -- Name | Label | Time | useWhileDead | canCancel
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Play When Done
        ExecuteCommand('e c')

        JobsDone = JobsDone + 1

        RemoveBlip(DeliveryBlip)

        TriggerServerEvent('LENT-PizzaJob:Server:RemoveAllZones', PlayerCitizenId)
        TriggerServerEvent('LENT-PizzaJob:Server:DeliverPizza')

        if Config.ResourceSettings['Payment']['Tips'] then
            local TippingChance = math.random(0, 100)

            if TippingChance >= Config.ResourceSettings['Payment']['TipsChance'] then
                TriggerServerEvent("LENT-PizzaJob:Server:TipPlayer")
            end
        end


        Notify('cl', 'You delivered the Pizza!', 'success')
    end, function() -- Play When Cancel
        ExecuteCommand('e c')
        Notify('cl', 'You cancelled the progress', 'error')
    end)
end)

RegisterNetEvent('LENT-PizzaJob:Client:GetPaySlip', function()
    if JobsDone > 0 then
        TriggerServerEvent("LENT-PizzaJob:Server:ReturnVehicle", JobsDone)
        JobsDone = 0
    else
        Notify('client', "You haven't done any work yet!", 'error')
    end
end)


RegisterNetEvent('LENT-PizzaJob:Client:RemoveZoneSync', function(PlayerCitizenId)
    exports['qb-target']:RemoveZone(PlayerCitizenId)
end)

RegisterNetEvent('LENT-PizzaJob:Client:CanReturn', function()
    returnVehicle = true
end)

RegisterNetEvent('LENT-PizzaJob:Client:ClearAll', function()
    CurrentlyOnJob = false
    DoorCoords = vector3(0, 0, 0)
    returnVehicle = false
    RemoveBlip(DeliveryBlip)
end)

RegisterNetEvent('LENT-PizzaJob:Client:ClearVehcile', function()
    if DoesEntityExist(PizzaVehicle) then
        NetworkRequestControlOfEntity(PizzaVehicle)
        Wait(500)
        DeleteEntity(PizzaVehicle)
        PizzaVehicle = nil
    end
end)

RegisterNetEvent('LENT-PizzaJob:Client:DrawWaypoint', function(coords)
    DeliveryBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(DeliveryBlip, 8)
    SetBlipScale(DeliveryBlip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName('Deliver Pizza')
    EndTextCommandSetBlipName(DeliveryBlip)
    SetBlipColour(DeliveryBlip, 5)
    SetBlipRoute(DeliveryBlip, true)
    SetBlipRouteColour(DeliveryBlip, 5)
end)

RegisterNetEvent('LENT-PizzaJob:Client:SendPhone', function(event, Sender, Subject, Message)
    if event == 'email' then
        SendPhoneEmail(Sender, Subject, Message)
    end
end)

-- [[ Functions ]] --
function SendPhoneEmail(Sender, Subject, Message)
    local C = Config.QBCoreSettings['Phone']
    if C == 'qb' then
        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = Sender,
            subject = Subject,
            message = Message,
        })
    elseif C == 'gks' then
        local MailData = {
            sender = Sender,
            image = '/html/static/img/icons/mail.png',
            subject = Subject,
            message = Message
          }
          exports["gksphone"]:SendNewMail(MailData)
    elseif C == 'qs' then
        TriggerServerEvent('qs-smartphone:server:sendNewMail', {
            sender = Sender,
            subject = Subject,
            message = Message,
        })
    elseif C == 'npwd' then
        exports["npwd"]:createNotification({
            notisId = "LENT:EMAIL",
            appId = "EMAIL",
            content = Message,
            secondaryTitle = Sender,
            keepOpen = false,
            duration = 5000,
            path = "/email",
        })
    end
end


-- [[ Threads ]] --
CreateThread(function()
    local JobBlip = AddBlipForCoord(Config.ResourceSettings['JobData']['Blip']['Coords'].x, Config.ResourceSettings['JobData']['Blip']['Coords'].y, Config.ResourceSettings['JobData']['Blip']['Coords'].z)
    SetBlipSprite(JobBlip, Config.ResourceSettings['JobData']['Blip']['ID'])
    SetBlipColour(JobBlip, Config.ResourceSettings['JobData']['Blip']['Color'])
    SetBlipScale(JobBlip, Config.ResourceSettings['JobData']['Blip']['Scale'])
    SetBlipAsShortRange(JobBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.ResourceSettings['JobData']['Blip']['Text'])
    EndTextCommandSetBlipName(JobBlip)

    QBCore.Functions.LoadModel(Config.ResourceSettings['JobData']['Ped']['Model'])
    local PizzaThisPed = CreatePed(0, Config.ResourceSettings['JobData']['Ped']['Model'], Config.ResourceSettings['JobData']['Ped']['Coords'].x, Config.ResourceSettings['JobData']['Ped']['Coords'].y, Config.ResourceSettings['JobData']['Ped']['Coords'].z - 1, Config.ResourceSettings['JobData']['Ped']['Coords'].w, false, false)
    TaskStartScenarioInPlace(PizzaThisPed, 'WORLD_HUMAN_CLIPBOARD', true)
    FreezeEntityPosition(PizzaThisPed, true)
    SetEntityInvincible(PizzaThisPed, true)
    SetBlockingOfNonTemporaryEvents(PizzaThisPed, true)

    exports['qb-target']:AddTargetEntity(PizzaThisPed, {
        options = {
            { -- Create Group & Such
                icon = 'fas fa-circle',
                label = 'Request Job',
                canInteract = function()
                    return not CurrentlyOnJob
                end,
                action = function()
                    TriggerServerEvent('LENT-PizzaJob:Server:StartJob')
                end,
            },
            { -- Cancel the current job
                icon = 'fas fa-circle',
                label = 'Cancel Job',
                canInteract = function()
                    return CurrentlyOnJob
                end,
                action = function()
                    TriggerServerEvent('LENT-PizzaJob:Server:CancelJob')
                    TriggerEvent('LENT-PizzaJob:Client:GetPaySlip')
                end,
            },
            { -- Returning the vehicle
                icon = 'fas fa-circle',
                label = 'Return Vehicle',
                canInteract = function()
                    return returnVehicle
                end,
                action = function()
                    TriggerEvent('LENT-PizzaJob:Client:GetPaySlip')
                end,
            }
        },

        distance = 2.0
    })
end)

-- [[ Other ]] --
