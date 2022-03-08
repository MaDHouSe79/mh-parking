local Translations = {
    error = {
        ["citizenid_error"]     = "[ERROR] Bürger-ID des Spielers konnte nicht abgerufen werden!",
        ["mis_id"]              = "[Error] Eine Spieler-ID ist erforderlich.",
        ["mis_amount"]          = "[Error] Es gibt keine Anzahl von Fahrzeugen, die dieser Spieler parken kann.",
        ["not_enough_money"]    = "Je hebt niet genoeg geld om de rekening te betalen!",
    },
    commands = {
        ["addvip"]              = "Hinzufügen",
        ["removevip"]           = "Entfernen",
    },
    system = {
        ['update']              = "There is a update for qb-parking", 
        ['enable']              = "Das Parksystem %{type} ist jetzt aktiviert",
        ["disable"]             = "Das Parksystem %{type} ist jetzt deaktiviert",
        ["freeforall"]          = "Parksystem: ist jetzt für alle Spieler aktiviert.",
        ["parkvip"]             = "Parksystem: ist jetzt nur für VIP aktiviert.",
        ["no_permission"]       = "Parksystem: Sie haben keine Parkberechtigung.",
        ["offline"]             = "Parksystem ist offline",
        ["update_needed"]       = "Parksystem ist veraltet....",
        ["already_vip"]         = "Spieler ist bereits ein VIP!",
        ["vip_not_found"]       = "Spieler nicht gefunden!",
        ["vip_add"]             = "Spieler %{username} wird als VIP hinzugefügt!",
        ["vip_remove"]          = "Player %{username} is removed as vip!",
        ["max_allow_reached"]   = "Die maximale Anzahl an gepackten Fahrzeugen für Sie beträgt %{max}",
        ["park_or_drive"]       = "Parken oder fahren",
        ["already_reserved"]    = "Dieser Parkplatz ist bereits reserviert.",
        ["parked_blip_info"]    = "Geparkt: %{modelname}",
        ["to_far_from_vehicle"] = "Sie sind zu weit vom Fahrzeug entfernt",
        ["open_create_menu"]    = "Parkerstellungsmenü öffnen (nur Admin)",
        ["must_be_onduty"]      = "Sie müssen verpflichtet sein, dies zu verwenden.",
        ["not_the_right_job"]   = "Du hast nicht den richtigen Job dafür.",
    },
    success = {
        ["parked"]              = "Ihr Auto ist gepackt",
        ["route_has_been_set"]  = "Es ist ein Wegpunkt auf der Karte, der auf der Karte angezeigt wird.",
        ["paid_park_space"]     = "Sie haben %{paid} bezahlt.",
    },
    info = {
        ["companyName"]         = "Beunhaas BV",
        ["owner"]               = "Inhaber: y%{owner}s",
        ["plate"]               = "Kennzeichen: g%{plate}s",
        ["model"]               = "b%{model}s",
        ["press_drive_car"]     = "Drücken Sie F5, um mit dem Fahren zu beginnen",
        ["car_already_parked"]  = "Ein Fahrzeug mit dem gleichen Kennzeichen hat bereits geparkt",
        ["car_not_found"]       = "Kein Fahrzeug gefunden",
        ["maximum_cars"]        = "Es können maximal r%{amount}s Autos draußen auf der Straße geparkt werden, und das Limit ist erreicht!",
        ["must_own_car"]        = "Sie müssen das Auto besitzen, um es zu parken.",
        ["has_take_the_car"]    = "Ihr Fahrzeug wurde aus der Parkzone entfernt",
        ["only_cars_allowd"]    = "Hier können Sie nur Autos parken",
        ["stop_car"]            = "Halten Sie Ihr Fahrzeug an, bevor Sie parken",
        ["police_info"]         = "rPolizeis Fahrzeuginfo\n",
        ["citizen_info"]        = "gBürgers Fahrzeuginfo\n",
        ["paid_park_space"]     = "You rent this parking space for $%{paid} p/h",
        ["drive"]               = "Drive Vecihle",
        ["park"]                = "Park Vehicle",
        ["limit_for_player"]    = "Sie können maximal %{amount} Fahrzeuge auf der Straße parken!",
        ["not_allowed_to_park"] = "Hier darf kein Fahrzeug geparkt werden!",
    },
    mail = {
        ["sender"]              = "%{company}",
        ["subject"]             = "Geparkt %{model}",
        ["message"]             = "Hey, %{username} Vielen Dank für Ihr Vertrauen in unseren Parkplatz! Damit Sie nicht vergessen, wo Sie Ihr Auto geparkt haben. Sie erhalten außerdem eine Erinnerungs-E-Mail mit Kennzeichen und Standort Sie haben Ihr Auto ungefähr geparkt Besitzer: %{username} Modell: %{model} Kennzeichen: %{plate} Ort: %{street}< br /> %{company}",
    },

    discoord = {
        ["version"]   = "[qb-parking] - Laufende Version %{version}",
        ["found"]     = "[qb-parking] - %{count}/%{total} geparkte Fahrzeuge gefunden.",
        ["spawntime"] = "[qb-parking] - Spawnzeit %{spawntime} Millisekunden.",
        ["timeloop"]  = "[qb-parking] - Parkzeitprüfschleife hat begonnen.",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})