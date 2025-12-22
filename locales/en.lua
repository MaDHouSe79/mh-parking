local Translations = {
    info = {
        not_the_owner = "You are not the owner of this vehicle...",
        not_a_vip = "You are not a VIP member..",
        wheel_clamp = "Wheel clamp",
        wheel_clamp_add = "Place Wheel clamp",
        no_cops = "No Cops..",
        wheel_clamp_added = "Vehicle clamped! Fine: $%{fine}",
        wheel_clamp_deleted = "Wheel clamp removed!",
        click_to_set_waypoint = "Click to set waypoint",
        no_waipoint = "Seriously do you need a waypoint for this %{distance} meters?",
        no_money = "You don't have enough money in your pocket, you need %{money} for the fees.",
        paid_parking = "You have paid %{money} for the parking fees.",
        vehicle_has_wheelclamp = "You can't unpart, you have a wheel clamp...",
        vehicle_impounded = "Vehicle %{plate} is impounded.",
        no_cop = "You are not a police...",
        impound = "Impound",
        wait_one_moment = "Please wait, try again in about 3 seconds.",
        addvip = "Add player as vip",
        removevip = "Remove player as vip",
        addasvip = "You are added as vip member",
        payerissvip = "Player is added as vip member",
        removeasvip = "Player is removed as vip member",
    },
    
    vehicle = {
        info = "Vehicle Information",
        body_damage = "Body Damage",
        engine_damage = "Engine Health",
        fuel_level = "Fuel Level",
        oil_level = "Oil Level",
        engine_temp = "Engine Temp",
        parked = "Vehicle parked automatically!",
        unparked = "Vehicle automatically unparked!",
        getkeys = "You have the key for vehicle %{vehicle} and plate %{plate}!",
    },

    blip = {
        label = "Parked:%{model} Plate: %{plate}",
    },
    
    nui = {
        hour = "%{hour} Hour",
        options = "Options",
        model = "Model: %{model}",
        class = "Class: %{class}",
        plate = "Plate: %{plate}",
        street = "Street: %{street}",
        fuel = "Fuel: %{fuel}%",
        engine = "Engine: %{engine}",
        body = "Body: %{body}",
        oil = "Oil: %{oil}%",
        addclamp = "Add Clamp",
        removeclamp = "Remove Clamp",
        impound = "Impound",
        parkinfo = "Max park time: %{parktime} | Current park time: %{overtime}",
        setwaypoint = "Set Waypoint",
        givekeys = "Give keys",
        park = "Park",
        unpark = "Unpark",
        pay_to_unclamp = "Pay to unclamp",
    },
}

if (GetConvar('mh_locale', 'en') == 'en') then
    Lang = Locale:new({phrases = Translations, warnOnMissing = true, fallbackLang = Lang})
end