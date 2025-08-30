local Translations = {
    error = {
        ["citizenid_error"]     = "[ERROR] Misslyckades att hämta spelar citizenid!",
        ["mis_id"]              = "[Error] Ett spelar ID är nödvändigt.",
        ["mis_amount"]          = "[Error] Det finns inget antal fordon den här spelaren kan parkera.",
        ["not_enough_money"]    = "Je hebt niet genoeg geld om de rekening te betalen!",
    },
    commands = {
        ["addvip"]              = "Lägg till", 
        ["removevip"]           = "Ta bort", 
    },
    system = {
        ['update']              = "There is a update for qb-parking", 
        ['enable']              = "Parkerings system %{type} är nu aktiverat",
        ["disable"]             = "Parkerings system %{type} är nu avaktiverat",
        ["freeforall"]          = "Parkerings system: är nu tillgänglig för alla spelare.",
        ["parkvip"]             = "Parkerings system: är nu tillgängliga för VIP.",
        ["no_permission"]       = "Parkerings system: Du har inte behörighet att parkera.",
        ["offline"]             = "Parkerings system är offline",
        ["update_needed"]       = "Parkerings system är gammalt",
        ["already_vip"]         = "Spelaren är redan VIP!",
        ["vip_not_found"]       = "Spelare hittades inte!",
        ["vip_add"]             = "Spelare %{username} är nu tillagd som VIP!",
        ["vip_remove"]          = "Spelare %{username} är nu borttagen som VIP!",
        ["max_allow_reached"]   = "Max antal fordon parkerade för dig är %{max}",
        ["park_or_drive"]       = "Parkera eller Kör",
        ["already_reserved"]    = "Den här parkeringen är reserverad.",
        ["parked_blip_info"]    = "Parked: %{modelname}",
        ["to_far_from_vehicle"] = "You are to far from the vehicle",
        ["open_create_menu"]    = "Open park create menu (Admin only)",
        ["must_be_onduty"]      = "You must be onduty to use this.",
        ["not_the_right_job"]   = "You dont have the right job to do this.",
    },
    success = {
        ["parked"]              = "Ditt fordon är parkerad",
        ["route_has_been_set"]  = "Er is een waypoint op de map geplaatst waar jou voertuig is gepakeerd.",
        ["paid_park_space"]     = "Je hebt %{paid} betaald.",
        ["get_vehicle_keys"]    = "You got the contact key from vehicle with the %{plate}",
    },
    info = {
        ["companyName"]         = "Beunhaas BV",
        ["owner"]               = "Ägare: ~y~%{owner}~s~",
        ["plate"]               = "Registreringsnummer: ~g~%{plate}~s~",
        ["model"]               = "~b~%{model}~s~",
        ["press_drive_car"]     = "Tryck F5 för att börja köra",
        ["car_already_parked"]  = "Ett fordon med samma registreringsnummer har redan blivit parkerad",
        ["car_not_found"]       = "Inga fordon hittades",
        ["maximum_cars"]        = "Det kan MAX vara %{amount} bilar parkerad ute på gatan och gränsen är nådd!",
        ["must_own_car"]        = "Du måste äga bilen för att kunna parkera den.",
        ["has_take_the_car"]    = "Ditt fordon har blivit borttagen från parkerings området.",
        ["only_cars_allowd"]    = "Du kan endast parkera bilar här.",
        ["stop_car"]            = "Stanna fordonet innan du kan parkera",
        ["police_info"]         = "~r~Polis~s~ Fordons Info\n",
        ["citizen_info"]        = "~g~Medborgare~s~ Fordons Info\n",
        ["paid_park_space"]     = "You rent this parking space for $%{paid} p/h",
        ["drive"]               = "Drive Vecihle",
        ["park"]                = "Park Vehicle",
        ["limit_for_player"]    = "Je kunt maximaal %{amount} voertuig(en) op straat parkeren!",
        ["not_allowed_to_park"] = "Je kunt hier geen voertuig parkeren!",
    },
    mail = {
        ["sender"]              = "%{company}",
        ["subject"]             = "Parkerade %{model}",
        ["message"]             = "Hej, %{username}<br /><br />Tack för att du litar på vårt parkerings område!<br /><br />För att du inte ska glömma vart du parkerade bilen.<br />Så kommer du få en påminnelse på din e-mail med registreringsnummer och område du parkerade din bil<br /><br />Ägare: %{username}<br />Model: %{model}<br />Reg NR: %{plate}<br />Område:%{street}<br /><br/><br/>%{company}",
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
