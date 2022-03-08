local Translations = {
    error = {
        ["citizenid_error"]     = "[ERROR] Failed to get player citizenid!",
        ["mis_id"]              = "[Error] Er is een speler id nodig.",
        ["mis_amount"]          = "[Error] Er is geen aantal voertuigen dat deze speler kan parkeren ingevored.",
        ["not_enough_money"]    = "Je hebt niet genoeg geld om de rekening te betalen!",
    },
    commands = {
        ["addvip"]              = "Add", 
        ["removevip"]           = "Remove", 
    },
    system = {
        ['update']              = "There is a update for qb-parking", 
        ['enable']              = "Park systeen %{type} is nu enable",
        ["disable"]             = "Park systeem %{type} is nu disable",
        ["freeforall"]          = "Park systeem: ingeschakelt voor iedereen.",
        ["parkvip"]             = "Park systeem: ingeschakelt alleen voor VIP.",
        ["no_permission"]       = "Park systeem: Je hebt geen rechten om te mogen parkeren.",
        ["offline"]             = "Park Systeem is offline",
        ["update_needed"]       = "Park Systeem is verouderd....",
        ["already_vip"]         = "Player is al een vip!",
        ["vip_not_found"]       = "Player niet gevonden!",
        ["vip_add"]             = "Player %{username} is toegevoegd als vip!",
        ["vip_remove"]          = "Player %{username} is toegevoegd als vip!",
        ["max_allow_reached"]   = "Het maximale aantal bepakte voertuigen voor jouw is %{max}",
        ["park_or_drive"]       = "Park or Drive",
        ["already_reserved"]    = "Deze parkeerplaats is al gereserveerd.",
        ["parked_blip_info"]    = "Parked: %{modelname}",
        ["to_far_from_vehicle"] = "You are to far from the vehicle",
        ["open_create_menu"]    = "Open park create menu (Admin only)",
        ["must_be_onduty"]      = "You must be onduty to use this.",
        ["not_the_right_job"]   = "You dont have the right job to do this.",
        ['no_money']            = "You have no money to pay the bill",
    }, 
    success = {
        ["parked"]              = "Je voertuig is gepakeerd",
        ["route_has_been_set"]  = "Er is een waypoint op de map geplaatst waar jou voertuig is gepakeerd.",
        ["paid_park_space"]     = "Je hebt %{paid} betaald.",
    },
    info = {
        ["companyName"]         = "Beunhaas BV",
        ["owner"]               = "Eigenaar: ~y~%{owner}~s~",
        ["plate"]               = "Kenteken: ~g~%{plate}~s~",
        ["model"]               = "~b~%{model}~s~",
        ["press_drive_car"]     = "Druk op F5 om te gaan rijden",
        ["car_already_parked"]  = "Deze parkeerplaats heeft al een auto met dezelfde plaat gestald",
        ["car_not_found"]       = "Geen voertuig gevonden",
        ["maximum_cars"]        = "Er kunnen maximaal %{amount} auto's gepakeerd worden, en de limiet is bereikt!",
        ["must_own_car"]        = "Je moet de auto bezitten om hem te kunnen parkeren.",
        ["has_take_the_car"]    = "Jou voertuig is uit de pakeer zone gehaalt",
        ["only_cars_allowd"]    = "Je kunt hier alleen auto's parkeren",
        ["stop_car"]            = "Stop het voertuig voor dat je het wilt parkeren...",
        ["police_info"]         = "~r~Politie~s~ Voertuig Info\n",
        ["citizen_info"]        = "~g~Citizen~s~ Voertuig Info\n",
        ["paid_park_space"]     = "Je huurt deze parkeer plek voor %{paid} p/h",  
        ["drive"]               = "Rijden",
        ["park"]                = "Parkeren",
        ["not_allowed_to_park"] = "Je kunt hier geen voertuig parkeren!",
        ["limit_for_player"]    = "Je kunt maximaal %{amount} voertuig(en) op straat parkeren!",
    },
    mail = {
        ["sender"]              = "%{company}",
        ["subject"]             = "Gepakeerd %{model}",
        ["message"]             = "Hey, %{username}<br /><br />Bedankt voor het vertrouwen in onze parkeerplaats!<br /><br />Om u het niet te laten vergeten waar jij jou auto gepakeerd hebt.<br />Krijgt je hierbij ook een herinderings e-mail met kenteken en de locatie waar je jou auto ongeveer gepakeerd hebt<br /><br />Eigennaar: %{username}<br />Model: %{model}<br />Kenteken: %{plate}<br />Locatie:%{street}<br /><br/><br/>%{company}",
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
