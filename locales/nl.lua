local Translations = {
    info = {
        not_the_owner = "Je bent niet de eigennaar van dit voertuig...",
        not_a_vip = "You are not a VIP member..",
        wheel_clamp = "Wielklem",
        wheel_clamp_add = "Wielklem plaatsen",
        no_cops = "Geen Politie..",
        wheel_clamp_added = "Voertuig geklemd! Boete: $%{fine}",
        wheel_clamp_deleted = "Wielklem verwijderd!",
        street = "Street: %{street}",
        fuel = "Brandstof: %{fuel}",
        engine = "Motor: %{engine}",
        body = "Body: %{body}",
        click_to_set_waypoint = "Click to set waypoint",
        no_waipoint = "Serieus heb je voor deze %{distance} meter een waypoint nodig?",
    },
    vehicle = {
        info = "Vehicle Information",
        body_damage = "Body Damage",
        engine_damage = "Engine Health",
        fuel_level = "Fuel Level",
        oil_level = "Oil Level",
        engine_temp = "Engine Temp",
        parked = "Voertuig automatisch geparkeerd!",
        unparked = "Voertuig automatisch ontparkeerd!",
        
    },
    blip = {
        label = "Parked:%{model} Plate: %{plate}",
    }
}

if GetConvar('qb_locale', 'en') == 'nl' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
