local Translations = {
    error = {
        ["citizenid_error"]     = "[ERROR] Kunne ikke finne spiller citizenid!",
        ["mis_id"]              = "[Error] En spiller ID er påkrevd.",
        ["mis_amount"]          = "[Error] There is no number of vehicles that this player can park.",
        ["not_enough_money"]    = "Je hebt niet genoeg geld om de rekening te betalen!",
    },
    commands = {
        ["addvip"]              = "Add", 
        ["removevip"]           = "Remove", 
    },
    system = {
        ['update']              = "There is a update for qb-parking", 
        ['enable']              = "Park system %{type} er nå aktivert",
        ["disable"]             = "Park system %{type} er nå deaktivert",
        ["freeforall"]          = "Park system: er aktivert for alle spillere.",
        ["parkvip"]             = "Park system: er nå aktivert kun for VIP.",
        ["no_permission"]       = "Park system: Du har ikke tillatelse til å parkere.",
        ["offline"]             = "Park System er offline",
        ["update_needed"]       = "Park System er utdatert....",
        ["already_vip"]         = "Spiller er allerede vip!",
        ["vip_not_found"]       = "Spiller ikke funnet!",
        ["vip_add"]             = "Spiller %{username} er lagt til som vip!",
        ["vip_remove"]          = "Spiller %{username} er fjernet som vip!",
        ["max_allow_reached"]   = "Du har parkert maks antall kjøretøy du kan parkere %{max}",
        ["park_or_drive"]       = "Park or Drive",
        ["already_reserved"]    = "This parking place has already been reserved.",
        ["parked_blip_info"]    = "Parked: %{modelname}",
        ["to_far_from_vehicle"] = "You are to far from the vehicle",
        ["open_create_menu"]    = "Open park create menu (Admin only)",
        ["must_be_onduty"]      = "You must be onduty to use this.",
        ["not_the_right_job"]   = "You dont have the right job to do this.",
    },
    success = {
        ["parked"]              = "Din bil er parkert",
        ["route_has_been_set"]  = "GPS er satt til lokasjon av bilen din.",
        ["paid_park_space"]     = "Je hebt %{paid} betaald.",
    },
    info = {
        ["companyName"]         = "EUROPARK",
        ["owner"]               = "Eier: ~y~%{owner}~s~",
        ["plate"]               = "Reg nr: ~g~%{plate}~s~",
        ["model"]               = "~b~%{model}~s~",
        ["press_drive_car"]     = "Trykk K for å kjøre",
        ["car_already_parked"]  = "Et kjøretøy med samme skilt nr er allerede parkert",
        ["car_not_found"]       = "Inget kjøretøy funnet",
        ["maximum_cars"]        = "Det kan være maks %{amount} biler parkert på gaten, og grensen er nå nådd!",
        ["must_own_car"]        = "Du må eie bilen for å parkere den.",
        ["has_take_the_car"]    = "Ditt kjøretøy er fjernet fra parkerings sonen",
        ["only_cars_allowd"]    = "Du kan bare parkere biler her",
        ["stop_car"]            = "Stopp kjøretøy før du parkerer",
        ["police_info"]         = "~r~Politi~s~ Kjøretøy Info\n",
        ["citizen_info"]        = "~g~Borger~s~ Kjøretøy Info\n",
        ["paid_park_space"]     = "You rent this parking space for $%{paid} p/h",
        ["drive"]               = "Drive Vecihle",
        ["park"]                = "Park Vehicle",
        ["limit_for_player"]    = "Je kunt maximaal %{amount} voertuig(en) op straat parkeren!",
        ["not_allowed_to_park"] = "Je kunt hier geen voertuig parkeren!",
    },
    mail = {
        ["sender"]              = "%{company}",
        ["subject"]             = "Parkert %{model}",
        ["message"]             = "Hei, %{username}<br /><br />Takk for at du valgte våre parkerings tjenester!<br /><br />For å hjelpe deg å huske hvor du har parkert bilen.<br />Vil du derfor motta en påminnelse om hvor du ca har parkert bilen din<br /><br />Eier: %{username}<br />Model: %{model}<br />Reg nr: %{plate}<br />Lokasjon:%{street}<br /><br/><br/>%{company}",
    },

    discoord = {
        ["version"]   = "[qb-parking] - Running Version %{version}",
        ["found"]     = "[qb-parking] - Found %{count}/%{total} vehicles that are parked.",
        ["spawntime"] = "[qb-parking] - Spawn time %{spawntime} milliseconds.",
        ["timeloop"]  = "[qb-parking] - Parking Time Check Loop has started.",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
