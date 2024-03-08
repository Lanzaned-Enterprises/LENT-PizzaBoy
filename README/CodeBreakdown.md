# Code Breakdown
*This files goes over the code within this script and breaks it down for players to easier understand*

## shared/sh_config.lua
```lua
function Notify(clsv, text, type, time)
    if clsv == 'client' or clsv == 'cl' then
        if Config.QBCoreSettings['Notify'] == 'qb' then
            QBCore.functions.Notify(text, type, time)
        elseif Config.QBCoreSettings['Notify'] == 'ps' then
            exports['ps-ui']:Notify(text, type, time)
        elseif Config.QBCoreSettings['Notify'] == 'custom' then
            print(text)
        end
    elseif clsv == 'server' or clsv == 'sv' then
        local src = source
        if Config.QBCoreSettings['Notify'] == 'qb' then
            TriggerClientEvent('QBCore:Notify', src, text, type, time)
        elseif Config.QBCoreSettings['Notify'] == 'ps' then
            TriggerClientEvent('ps-ui:Notify', src, text, type, time)
        elseif Config.QBCoreSettings['Notify'] == 'custom' then
            print(text)
        end
    else
        print('Invalid CLSV Argument passed!')
    end
end
```
*This function reads from the `['Config.QBCoreSettings']` `Notify` and create the notification according to the player*

## client/cl_main.lua
*SOON!*

## server/sv_main.lua
*SOON!*

## server/sv_github.lua
*SOON!*
