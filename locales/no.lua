local Translations = {
    error = {
        ["citizenid_error"]     = "[ERROR] Kunne ikke finne spiller citizenid!",
        ["mis_id"]              = "[Error] En spiller ID er påkrevd.",
        ["mis_amount"]          = "[Error] There is no number of vehicles that this player can park.",
    },
    commands = {
        ["addvip"]              = "Add", 
        ["removevip"]           = "Remove", 
    },
    system = {
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
        ["already_reserved"]    = "This parking place has already been reserved by %{name}",
    },
    success = {
        ["parked"]              = "Din bil er parkert",
        ["route_has_been_set"]  = "GPS er satt til lokasjon av bilen din.",
    },
    info = {
        ["companyName"]         = "EUROPARK",
        ["owner"]               = "Eier: ~y~%{owner}~s~",
        ["plate"]               = "Reg nr: ~g~%{plate}~s~",
        ["model"]               = "~b~%{model}~s~",
        ["press_drive_car"]     = "Trykk K for å kjøre",
        ["car_already_parked"]  = "Et kjøretøy med samme skilt nr er allerede parkert",
        ["car_not_found"]       = "Inget kjøretøy funnet",
        ["maximum_cars"]        = "Det kan være maks ~r~%{value}~s~ biler parkert på gaten, og grensen er nå nådd, du må parkere dette kjøretøyet i en garasje!",
        ["must_own_car"]        = "Du må eie bilen for å parkere den.",
        ["has_take_the_car"]    = "Ditt kjøretøy er fjernet fra parkerings sonen",
        ["only_cars_allowd"]    = "Du kan bare parkere biler her",
        ["stop_car"]            = "Stopp kjøretøy før du parkerer",
        ["police_info"]         = "~r~Politi~s~ Kjøretøy Info\n",
        ["citizen_info"]        = "~g~Borger~s~ Kjøretøy Info\n",
    },
    mail = {
        ["sender"]              = "%{company}",
        ["subject"]             = "Parkert %{model}",
        ["message"]             = "Hei, %{username}<br /><br />Takk for at du valgte våre parkerings tjenester!<br /><br />For å hjelpe deg å huske hvor du har parkert bilen.<br />Vil du derfor motta en påminnelse om hvor du ca har parkert bilen din<br /><br />Eier: %{username}<br />Model: %{model}<br />Reg nr: %{plate}<br />Lokasjon:%{street}<br /><br/><br/>%{company}",
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
