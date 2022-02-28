## ---------------------------------------------Updates------------------------------------------------
## Update 39 👊😉👍 27-2-2022
- Added Parking Polyzones.
- You can still use the park anywhere you want, but,
- to make it more high performance, you can now also use polyzone.
- police but only onduty, wil be iqnored and can park anywere, even on other players parking spots or not parking spots free of paid.


## Add This to your database
```sql
ALTER TABLE `player_parking` ADD COLUMN `oil` INT(15) NOT NULL DEFAULT '100' AFTER `fuel`;
```


## Polyzone NOTE
- Vehicles only showup when you inside a park zone, the same for the park markers and names.
- You can sill add park spaces that are paid or free or just no park space at all.
- to create a parking spot fist use the command [/park-build] to enable the build mode, so you can lineup the markers.
- Then you typ [/park-create] to open the NUI menu, and create your parking spot.
- All parking locations are saved in de folder [configs] you can also find the polyzones.lua file if you want to make any changes. 


## All Commands
- [/park]              -- 👉 User/Admin
- [/park-names]        -- 👉 User/Admin
- [/park-lotnames]     -- 👉 User/Admin
- [/park-notification] -- 👉 User/Admin
- [/park-system]       -- 👉 Admin
- [/park-usevip]       -- 👉 Admin
- [/park-addvip]       -- 👉 Admin
- [/park-removevip]    -- 👉 Admin
- [/park-create]       -- 👉 Admin
- [/park-build]        -- 👉 Admin

## 🙈 My Youtube & My Discord 👊😉👍
- [Youtube](https://www.youtube.com/channel/UC6431XeIqHjswry5OYtim0A)
- [Discord](https://discord.gg/cEMSeE9dgS)


## ---------------------------------------------Updates------------------------------------------------
## Huge Update 38 👊😉👍 25-2-2022
- Added a NUI to create new parking lots.
- Added Markers for reserved park positions.
- Added Park Blips on the map.
- Added Target Eye, you can now unpark your vehicle even if you are outsite of the vehicle.
- No Vip system anymore, casue you can now add parking stopt for players where thay want.
- You can still use the Anyware you can park if you change this [Config.UseOnlyPreCreatedParkingSpots] to [false] in the config.lua

**NOTE**
- All parking locations wil be addedd in the configs directory, so if you want to edit it, go to configs directory
- If you want to remove a location you have to remove it from one of the lua files where you add it.
- The parkname must not be a duplicate, it must have a unique name.
- The Park Displayname is the name that you see in game. this does not have to be a unique name.

## Best way to use the create a parking lot
- Park your vehicle facing the nose inside the parking lot. (to correctly place a marker)
- Type /park-create or use F6 if you use the keybinds.
- if you're standing correctly, your marker will be in front of you after you press submit button. 
- The parking spot is where you're standing at that moment when you hit submit button.
- Park your vehicle correct before opening the menu and create the spot.

## New Admin Commands
- 👉 /park-build    (admin only) (Build Mode)
- 👉 /park-create   (admin only) (Create Menu)

## Example of a parkong place
```lua
Config.ReservedParkList["Blokkenpark"] = {                     -- must be a unique name
    ["name"]       = "Blokkenpark",                            -- the name of the parking place (must be a unique name)
    ["display"]    = "Garage Spawnpoint",                      -- the marker display label
    ["citizenid"]  = "0",                                      -- if 0 this had no owner and can not be use as a parking space
    ["cost"]       = 0,                                        -- cost per day, not in used yet
    ["job"]        = "none",                                   -- the job that is allowed to park
    ["radius"]     = 2.0,                                      -- the radius of this parking space
    ["parktype"]   = "prived",                                 -- is a prived parking space
    ["marker"]     = true,                                     -- if true a marker wil showup when you walk to it
    ["coords"]     = vec3(220.021973, -809.142883, 30.324585), -- the center of the parking place where the car is parked.
    ["markcoords"] = vec3(217.716370, -808.193604, 30.398928), -- the marker coord.
}
```
## NOTE 0 as citizenid id
If you are creating a parking space and you add 0 as citizenid and prived on true, 
than this will be a location where players can't park there vehicle.
you can use this to avoid parking on spawnpoints.

## Jobs and Houses 
You can give players if they are a police or ambulance or mechanic, you can give this players there own parking place at work.
you can also create parking spaces by players at there houses, but you can also use the anywhere you can park,
but pleyers are not able to park on pre-created parking lots.

so if you put a citizenid when you create a parking space, than only this player can park. 

## 😎 Special thanks for helping me with testing 👊😉👍
- 💪 GUS
- 💪 Jazerra
- 💪 ameN
- 💪 MulGirtab
- 💪 DannyJ
- 💪 MasonJason310
- 💪 Enxsistanz
- 💪 !ExiledVibe!
- 💪 FARRUKO

## 🙈 My Youtube & My Discord 👊😉👍
- [Youtube](https://www.youtube.com/channel/UC6431XeIqHjswry5OYtim0A)
- [Discord](https://discord.gg/cEMSeE9dgS)
