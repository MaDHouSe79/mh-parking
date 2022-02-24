local Translations = {
    error = {
        ["citizenid_error"] = "[ERROR] Bürger-ID des Spielers konnte nicht abgerufen werden!",
        ["mis_id"] = "[Error] Eine Spieler-ID ist erforderlich.",
        ["mis_amount"] = "[Error] Es gibt keine Anzahl von Fahrzeugen, die dieser Spieler parken kann.",
    },
    commands = {
        ["addvip"] = "Hinzufügen",
        ["removevip"] = "Entfernen",
    },
    system = {
        ['enable'] = "Das Parksystem %{type} ist jetzt aktiviert",
        ["disable"] = "Das Parksystem %{type} ist jetzt deaktiviert",
        ["freeforall"] = "Parksystem: ist jetzt für alle Spieler aktiviert.",
        ["parkvip"] = "Parksystem: ist jetzt nur für VIP aktiviert.",
        ["no_permission"] = "Parksystem: Sie haben keine Parkberechtigung.",
        ["offline"] = "Parksystem ist offline",
        ["update_needed"] = "Parksystem ist veraltet....",
        ["already_vip"] = "Spieler ist bereits ein VIP!",
        ["vip_not_found"] = "Spieler nicht gefunden!",
        ["vip_add"] = "Spieler %{username} wird als VIP hinzugefügt!",
        ["vip_remove"] = "Player %{username} is removed as vip!",
        ["max_allow_reached"] = "Die maximale Anzahl an gepackten Fahrzeugen für Sie beträgt %{max}",
        ["park_or_drive"] = "Parken oder fahren",
        ["already_reserved"]    = "This parking place has already been reserved by %{name}",
        ["parked_blip_info"]    = "Parked: %{modelname}",
    },
    success = {
        ["parked"] = "Ihr Auto ist gepackt",
        ["route_has_been_set"] = "Es ist ein Wegpunkt auf der Karte, der auf der Karte angezeigt wird.",
    },
    info = {
        ["companyName"] = "Beunhaas BV",
        ["owner"] = "Inhaber: y%{owner}s",
        ["plate"] = "Kennzeichen: g%{plate}s",
        ["model"] = "b%{model}s",
        ["press_drive_car"] = "Drücken Sie F5, um mit dem Fahren zu beginnen",
        ["car_already_parked"] = "Ein Fahrzeug mit dem gleichen Kennzeichen hat bereits geparkt",
        ["car_not_found"] = "Kein Fahrzeug gefunden",
        ["maximum_cars"] = "Es können maximal r%{value}s Autos draußen auf der Straße geparkt werden, und das Limit ist erreicht, du musst dieses Fahrzeug im Parkhaus parken!",
        ["must_own_car"] = "Sie müssen das Auto besitzen, um es zu parken.",
        ["has_take_the_car"] = "Ihr Fahrzeug wurde aus der Parkzone entfernt",
        ["only_cars_allowd"] = "Hier können Sie nur Autos parken",
        ["stop_car"] = "Halten Sie Ihr Fahrzeug an, bevor Sie parken",
        ["police_info"] = "rPolizeis Fahrzeuginfo\n",
        ["citizen_info"] = "gBürgers Fahrzeuginfo\n",
    },
    mail = {
        ["sender"] = "%{company}",
        ["subject"] = "Geparkt %{model}",
        ["message"] = "Hey, %{username} Vielen Dank für Ihr Vertrauen in unseren Parkplatz! Damit Sie nicht vergessen, wo Sie Ihr Auto geparkt haben. Sie erhalten außerdem eine Erinnerungs-E-Mail mit Kennzeichen und Standort Sie haben Ihr Auto ungefähr geparkt Besitzer: %{username} Modell: %{model} Kennzeichen: %{plate} Ort: %{street}< br /> %{company}",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})