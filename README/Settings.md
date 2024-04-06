# Script Settings

```lua
Config.LENTSettings = {
    ['Debug'] = false,
}
```
*This will create debug zones around the doors of which the player is required to deliver the pizza, This should remain false if you're using it on a live server and is mainly used for development purposes!*

```lua
Config.QBCoreSettings = {
    ['Fuel'] = 'cdn-fuel',
    ['Renewed-Banking'] = true, -- If Bank is true it will generate transactions
}
```
- *Notify, is the resource that you're using for the notifications send to the player, The function responsible for sending notifications can be found at the bottom of the [Shared/sh_config.lua](../shared/sh_config.lua)*
- *Phone, Sending messages to the player from the pizza this business account, Emails, Messages & other notifications that will bring more immersion to the roleplay of the player.*
- *Fuel, The name of the resource you use for the fuel.. The export will still need to be called `SetFuel` otherwise this might not work!*
- *Renewed-Banking, If this is set to true you will be able to see transactions in your bank account from the Pizza This account!*
    - *This requires it to be a job in the `QBCore.Shared.Jobs` list and added to the SQL*

```lua
Config.ResourceSettings = {
    ['ProggressTime'] = math.random(2500, 5000),
}
```
*The amount it may take for the pizza to be delivered when knocking on the door*

```lua
Config.ResourceSettings = {
    ['Job'] = {
        ['Required'] = true,
        ['JobName'] = 'pizzaboy',
    },
}
```
- *Required, If this is set to true the ['JobName'] must be a valid job in the `QBCore.Shared.Jobs` list*
- *JobName, If ['Required'] is true then this must be a valid job from your `QBCore.Shared.Jobs` list*

```lua
Config.ResourceSettings = {
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
}
```
- *Ped, The general placement and model of the ped standing out of the Pizza This place for players to interact with to start, stop & return the job vehicle*
- *Blip, The data of the blip which includes which icon, the size, the color and what it will display on the main map*
- *Vehicle, The model & customization of a vehicle along where it will be placed when the job is started*
    - *Model, If you are using the optionally listed dependency for the Admiral pack you can use `admiral3taxi` as a model and turn `['Customize']` to false!*

```lua
Config.ResourceSettings = {
    ['DeliveryData'] = {
        [1] = {
            Coords = {
                ...
            },
            Payment = math.random(200, 500),
        },
    },
}
```
- *Coords, the list of Vector4 Coordinates where the player has to dilver the pizza to*
- *Payment, A random number or static number that will be multiplied to a max of 10 when the player has done more then 20 jobs*

```lua
Config.ResourceSettings = {
    ['Payment'] = {
        ['Type'] = 'bank',
        ['Tips'] = true,
        ['TipsAmount'] = math.random(10, 25),
        ['TipsChance'] = 30,
    },
}
```
- *Type, Should either be `cash` or `bank`. If `['Renewed-Banking']` is true it is preffered if you use `bank` to generate transactions coming from `Pizza This` for Law Enforcement to see!*
- *Tips, If the player is allowed to make tips in cash from delivering the pizza's, Should probably remain true if the job payout itself is low*
- *TipsAmount, Additional way for the player to make money, This will **NOT** be multiplied by the amount of jobs, Rather by just delivering*
- *TipsChance, The amount in % that the player has for receiving a tip!*
    - *Default = 30 which gives the player a 70% of receicing a tip!*