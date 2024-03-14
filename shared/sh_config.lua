-- [[ QBCore ]] --
local QBCore = exports['qb-core']:GetCoreObject()

-- [[ Config ]] --
Config = Config or {}

Config.LENTSettings = {
    ['Debug'] = false,
}

Config.QBCoreSettings = {
    ['Notify'] = 'qb', -- qb, ps, custom
    ['Phone'] = 'qb', -- qb, gks, qs, npwd
    ['Fuel'] = 'cdn-fuel',
    ['Renewed-Banking'] = true, -- If Bank is true it will generate transactions
}

Config.ResourceSettings = {
    ['ProggressTime'] = math.random(2500, 5000),
    ['Job'] = {
        ['Required'] = true,
        ['JobName'] = 'pizzaboy',
    },
    ['JobData'] = {
        ['Ped'] = {
            ['Coords'] = vector4(537.6, 101.22, 96.53, 134.39),
            ['Model'] = 'csb_vagspeak'
        },
        ['Blip'] = {
            ['Coords'] = vector4(537.6, 101.22, 96.53, 134.39),
            ['ID'] = 514,
            ['Color'] = 11,
            ['Scale'] = 0.8,
            ['Text'] = "Pizza This..."
        },
        ['Vehicle'] = {
            ['Model'] = 'futo2',
            ['Customize'] = true, -- Set to TRUE if you are using model = 'futo2'
            ['Coords'] = vector4(530.24, 96.21, 96.28, 118.52),
        },
    },
    ['DeliveryData'] = {
        [1] = { -- [[ Vinewood ]] --
            Coords = {
                vector4(173.0, -25.89, 68.35, 348.12),
                vector4(-165.69, 75.58, 71.09, 172.06),
                vector4(-150.01, 123.93, 69.91, 329.69),
                vector4(-159.71, 129.41, 70.23, 330.86),
            },
            Payment = math.random(500, 750)
        },
        [2] = {
            Coords = { -- [[ Davis ]] --
                vector4(101.07, -1912.27, 21.41, 339.03),
                vector4(72.25, -1939.14, 21.37, 136.83),
                vector4(76.94, -1949.32, 21.17, 138.81),
                vector4(38.94, -1911.57, 21.95, 52.51),
                vector4(54.42, -1873.06, 22.81, 318.82),
                vector4(23.11, -1896.9, 22.97, 139.47),
                vector4(45.72, -1863.96, 23.28, 324.37),
                vector4(-4.84, -1872.3, 24.15, 241.43),
            },
            Payment = math.random(200, 500),
        },
    },
    ['Payment'] = {
        ['Type'] = 'bank',
        ['Tips'] = true,
        ['TipsAmount'] = math.random(10, 25),
        ['TipsChance'] = 30,
    },
}

function Notify(clsv, text, type, time)
    -- What does clsv stand for?
    -- Client / Server | Why sv..? I don't know sounds better
    -- Don't bully me... I try my best okay!
    local time = time or 2500
    if clsv == 'client' or clsv == 'cl' then
        if Config.QBCoreSettings['Notify'] == 'qb' then
            QBCore.functions.Notify(text, type, time)
        elseif Config.QBCoreSettings['Notify'] == 'ps' then
            exports['ps-ui']:Notify(text, type, time)
        elseif Config.QBCoreSettings['Notify'] == 'custom' then
            -- Create Custom Notify
        end
    elseif clsv == 'server' or clsv == 'sv' then
        local src = source
        TriggerClientEvent('LENT-PizzaBoy:Client:SendNotify', src, text, type, time)
    else
        print('Invalid CLSV Argument passed!')
    end
end