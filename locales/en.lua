local Translations = {
    info = {
        not_the_owner = "You are not the owner of this vehicle...",
        not_a_vip = "You are not a VIP member..",
        wheel_clamp = "Wheel clamp",
        wheel_clamp_add = "Place Wheel clamp",
        no_cops = "No Cops..",
        wheel_clamp_added = "Vehicle clamped! Fine: $%{fine}",
        wheel_clamp_deleted = "Wheel clamp removed!",
        street = "Street: %{street}",
        fuel = "Brandstof: %{fuel}",
        engine = "Motor: %{engine}",
        body = "Body: %{body}",
        click_to_set_waypoint = "Click to set waypoint",
        no_waipoint = "Seriously do you need a waypoint for this %{distance} meters?",
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
    },

    blip = {
        label = "Parked:%{model} Plate: %{plate}",
    }
}

if GetConvar('mh_locale', 'en') == 'en' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })

end
