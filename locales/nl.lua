-- [[ ===================================================== ]] --
-- [[               MH Parking V2 by MaDHouSe79             ]] --
-- [[ ===================================================== ]] --
local Translations = {
    info = {
        ['not_the_owner'] = "Je bent niet de eigenaar van dit voertuig...",
        ['remove_vehicle_zone'] = "Voertuig verwijderd uit de parkeerzone",
        ['limit_parking'] = "U heeft de parkeerlimiet bereikt. Limiet(%{limit})",
        ['vehicle_parked'] = "Voertuig staat geparkeerd",
        ['already_parked'] = "Voertuig staat al geparkeerd",
        ['parked_blip'] = "Geparkeerd: %{model}",
        ['no_vehicle_nearby'] = "Geen voertuig in de buurt",
        ['no_waipoint'] = "Serieus heb je voor deze %{distance} meter een waypoint nodig?",
        ['no_vehicles_parked'] = "Je hebt geen voertuigen gepakeerd staan.",
        ['get_in_vehicle'] = "Get In Vehicle",
        ['select_vehicle'] = "Select Vehicle",
        ["owner"] = "Eigenaar: ~y~%{owner}~s~",
        ["plate"] = "Kenteken: ~g~%{plate}~s~",
        ["model"] = "Model: ~b~%{model}~s~",
        ["brand"] = "Brand: ~o~%{brand}~s~",
        ['playeraddasvip'] = "U bent toegevoegd als vip voor het parksysteemm",
        ['isaddedasvip'] = "Speler is toegevoegd als vip voor het parksysteem",
        ['playerremovedasvip'] = "Speler is verwijderd als vip voor het parksysteem",
        ['steet'] = "Steet: %{steet}",
        ['fuel'] = "Fuel: %{fuel}",
        ['engine'] = "Engine: %{engine}",
        ['body'] = "Body: %{body}",
        ['click_to_set_waypoint'] = "Klik voor waypoint",
        ['close'] = "Sluit",
        ['park_menu'] = "Parked Menu",
        ['press_to_attach'] = "Druk E om the boot op de trailer te plaatsen",
        ['unable_to_park'] = "Kan niet parkeren",
        ['parking_lot'] = "Parkeerplaats",
        ["press_drive_car"] = "Druk op %{key} om te rijden",
        ["stop_car"] = "Stop het voertuig voor dat je het wilt parkeren...",
        ["only_cars_allowd"]    = "Je kunt hier alleen auto's parkeren",
    },
    commands = {
        ['addvip'] = "Parking VIP Toevoegen",
        ['addvip_info'] = "De id can de player die je wilt toevoegen",
        ['addvip_info_amount'] = "Max park totaal",
        ['removevip'] = "Parking Vip Verwijderen",
        ['removevip_info'] = "De ID van de player dat je wilt verwijderen",
    },
    vehicle = {
        ['model'] = "Model: %{model}",
        ['brand'] = "Uitvoering: %{brand}",
        ['plate'] = "Kenteken: %{plate}",
        ['fuel']  = "Brandstof: %{fuel}%",
        ['engine'] = "Motor: %{engine}%",
        ['body']  = "Body: %{body}%",
    }
}

if GetConvar('qb_locale', 'en') == 'nl' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end