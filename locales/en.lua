local Translations = {
    error = {
        ["citizenid_error"]     = "[ERROR] Failed to get player citizenid!",
        ["mis_id"]              = "[Error] A player ID is required.",
        ["mis_amount"]          = "[Error] There is no number of vehicles that this player can park.",
    },
    commands = {
        ["addvip"]              = "Add", 
        ["removevip"]           = "Remove", 
    },
    system = {
        ['enable']              = "Park systen %{type} is now enable",
        ["disable"]             = "Park system %{type} is now disable",
        ["freeforall"]          = "Park system: is now enabled for all players.",
        ["parkvip"]             = "Park system: is now only enabled for VIP.",
        ["no_permission"]       = "Park system: You do not have permission to park.",
        ["offline"]             = "Park System is offline",
        ["update_needed"]       = "Park System is outdated....",
        ["already_vip"]         = "Player is already a vip!",
        ["vip_not_found"]       = "Player not found!",
        ["vip_add"]             = "Player %{username} is added as vip!",
        ["vip_remove"]          = "Player %{username} is removed as vip!",
        ["max_allow_reached"]   = "The maximum number of packed vehicles for you is %{max}",
        ["park_or_drive"]       = "Park or Drive",
    },
    success = {
        ["parked"]              = "Your car is packed",
        ["route_has_been_set"]  = "Er is een waypoint op de map geplaatst waar jou voertuig is gepakeerd.",
    },
    info = {
        ["companyName"]         = "Beunhaas BV",
        ["owner"]               = "Owner: ~y~%{owner}~s~",
        ["plate"]               = "Plate: ~g~%{plate}~s~",
        ["model"]               = "~b~%{model}~s~",
        ["press_drive_car"]     = "Press F5 to start driving",
        ["car_already_parked"]  = "A vehicle with the same plate has already parked",
        ["car_not_found"]       = "No vehicle found",
        ["maximum_cars"]        = "There can be a maximum of ~r~%{value}~s~ cars can be parked outside on the street, and the limit has been reached, you must park this vehicle in the parking garage!",
        ["must_own_car"]        = "You must own the car to park it.",
        ["has_take_the_car"]    = "Your vehicle has been removed from the parking zone",
        ["only_cars_allowd"]    = "You can only park cars here",
        ["stop_car"]            = "Stop your vehicle before you park",
        ["police_info"]         = "~r~Police~s~ Vehicle Info\n",
        ["citizen_info"]        = "~g~Citizen~s~ Vehicle Info\n",
    },
    mail = {
        ["sender"]              = "%{company}",
        ["subject"]             = "Parked %{model}",
        ["message"]             = "Hey, %{username}<br /><br />Thank you for trusting our parking lot!<br /><br />To make sure you don't forget where you parked your car.<br />Will you also receive a reminder e-mail with license plate and the location where you parked your car approximately<br /><br />Owner: %{username}<br />Model: %{model}<br />Plate: %{plate}<br />Location:%{street}<br /><br/><br/>%{company}",
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
