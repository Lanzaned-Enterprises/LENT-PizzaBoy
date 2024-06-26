--[[ Version Checker ]] --
local version = "200"

local DISCORD_WEBHOOK = ""
local DISCORD_NAME = "LENT - Pizza This"
local DISCORD_IMAGE = "https://cdn.discordapp.com/attachments/1026175982509506650/1026176123928842270/Lanzaned.png"

local RESOURCE_NAME = "LENT-PizzaBoy" -- DO NOT CHANCE THIS

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        CheckResourceVersion()
    end
end)

function CheckUpdateEmbed(color, name, message, footer)
    local content = {
        {
            ["color"] = color,
            ["title"] = " " .. name .. " ",
            ["description"] = message,
            ["footer"] = {
                ["text"] = " " .. footer .. " ",
            },
        }
    }
    PerformHttpRequest(DISCORD_WEBHOOK, function(err, text, headers) end,
    'POST', json.encode({
        username = DISCORD_NAME,
        embeds = content,
        avatar_url = DISCORD_IMAGE
    }), { ['Content-Type'] = 'application/json '})
end

function CheckResourceVersion()
    PerformHttpRequest("https://raw.githubusercontent.com/Lanzaned-Enterprises/"..RESOURCE_NAME.."/main/version.txt", function(err, text, headers)
        if (version > text) then -- Using Dev Branch
            print(" ")
            print("---------- LANZANED PIZZABOY ----------")
            print(""..RESOURCE_NAME.." is using a development branch! Please update to stable ASAP!")
            print("Your Version: " .. version .. " Current Stable Version: " .. text)
            print("https://github.com/Lanzaned-Enterprises/"..RESOURCE_NAME.."")
            print("---------------------------------------")
            print(" ")
            CheckUpdateEmbed(5242880, "LANZANED UPDATE CHECKER", ""..RESOURCE_NAME.." is using a development branch! Please update to stable ASAP!\nYour Version: " .. version .. " Current Stable Version: " .. text .. "\nhttps://github.com/Lanzaned-Enterprises/LENT-CargoHeist", "Script created by: https://discord.lanzaned.com")
        elseif (text < version) then -- Not updated
            print(" ")
            print("---------- LANZANED PIZZABOY ----------")
            print(""..RESOURCE_NAME.." is not up to date! Please update!")
            print("Curent Version: " .. version .. " Latest Version: " .. text)
            print("https://github.com/Lanzaned-Enterprises/"..RESOURCE_NAME.."")
            print("---------------------------------------")
            print(" ")
            CheckUpdateEmbed(5242880, "LANZANED UPDATE CHECKER", ""..RESOURCE_NAME.." is not up to date! Please update!\nCurent Version: " .. version .. " Latest Version: " .. text .. "\nhttps://github.com/Lanzaned-Enterprises/LENT-CargoHeist", "Script created by: https://discord.lanzaned.com")
        else -- resource is fine
            print(" ")
            print("---------- LANZANED PIZZABOY ----------")
            print(""..RESOURCE_NAME.." is up to date and ready to go!")
            print("Running on Version: " .. version)
            print("https://github.com/Lanzaned-Enterprises/"..RESOURCE_NAME.."")
            print("---------------------------------------")
            print(" ")
            CheckUpdateEmbed(20480, "LANZANED UPDATE CHECKER", ""..RESOURCE_NAME.." is up to date and ready to go!\nRunning on Version: " .. version .. "\nhttps://github.com/Lanzaned-Enterprises/LENT-CargoHeist", "Script created by: https://discord.lanzaned.com")
        end 
    end, "GET", "", {})
end