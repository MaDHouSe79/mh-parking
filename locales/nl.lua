local Translations = {
    error = {
        ["citizenid_error"]     = "[ERROR] Failed to get player citizenid!",
    },
    system = {
        ['enable']              = "Park systeen %{type} is nu enable",
        ["disable"]             = "Park systeem %{type} is nu disable",
        ["freeforall"]          = "Park systeem: ingeschakelt voor iedereen.",
        ["parkvip"]             = "Park systeem: ingeschakelt alleen voor VIP.",
        ["no_permission"]       = "Park systeem: Je hebt geen rechten om te mogen parkeren.",
        ["offline"]             = "Park Systeen is offline",
        ["update_needed"]       = "Park System is verouderd....",
    },
    success = {
        ["parked"]              = "Je auto is gepakeerd",
        ["route_has_been_set"]  = "Er is een waypoint op de map geplaatst waar jou voertuig is gepakeerd.",
    },
    info = {
        ["companyName"]         = "Beunhaas BV",
        ["owner"]               = "Eigenaar: ~y~%{owner}~s~",
        ["plate"]               = "Kenteken: ~g~%{plate}~s~",
        ["model"]               = "~b~%{model}~s~",
        ["press_drive_car"]     = "Druk op F5 om te gaan rijden",
        ["car_already_parked"]  = "Deze parkeerplaats heeft al een auto met dezelfde plaat gestald",
        ["car_not_found"]       = "Geen voertuig gevonden",
        ["maximum_cars"]        = "Er kunnen maximaal ~r~%{value}~s~ auto's buiten op straat gepakeerd worden, en de limiet is bereikt, u moet dit voertuig in de pakeer garage parkeren!",
        ["must_own_car"]        = "Je moet de auto bezitten om hem te kunnen parkeren.",
        ["has_take_the_car"]    = "Jou voertuig is uit de pakeer zone gehaalt",
        ["only_cars_allowd"]    = "Je kunt hier alleen auto's parkeren",
        ["stop_car"]            = "Stop het voertuig voor dat je het wilt parkeren...",
    },
    mail = {
        ["sender"]              = "%{company}",
        ["subject"]             = "Gepakeerd %{model}",
        ["message"]             = "Hey, %{username}<br /><br />Bedankt voor het vertrouwen in onze parkeerplaats!<br /><br />Om u het niet te laten vergeten waar jij jou auto gepakeerd hebt.<br />Krijgt je hierbij ook een herinderings e-mail met kenteken en de locatie waar je jou auto ongeveer gepakeerd hebt<br /><br />Eigennaar: %{username}<br />Model: %{model}<br />Kenteken: %{plate}<br />Locatie:%{street}<br /><br/><br/>%{company}",
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
